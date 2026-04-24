/// Immutable record of a single "you should have played X" training
/// drill extracted from a game analysis. Lives in the MistakeVault
/// Hive box and powers the Apex Academy SRS queue.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

/// Leitner 3-box schedule. Indexed 0..2; box 3 is "graduated" and
/// drills never re-appear unless the user gets a fresh position wrong.
///
/// Values taken from the Lotus teardown: 1d / 3d / 7d.
enum LeitnerBox {
  fresh(Duration(days: 1)),
  reinforce(Duration(days: 3)),
  mastered(Duration(days: 7));

  const LeitnerBox(this.cooldown);
  final Duration cooldown;

  LeitnerBox get next => switch (this) {
        LeitnerBox.fresh => LeitnerBox.reinforce,
        LeitnerBox.reinforce => LeitnerBox.mastered,
        LeitnerBox.mastered => LeitnerBox.mastered,
      };
}

class MistakeDrill {
  const MistakeDrill({
    required this.id,
    required this.fenBefore,
    required this.isWhiteToMove,
    required this.userMoveUci,
    required this.userMoveSan,
    required this.bestMoveUci,
    required this.bestMoveSan,
    required this.classification,
    required this.sourceGameId,
    required this.sourcePly,
    required this.createdAt,
    required this.nextDueAt,
    this.lastReviewedAt,
    this.leitnerBox = LeitnerBox.fresh,
    this.reviewsCorrect = 0,
    this.reviewsWrong = 0,
    this.openingName,
    this.ecoCode,
  });

  /// Position-stable id. Using FEN (before) as the key means the same
  /// mistake recurring across multiple games deduplicates to one drill
  /// — we sharpen a recurring pattern rather than spamming the queue.
  final String id;
  final String fenBefore;
  final bool isWhiteToMove;
  final String userMoveUci;
  final String userMoveSan;
  final String bestMoveUci;
  final String bestMoveSan;
  final MoveQuality classification;
  final String sourceGameId;
  final int sourcePly;
  final DateTime createdAt;
  final DateTime nextDueAt;
  final DateTime? lastReviewedAt;
  final LeitnerBox leitnerBox;
  final int reviewsCorrect;
  final int reviewsWrong;
  final String? openingName;
  final String? ecoCode;

  bool isDue(DateTime now) => !nextDueAt.isAfter(now);

  MistakeDrill copyWith({
    DateTime? nextDueAt,
    DateTime? lastReviewedAt,
    LeitnerBox? leitnerBox,
    int? reviewsCorrect,
    int? reviewsWrong,
  }) {
    return MistakeDrill(
      id: id,
      fenBefore: fenBefore,
      isWhiteToMove: isWhiteToMove,
      userMoveUci: userMoveUci,
      userMoveSan: userMoveSan,
      bestMoveUci: bestMoveUci,
      bestMoveSan: bestMoveSan,
      classification: classification,
      sourceGameId: sourceGameId,
      sourcePly: sourcePly,
      createdAt: createdAt,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      leitnerBox: leitnerBox ?? this.leitnerBox,
      reviewsCorrect: reviewsCorrect ?? this.reviewsCorrect,
      reviewsWrong: reviewsWrong ?? this.reviewsWrong,
      openingName: openingName,
      ecoCode: ecoCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fenBefore': fenBefore,
        'isWhiteToMove': isWhiteToMove,
        'userMoveUci': userMoveUci,
        'userMoveSan': userMoveSan,
        'bestMoveUci': bestMoveUci,
        'bestMoveSan': bestMoveSan,
        'classification': classification.name,
        'sourceGameId': sourceGameId,
        'sourcePly': sourcePly,
        'createdAt': createdAt.toIso8601String(),
        'nextDueAt': nextDueAt.toIso8601String(),
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
        'leitnerBox': leitnerBox.name,
        'reviewsCorrect': reviewsCorrect,
        'reviewsWrong': reviewsWrong,
        'openingName': openingName,
        'ecoCode': ecoCode,
      };

  factory MistakeDrill.fromJson(Map<dynamic, dynamic> j) {
    final classRaw = j['classification'] as String;
    final classification = MoveQuality.values.firstWhere(
      (q) => q.name == classRaw,
      orElse: () => MoveQuality.mistake,
    );
    final boxRaw = j['leitnerBox'] as String? ?? 'fresh';
    final box = LeitnerBox.values.firstWhere(
      (b) => b.name == boxRaw,
      orElse: () => LeitnerBox.fresh,
    );
    return MistakeDrill(
      id: j['id'] as String,
      fenBefore: j['fenBefore'] as String,
      isWhiteToMove: j['isWhiteToMove'] as bool,
      userMoveUci: j['userMoveUci'] as String,
      userMoveSan: j['userMoveSan'] as String,
      bestMoveUci: j['bestMoveUci'] as String,
      bestMoveSan: j['bestMoveSan'] as String,
      classification: classification,
      sourceGameId: j['sourceGameId'] as String,
      sourcePly: (j['sourcePly'] as num).toInt(),
      createdAt: DateTime.parse(j['createdAt'] as String),
      nextDueAt: DateTime.parse(j['nextDueAt'] as String),
      lastReviewedAt: j['lastReviewedAt'] == null
          ? null
          : DateTime.tryParse(j['lastReviewedAt'] as String),
      leitnerBox: box,
      reviewsCorrect: (j['reviewsCorrect'] as num?)?.toInt() ?? 0,
      reviewsWrong: (j['reviewsWrong'] as num?)?.toInt() ?? 0,
      openingName: j['openingName'] as String?,
      ecoCode: j['ecoCode'] as String?,
    );
  }
}
