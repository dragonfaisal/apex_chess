/// Compact display model for the Stats Recent Scans list.
library;

import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/models/archived_game_card_display.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';

class RecentScanDisplay {
  const RecentScanDisplay({
    required this.card,
    required this.accuracy,
    required this.summary,
  });

  final ApexGameCardDisplayModel card;
  final String accuracy;
  final String summary;

  String get title => '${card.white.name} vs ${card.black.name}';
  String get subtitle => summary;

  factory RecentScanDisplay.fromGame(ArchivedGame game, {String? perspective}) {
    final payload = CanonicalAnalysisPayload.fromArchivedGame(game);
    return RecentScanDisplay.fromPayload(
      payload,
      game: game,
      perspective: perspective,
    );
  }

  factory RecentScanDisplay.fromPayload(
    CanonicalAnalysisPayload payload, {
    required ArchivedGame game,
    String? perspective,
  }) {
    final base = game.toApexGameCardDisplay(userHandle: perspective);
    return RecentScanDisplay(
      card: ApexGameCardDisplayModel(
        resultTone: base.resultTone,
        white: base.white,
        black: base.black,
        primaryMeta: '${payload.accuracyLabel}% · ${payload.reviewModeLabel}',
        moveCountLabel: '${payload.moveCount} moves',
        secondaryMeta: '${payload.sourceLabel} · ${game.relativePlayedAt}',
      ),
      accuracy: payload.accuracyLabel,
      summary:
          '${payload.accuracyLabel}% · '
          '${payload.reviewModeLabel} · ${payload.moveCount} moves',
    );
  }
}
