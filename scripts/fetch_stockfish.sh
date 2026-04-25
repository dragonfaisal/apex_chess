#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# fetch_stockfish.sh — vendor the Stockfish engine into src/native/vendor/
#
# Downloads the official Stockfish source at a pinned tag and stages it for
# the apex_chess native bridge:
#
#   1. Clones (shallow) https://github.com/official-stockfish/Stockfish.git
#      at `${APEX_STOCKFISH_TAG}` (default: sf_17 — current stable as of 2025).
#      Stockfish 18 is still a development branch; bump this variable when
#      sf_18 tags land.
#
#   2. Renames the engine's `int main(int, char**)` to
#      `extern "C" int stockfish_main(int, char**)` so the bridge can drive
#      the UCI loop in-process. This is the ONLY change we make to upstream
#      source — stdin/stdout redirection happens in the bridge via pipes.
#
#   3. Applies Apex's lightweight NNUE patch so both network slots use the
#      mobile-friendly small net.
#
#   4. Fetches only the small NNUE weight file. NNUE is ENABLED by default —
#      Stockfish 17 is NNUE-only and will crash on `go depth` without real
#      weights. Pass `--no-nnue` (or set `APEX_STOCKFISH_WITH_NNUE=0`) only
#      if you need to exercise UCI wiring without searching.
#
# Idempotent — re-running over an existing vendor/ directory is a no-op
# unless `--force` is passed.
#
# Usage:
#   scripts/fetch_stockfish.sh                       # vendor + download NNUE
#   scripts/fetch_stockfish.sh --no-nnue             # skip NNUE download (stubs)
#   scripts/fetch_stockfish.sh --force               # re-vendor from scratch
#   APEX_STOCKFISH_TAG=sf_18 scripts/fetch_stockfish.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/src/native/vendor/Stockfish"

TAG="${APEX_STOCKFISH_TAG:-sf_17}"
WITH_NNUE="${APEX_STOCKFISH_WITH_NNUE:-1}"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --with-nnue) WITH_NNUE=1 ;;
    --no-nnue)   WITH_NNUE=0 ;;
    --force)     FORCE=1 ;;
    -h|--help)
      sed -n '2,33p' "$0"
      exit 0
      ;;
    *)
      echo "[fetch-stockfish] unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

echo "[fetch-stockfish] tag=$TAG  with_nnue=$WITH_NNUE  vendor=$VENDOR_DIR"

if [ -d "$VENDOR_DIR/.git" ] && [ "$FORCE" -eq 0 ]; then
  echo "[fetch-stockfish] already vendored — pass --force to re-fetch."
else
  if [ "$FORCE" -eq 1 ] && [ -d "$VENDOR_DIR" ]; then
    echo "[fetch-stockfish] --force: removing $VENDOR_DIR"
    rm -rf "$VENDOR_DIR"
  fi
  mkdir -p "$(dirname "$VENDOR_DIR")"
  git clone --depth 1 --branch "$TAG" \
      https://github.com/official-stockfish/Stockfish.git "$VENDOR_DIR"

  # ── Patch: rename upstream `main` so the bridge can drive UCI. ──────────
  MAIN_CPP="$VENDOR_DIR/src/main.cpp"
  if [ ! -f "$MAIN_CPP" ]; then
    echo "[fetch-stockfish] ERROR: $MAIN_CPP not found — Stockfish layout changed?" >&2
    exit 1
  fi
  # Idempotent rewrite: only patch if the original symbol is present.
  if grep -qE '^int main\(int argc, char\* argv\[\]\)' "$MAIN_CPP"; then
    sed -i.bak \
      's/^int main(int argc, char\* argv\[\])/extern "C" int stockfish_main(int argc, char* argv[])/' \
      "$MAIN_CPP"
    rm -f "$MAIN_CPP.bak"
    echo "[fetch-stockfish] patched main.cpp: main → stockfish_main"
  else
    echo "[fetch-stockfish] main.cpp already patched (or signature changed)"
  fi
fi

VENDOR_DIR="$VENDOR_DIR" python3 - <<'PY'
import os
from pathlib import Path

root = Path(os.environ["VENDOR_DIR"]) / "src"

def replace(path: str, old: str, new: str) -> None:
    file = root / path
    text = file.read_text()
    if old not in text:
        return
    file.write_text(text.replace(old, new))

small_name = "nn-37f18f62d772.nnue"
replace(
    "evaluate.h",
    '#define EvalFileDefaultNameBig "nn-1111cefa1111.nnue"',
    f'#define EvalFileDefaultNameBig "{small_name}"',
)
replace(
    "nnue/network.h",
    "using BigFeatureTransformer =\n"
    "  FeatureTransformer<TransformedFeatureDimensionsBig, &StateInfo::accumulatorBig>;\n"
    "using BigNetworkArchitecture = NetworkArchitecture<TransformedFeatureDimensionsBig, L2Big, L3Big>;",
    "using BigFeatureTransformer =\n"
    "  FeatureTransformer<TransformedFeatureDimensionsSmall, &StateInfo::accumulatorSmall>;\n"
    "using BigNetworkArchitecture = NetworkArchitecture<TransformedFeatureDimensionsSmall, L2Small, L3Small>;",
)
replace(
    "nnue/network.cpp",
    "template class Network<\n"
    "  NetworkArchitecture<TransformedFeatureDimensionsBig, L2Big, L3Big>,\n"
    "  FeatureTransformer<TransformedFeatureDimensionsBig, &StateInfo::accumulatorBig>>;\n\n",
    "",
)
for file_name in ("evaluate.cpp", "nnue/nnue_misc.cpp"):
    file = root / file_name
    text = file.read_text().replace("networks.big.evaluate(pos, &caches.big)", "networks.big.evaluate(pos, &caches.small)")
    text = text.replace("networks.big.evaluate(pos, &caches->big)", "networks.big.evaluate(pos, &caches->small)")
    text = text.replace("networks.big.hint_common_access(pos, &caches.big)", "networks.big.hint_common_access(pos, &caches.small)")
    text = text.replace("networks.big.trace_evaluate(pos, &caches.big)", "networks.big.trace_evaluate(pos, &caches.small)")
    file.write_text(text)

big_net = root / "nn-1111cefa1111.nnue"
if big_net.exists():
    big_net.unlink()
PY
echo "[fetch-stockfish] applied Apex lightweight NNUE patch"

# ── NNUE weight files (optional) ──────────────────────────────────────────
NNUE_DIR="$VENDOR_DIR/src"
if [ "$WITH_NNUE" -eq 1 ]; then
  # Parse and download only the small NNUE filename from evaluate.h.
  EVAL_H="$VENDOR_DIR/src/evaluate.h"
  if [ -f "$EVAL_H" ]; then
    SMALL="$(grep -oE 'nn-[a-f0-9]+\.nnue' "$EVAL_H" | tail -1)"
    if [ -n "$SMALL" ] && [ ! -f "$NNUE_DIR/$SMALL" ]; then
      echo "[fetch-stockfish] downloading lightweight NNUE $SMALL"
      curl -fsSL "https://tests.stockfishchess.org/api/nn/$SMALL" -o "$NNUE_DIR/$SMALL" || {
        echo "[fetch-stockfish] NNUE download failed — engine search will fail until the file exists." >&2
      }
    fi
  else
    echo "[fetch-stockfish] evaluate.h not found — skipping NNUE download."
  fi
else
  # Stub .nnue files so incbin doesn't fail to compile when the real weights
  # aren't requested. Engine will emit a warning and degrade gracefully at
  # runtime unless `EvalFile` is pointed at a real file.
  EVAL_H="$VENDOR_DIR/src/evaluate.h"
  if [ -f "$EVAL_H" ]; then
    for f in $(grep -oE 'nn-[a-f0-9]+\.nnue' "$EVAL_H" | sort -u); do
      if [ ! -f "$NNUE_DIR/$f" ]; then
        : > "$NNUE_DIR/$f"
        echo "[fetch-stockfish] created stub $f (pass --with-nnue for real weights)"
      fi
    done
  fi
fi

echo "[fetch-stockfish] done. Next:"
echo "  cmake -S src/native -B build/native"
echo "  cmake --build build/native -j"
echo ""
echo "  (vendor/ is intentionally checked in so Android builds use real Stockfish)"
