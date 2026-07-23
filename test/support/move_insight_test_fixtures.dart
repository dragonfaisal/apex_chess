import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/move_insight_engine.dart';

MoveInsight testBookInsight({
  String eco = 'B00',
  String name = "King's Pawn Game",
}) {
  final facts = <MoveInsightFact>[
    const MoveInsightFact(
      id: 'f_legal',
      type: MoveInsightFactType.legalTransition,
      pieceRole: 'pawn',
      pieceSide: 'white',
      fromSquare: 'e2',
      toSquare: 'e4',
    ),
    MoveInsightFact(
      id: 'f_opening',
      type: MoveInsightFactType.openingTransition,
      textValue: '$eco|$name',
    ),
  ];
  final claim = MoveInsightClaim(
    id: 'c_booktransition',
    type: MoveInsightClaimType.bookTransition,
    confidence: MoveInsightConfidence.verified,
    reasonCode: 'verified_exact_opening_transition',
    supportingFactIds: const <String>['f_legal', 'f_opening'],
    openingEco: eco,
    openingName: name,
  );
  return _insight(facts, claim);
}

MoveInsight testMaterialDropInsight({
  String reply = 'Qh2+',
  String betterMove = 'Rf1',
  String pieceRole = 'rook',
}) {
  const facts = <MoveInsightFact>[
    MoveInsightFact(
      id: 'f_legal',
      type: MoveInsightFactType.legalTransition,
      pieceRole: 'rook',
      pieceSide: 'white',
      fromSquare: 'a1',
      toSquare: 'a2',
    ),
    MoveInsightFact(
      id: 'f_played_line',
      type: MoveInsightFactType.coherentEngineLine,
      textValue: 'Qh2+ Kf1 Qxa2',
    ),
    MoveInsightFact(
      id: 'f_played_material',
      type: MoveInsightFactType.materialDelta,
      intValue: -5,
    ),
    MoveInsightFact(
      id: 'f_best_line',
      type: MoveInsightFactType.coherentEngineLine,
      textValue: 'Rf1',
    ),
  ];
  final claim = MoveInsightClaim(
    id: 'c_dropsmaterial',
    type: MoveInsightClaimType.dropsMaterial,
    confidence: MoveInsightConfidence.verified,
    reasonCode: 'best_response_line_sustains_material_loss',
    supportingFactIds: const <String>[
      'f_legal',
      'f_played_line',
      'f_played_material',
      'f_best_line',
    ],
    pieceRole: pieceRole,
    materialDelta: -5,
    betterMoveSan: betterMove,
    opponentReplySan: reply,
    continuationSan: <String>[reply, 'Kf1', 'Qxa2'],
  );
  return _insight(facts, claim);
}

MoveInsight testMateInsight() {
  const facts = <MoveInsightFact>[
    MoveInsightFact(
      id: 'f_legal',
      type: MoveInsightFactType.legalTransition,
      pieceRole: 'queen',
      pieceSide: 'white',
      fromSquare: 'h5',
      toSquare: 'f7',
    ),
    MoveInsightFact(
      id: 'f_terminal_mate',
      type: MoveInsightFactType.terminalMate,
      pieceSide: 'white',
    ),
  ];
  const claim = MoveInsightClaim(
    id: 'c_deliversmate',
    type: MoveInsightClaimType.deliversMate,
    confidence: MoveInsightConfidence.verified,
    reasonCode: 'legal_move_reaches_checkmate',
    supportingFactIds: <String>['f_legal', 'f_terminal_mate'],
    pieceRole: 'queen',
    pieceSquare: 'f7',
  );
  return _insight(facts, claim);
}

MoveInsight _insight(List<MoveInsightFact> facts, MoveInsightClaim claim) {
  final rendered = const MoveInsightRenderer().render(claim);
  return MoveInsight.create(
    state: MoveInsightState.available,
    facts: facts,
    primaryClaim: claim,
    causalChain: <MoveInsightCausalStep>[
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.move,
        factId: claim.supportingFactIds.first,
      ),
      if (claim.supportingFactIds.length > 1)
        MoveInsightCausalStep(
          stage: MoveInsightCausalStage.changedFact,
          factId: claim.supportingFactIds[1],
        ),
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.outcome,
        factId: claim.supportingFactIds.last,
      ),
    ],
    conciseText: rendered.concise,
    causeText: rendered.cause,
    consequenceText: rendered.consequence,
    betterMoveText: rendered.betterMove,
    continuationText: rendered.continuation,
  );
}
