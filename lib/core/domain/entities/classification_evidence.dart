/// Immutable, provider-neutral facts consumed by the Apex move classifier.
///
/// This model deliberately contains no user-facing prose. A classification
/// decision must be reproducible from these facts plus the classifier policy
/// version.
library;

enum ClassificationMover { white, black }

enum ClassificationScoreDomain { centipawn, mate, invalid }

enum ClassificationBookState { verified, notBook, unavailable }

enum ClassificationVerificationState {
  notRequested,
  complete,
  incomplete,
  contradicted,
}

enum ClassificationForcedState {
  onlyLegalMove,
  verifiedForcedResponse,
  notForced,
  unavailable,
}

enum ClassificationUnavailableReason {
  unsupportedSchema,
  missingEvaluationBefore,
  missingPlayedMoveEvaluation,
  missingBestMoveEvaluation,
  ambiguousScore,
  missingMoveIdentity,
  incompleteSearch,
  incoherentCandidates,
  contradictoryBestMove,
  invalidCandidate,
  unknown,
}

/// A single score in Apex's canonical White perspective.
///
/// Exactly one of [whiteCp] and [whiteMate] must be present. Mate zero is not
/// an engine verdict and is therefore invalid evidence.
class ClassificationScore {
  const ClassificationScore({this.whiteCp, this.whiteMate});

  const ClassificationScore.cp(int cp) : whiteCp = cp, whiteMate = null;

  const ClassificationScore.mate(int mate) : whiteCp = null, whiteMate = mate;

  final int? whiteCp;
  final int? whiteMate;

  ClassificationScoreDomain get domain {
    if (whiteCp != null && whiteMate == null) {
      return ClassificationScoreDomain.centipawn;
    }
    if (whiteCp == null && whiteMate != null && whiteMate != 0) {
      return ClassificationScoreDomain.mate;
    }
    return ClassificationScoreDomain.invalid;
  }

  bool get isValid => domain != ClassificationScoreDomain.invalid;

  Map<String, Object?> toJson() => <String, Object?>{
    'domain': domain.name,
    'whiteCp': whiteCp,
    'whiteMate': whiteMate,
  };

  factory ClassificationScore.fromJson(Map<dynamic, dynamic> json) =>
      ClassificationScore(
        whiteCp: (json['whiteCp'] as num?)?.toInt(),
        whiteMate: (json['whiteMate'] as num?)?.toInt(),
      );
}

/// One exact root candidate from a coherent engine frame.
class ClassificationCandidateEvidence {
  const ClassificationCandidateEvidence({
    required this.rootUci,
    required this.rank,
    required this.score,
    required this.achievedDepth,
    required this.isLegal,
    required this.pvComplete,
  });

  final String rootUci;
  final int rank;
  final ClassificationScore score;
  final int achievedDepth;
  final bool isLegal;
  final bool pvComplete;

  bool get isStructurallyValid =>
      _isValidRootUci(rootUci) &&
      rank > 0 &&
      score.isValid &&
      achievedDepth > 0 &&
      isLegal &&
      pvComplete;

  Map<String, Object?> toJson() => <String, Object?>{
    'rootUci': rootUci,
    'rank': rank,
    'score': score.toJson(),
    'achievedDepth': achievedDepth,
    'isLegal': isLegal,
    'pvComplete': pvComplete,
  };

  factory ClassificationCandidateEvidence.fromJson(
    Map<dynamic, dynamic> json,
  ) => ClassificationCandidateEvidence(
    rootUci: json['rootUci'] as String? ?? '',
    rank: (json['rank'] as num?)?.toInt() ?? 0,
    score: ClassificationScore.fromJson(
      (json['score'] as Map?) ?? const <String, Object?>{},
    ),
    achievedDepth: (json['achievedDepth'] as num?)?.toInt() ?? 0,
    isLegal: json['isLegal'] as bool? ?? false,
    pvComplete: json['pvComplete'] as bool? ?? false,
  );
}

/// Complete immutable input to the versioned production classifier.
class MoveClassificationEvidence {
  MoveClassificationEvidence({
    this.schemaVersion = 1,
    required this.mover,
    required this.evaluationBefore,
    required this.playedMoveEvaluation,
    required this.bestMoveEvaluation,
    required this.playedMoveUci,
    required this.bestMoveUci,
    List<ClassificationCandidateEvidence> candidates =
        const <ClassificationCandidateEvidence>[],
    this.requestedMultiPv = 1,
    this.receivedMultiPv = 0,
    this.candidateSetComplete = false,
    this.candidateSetCoherent = false,
    this.bestMovePv1Consistent = false,
    this.searchQualityMet = false,
    this.achievedDepthFloor,
    this.legalMoveCount,
    this.bookState = ClassificationBookState.unavailable,
    this.verificationState = ClassificationVerificationState.notRequested,
    this.forcedState = ClassificationForcedState.unavailable,
    this.isSacrifice,
    this.isCapture,
    this.isFreeCapture,
    this.isRecapture,
    this.isTrivialRecapture,
    this.isFirstSacrificePly,
    this.tacticalBestOrNearBest = false,
    this.tacticalHasForcingOutcome = false,
    this.tacticalForcedMate = false,
    this.unavailableReason,
  }) : candidates = List<ClassificationCandidateEvidence>.unmodifiable(
         candidates,
       );

  final int schemaVersion;
  final ClassificationMover mover;
  final ClassificationScore? evaluationBefore;
  final ClassificationScore? playedMoveEvaluation;
  final ClassificationScore? bestMoveEvaluation;
  final String? playedMoveUci;
  final String? bestMoveUci;
  final List<ClassificationCandidateEvidence> candidates;
  final int requestedMultiPv;
  final int receivedMultiPv;
  final bool candidateSetComplete;
  final bool candidateSetCoherent;

  /// Upstream assertion that bestmove, PV1 root, and PV1 score belong to the
  /// same selected coherent engine frame.
  final bool bestMovePv1Consistent;
  final bool searchQualityMet;
  final int? achievedDepthFloor;
  final int? legalMoveCount;
  final ClassificationBookState bookState;
  final ClassificationVerificationState verificationState;
  final ClassificationForcedState forcedState;

  /// Nullable material facts. Null means unavailable, never false.
  final bool? isSacrifice;
  final bool? isCapture;
  final bool? isFreeCapture;
  final bool? isRecapture;
  final bool? isTrivialRecapture;
  final bool? isFirstSacrificePly;

  /// Factual verifier outputs. No motif names or explanation prose live here.
  final bool tacticalBestOrNearBest;
  final bool tacticalHasForcingOutcome;
  final bool tacticalForcedMate;

  final ClassificationUnavailableReason? unavailableReason;

  bool get hasValidCoreScores =>
      evaluationBefore?.isValid == true &&
      playedMoveEvaluation?.isValid == true &&
      bestMoveEvaluation?.isValid == true;

  bool get hasExactMoveIdentity =>
      playedMoveUci != null &&
      _isValidRootUci(playedMoveUci!) &&
      bestMoveUci != null &&
      _isValidRootUci(bestMoveUci!);

  bool get hasStructurallyCoherentCandidates {
    if (!candidateSetCoherent || candidates.isEmpty) return false;
    final roots = <String>{};
    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      if (candidate.rank != index + 1 ||
          !candidate.isStructurallyValid ||
          !roots.add(_normalizeRootUci(candidate.rootUci))) {
        return false;
      }
    }
    return true;
  }

  bool get hasCompleteCandidateSet =>
      candidateSetComplete &&
      hasStructurallyCoherentCandidates &&
      requestedMultiPv > 0 &&
      receivedMultiPv >= requestedMultiPv &&
      candidates.length >= requestedMultiPv;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'mover': mover.name,
    'evaluationBefore': evaluationBefore?.toJson(),
    'playedMoveEvaluation': playedMoveEvaluation?.toJson(),
    'bestMoveEvaluation': bestMoveEvaluation?.toJson(),
    'playedMoveUci': playedMoveUci,
    'bestMoveUci': bestMoveUci,
    'candidates': candidates
        .map((candidate) => candidate.toJson())
        .toList(growable: false),
    'requestedMultiPv': requestedMultiPv,
    'receivedMultiPv': receivedMultiPv,
    'candidateSetComplete': candidateSetComplete,
    'candidateSetCoherent': candidateSetCoherent,
    'bestMovePv1Consistent': bestMovePv1Consistent,
    'searchQualityMet': searchQualityMet,
    'achievedDepthFloor': achievedDepthFloor,
    'legalMoveCount': legalMoveCount,
    'bookState': bookState.name,
    'verificationState': verificationState.name,
    'forcedState': forcedState.name,
    'isSacrifice': isSacrifice,
    'isCapture': isCapture,
    'isFreeCapture': isFreeCapture,
    'isRecapture': isRecapture,
    'isTrivialRecapture': isTrivialRecapture,
    'isFirstSacrificePly': isFirstSacrificePly,
    'tacticalBestOrNearBest': tacticalBestOrNearBest,
    'tacticalHasForcingOutcome': tacticalHasForcingOutcome,
    'tacticalForcedMate': tacticalForcedMate,
    'unavailableReason': unavailableReason?.name,
  };

  factory MoveClassificationEvidence.fromJson(Map<dynamic, dynamic> json) {
    T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.where((value) => value.name == raw).firstOrNull ?? fallback;

    final schemaVersion = (json['schemaVersion'] as num?)?.toInt();
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported or missing classification evidence schema: '
        '${json['schemaVersion']}',
      );
    }
    final moverRaw = json['mover'];
    final moverMatches = ClassificationMover.values.where(
      (value) => value.name == moverRaw,
    );
    if (moverMatches.isEmpty) {
      throw FormatException(
        'Missing or unknown classification evidence mover: $moverRaw',
      );
    }

    final rawCandidates = json['candidates'] as List<dynamic>? ?? const [];
    final before = json['evaluationBefore'];
    final played = json['playedMoveEvaluation'];
    final best = json['bestMoveEvaluation'];
    final unavailableRaw = json['unavailableReason'];
    return MoveClassificationEvidence(
      schemaVersion: schemaVersion!,
      mover: moverMatches.first,
      evaluationBefore: before is Map
          ? ClassificationScore.fromJson(before)
          : null,
      playedMoveEvaluation: played is Map
          ? ClassificationScore.fromJson(played)
          : null,
      bestMoveEvaluation: best is Map
          ? ClassificationScore.fromJson(best)
          : null,
      playedMoveUci: json['playedMoveUci'] as String?,
      bestMoveUci: json['bestMoveUci'] as String?,
      candidates: rawCandidates
          .whereType<Map<dynamic, dynamic>>()
          .map(ClassificationCandidateEvidence.fromJson)
          .toList(growable: false),
      requestedMultiPv: (json['requestedMultiPv'] as num?)?.toInt() ?? 1,
      receivedMultiPv: (json['receivedMultiPv'] as num?)?.toInt() ?? 0,
      candidateSetComplete: json['candidateSetComplete'] as bool? ?? false,
      candidateSetCoherent: json['candidateSetCoherent'] as bool? ?? false,
      bestMovePv1Consistent: json['bestMovePv1Consistent'] as bool? ?? false,
      searchQualityMet: json['searchQualityMet'] as bool? ?? false,
      achievedDepthFloor: (json['achievedDepthFloor'] as num?)?.toInt(),
      legalMoveCount: (json['legalMoveCount'] as num?)?.toInt(),
      bookState: enumValue(
        ClassificationBookState.values,
        json['bookState'],
        ClassificationBookState.unavailable,
      ),
      verificationState: enumValue(
        ClassificationVerificationState.values,
        json['verificationState'],
        ClassificationVerificationState.notRequested,
      ),
      forcedState: enumValue(
        ClassificationForcedState.values,
        json['forcedState'],
        ClassificationForcedState.unavailable,
      ),
      isSacrifice: json['isSacrifice'] as bool?,
      isCapture: json['isCapture'] as bool?,
      isFreeCapture: json['isFreeCapture'] as bool?,
      isRecapture: json['isRecapture'] as bool?,
      isTrivialRecapture: json['isTrivialRecapture'] as bool?,
      isFirstSacrificePly: json['isFirstSacrificePly'] as bool?,
      tacticalBestOrNearBest: json['tacticalBestOrNearBest'] as bool? ?? false,
      tacticalHasForcingOutcome:
          json['tacticalHasForcingOutcome'] as bool? ?? false,
      tacticalForcedMate: json['tacticalForcedMate'] as bool? ?? false,
      unavailableReason: unavailableRaw == null
          ? null
          : enumValue(
              ClassificationUnavailableReason.values,
              unavailableRaw,
              ClassificationUnavailableReason.unknown,
            ),
    );
  }
}

bool _isValidRootUci(String uci) {
  final lower = uci.toLowerCase();
  if (lower.length != 4 && lower.length != 5) return false;

  bool validSquareAt(int offset) {
    final file = lower.codeUnitAt(offset);
    final rank = lower.codeUnitAt(offset + 1);
    return file >= 'a'.codeUnitAt(0) &&
        file <= 'h'.codeUnitAt(0) &&
        rank >= '1'.codeUnitAt(0) &&
        rank <= '8'.codeUnitAt(0);
  }

  if (!validSquareAt(0) || !validSquareAt(2)) return false;
  return lower.length == 4 || 'qrbn'.contains(lower[4]);
}

String _normalizeRootUci(String uci) {
  final lower = uci.toLowerCase();
  if (lower.length < 4) return lower;
  final suffix = lower.substring(4);
  return switch (lower.substring(0, 4)) {
    'e1h1' => 'e1g1$suffix',
    'e1a1' => 'e1c1$suffix',
    'e8h8' => 'e8g8$suffix',
    'e8a8' => 'e8c8$suffix',
    _ => lower,
  };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
