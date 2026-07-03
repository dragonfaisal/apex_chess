# Apex Chess Review UI Canon

## Purpose
This document defines the review-screen product identity and UI behavior for Apex Chess. It protects the premium review experience from casual redesign and noisy label presentation.

## Current Canon

### Review Screen Identity
- Fast, clean, premium, simple on the surface, powerful underneath.
- Material 3 inspired.
- Deep dark navy base with electric blue/cyan accents.
- Subtle neon only when it communicates analysis meaning.
- No fake hype words or decorative clutter.

### Move Timeline Behavior
- Timeline must stay synchronized with board, eval chart, labels, and explanations.
- It must support scanning key moves without blocking the board.
- Badges and counts must match underlying saved timeline data.

### Board Overlay Behavior
- Highlights must identify the selected move and relevant squares.
- Overlays must not obscure pieces or legal move comprehension.
- Castling markers must attach to the king destination square, not the rook square.

### Better-Move Arrow Behavior
- Better-move arrows are for mistakes or missed opportunities where a better move is known.
- Suppress noisy better-move arrows on Best, Brilliant, Great, and Book unless explicitly scoped.
- Arrow plus destination halo should be readable in dark mode.

### Eval Bar / Chart Expectations
- Eval visuals must make perspective clear.
- CP and mate must be represented honestly.
- Charts must not display fake zero values from failed engine paths.

### Badge / Icon Policy
Current implementation must be inspected before changing icons.

Known direction:
- Brilliant: `!!` plus glow/halo/sparkle identity.
- Great: strong positive marker.
- Best: best/check marker.
- Excellent: high positive marker.
- Good: simple positive marker.
- Book: book/theory marker.
- Inaccuracy: `?!`.
- Mistake: `?`.
- Blunder: `??`.
- Checkmate: `#`.
- Miss: missed opportunity marker.

### Brilliant Glow / Halo
- Brilliant visual treatment should feel rare and special.
- Do not overuse glow on ordinary moves.
- Glow must not impair readability or accessibility.

### Label Display Policy
- Labels must come from saved/active analysis evidence.
- Provisional labels must look provisional.
- Internal-only labels such as forced/onlyMove/candidate should not be displayed publicly unless explicitly approved.

### Beginner-Friendly Explanation Style
- Explain what changed and what to try instead.
- Avoid raw engine jargon unless the user is in an advanced detail view.
- Use concrete, short coaching.

## Rules
- Do not redesign UI identity unless scoped.
- Do not add visible feature-explainer text to product surfaces unless part of the actual workflow.
- Keep board, timeline, eval, and explanation state synchronized.
- Any visual badge change requires inspecting current implementation first.

## Forbidden Regressions
- Move list covering the board or making review unusable.
- Castling aura on the wrong square.
- Badge/icon drift from classification canon.
- Raw UCI, PV dumps, or debug proof output in product UI.
- Hype words replacing evidence.
- Dark navy/cyan identity replaced casually by generic palettes.

## Phase Usage Notes
- Use this file for review board, timeline, badge, explanation, chart, and visual identity phases.
- Run focused UI/golden/manual checks when UI is touched.
- Android visual proof is needed for layout, text fit, gestures, and board/timeline usability changes.
