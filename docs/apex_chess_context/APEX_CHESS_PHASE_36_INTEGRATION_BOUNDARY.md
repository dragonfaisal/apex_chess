# Apex Chess Phase 36 Integration Boundary

## Purpose

Phase 36O consolidates the Phase 35Q through Phase 36N developer-preview
chain and stops further safety-wrapper rotation. This document is an
architecture boundary note, not a runtime layer, UI surface, persistence path,
file export, backend payload, or public classification contract.

## Chain Summary

- Phase 35Q private single-move draft analysis: richest private evidence
  source. It owns the controlled single-move draft evidence, private bucket,
  private reason, private confidence tier, and public/official guard flags.
- Phase 36A legacy reintegration seam: first safe bridge from the private
  analysis result toward legacy read-model work. It blocks old analyzer,
  classifier, saved-review, UI, and archive/stat paths.
- Phase 36B legacy move result read model: safe internal single-move read
  shape.
- Phase 36C legacy timeline entry read model: safe single-entry timeline shape
  with deterministic order.
- Phase 36D legacy timeline collection read model: safe internal collection of
  timeline entries.
- Phase 36E legacy review summary read model: safe aggregate summary for the
  developer-only review chain.
- Phase 36F legacy review envelope read model: useful package of safe timeline
  collection and safe summary.
- Phase 36H developer review envelope snapshot: developer-only read-only
  snapshot of the safe envelope.
- Phase 36J developer snapshot export contract: in-memory export guard. Keep it
  for compatibility and existing validation, but do not extend it as a future
  product or preview boundary.
- Phase 36L developer snapshot debug read facade: read facade over the export
  contract. Keep it for compatibility and existing validation, but do not extend
  it as a future product or preview boundary.
- Phase 36N developer debug preview contract: chosen source of truth for future
  read-only developer preview work.

## Source Of Truth Decision

Use `AnalyzerDeveloperDebugPreviewContract` as the source of truth for future
read-only developer preview work.

This boundary is the right stopping point because it is typed, read-only,
developer-only, and explicitly not public, product UI, debug UI, persistence,
saved analysis, file export, backend, archive/stat output, or official metrics.
It carries source identifiers, preview status, safe private counts, and the
public/official/side-effect guard fields needed by the next real integration
step.

## Useful Layers To Keep

- Keep Phase 35Q as the private evidence source.
- Keep Phase 36A as the legacy reintegration seam.
- Keep Phase 36B through Phase 36F as the safe internal legacy read-model chain.
- Keep Phase 36H as the envelope-to-snapshot bridge.
- Keep Phase 36N as the developer preview source of truth.
- Keep Phase 36J and Phase 36L for compatibility and existing tests, but treat
  them as complete hardening layers rather than extension points.

## Redundant Or Over-Defensive Layers

The Phase 36H through Phase 36N chain contains more safety envelopes than the
next integration step should need. The export contract and debug read facade are
defensive bridges around an already safe snapshot. They should not become the
pattern for more preview layers.

Additional golden-case-only or wrapper-only phases would add rotation without
moving product/runtime capability forward.

## Layers To Stop Extending

- Do not add another snapshot wrapper above the Phase 36N developer debug
  preview contract.
- Do not add another export-only or facade-only phase before a real consumer.
- Do not add another safety-golden-only phase unless a real runtime or product
  boundary changes.
- Do not turn this chain into UI, debug UI, saved analysis, persistence, file
  export, backend, archive/stat output, or public classification work.

## Unsafe Paths Still Blocked

The next work must continue to block product UI, debug UI, view models,
persistence, saved analysis, file export, backend payloads, archive/stat output,
public labels, official move quality, official win percentage, official CP-loss,
accuracy, ACPL, engine calls, Android proof, and legacy analyzer/classifier
execution.

## Next Integration Boundary

The next real build step is a read-only developer preview adapter.

The adapter should:

- consume `AnalyzerDeveloperDebugPreviewContract`;
- expose a narrow developer-only read interface for one safe preview source;
- avoid creating a new safety wrapper or another golden-case-only layer;
- avoid UI, debug UI, view models, persistence, saved analysis, file export,
  backend payloads, archive/stat output, public labels, official metrics,
  engine calls, and Android proof;
- include one focused pure adapter test proving the clean contract is consumed;
- include one fail-closed pure adapter test for unsafe or unavailable preview
  contracts.

## Minimal Boundary Tests Going Forward

The boundary should be protected by consumer tests, not another standalone
diagnostic layer:

- a focused adapter success test consuming a clean
  `AnalyzerDeveloperDebugPreviewContract`;
- a focused fail-closed test for unsafe or unavailable preview contracts;
- a guard test proving public/official/side-effect outputs remain absent.

No additional wrapper-only phase is needed unless a real runtime or product
boundary changes.
