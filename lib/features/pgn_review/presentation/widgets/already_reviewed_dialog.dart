library;

import 'package:flutter/material.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

enum AlreadyReviewedAction { preview, analyzeAnyway }

Future<AlreadyReviewedAction?> showAlreadyReviewedDialog({
  required BuildContext context,
  required ArchivedGame savedReview,
  required AnalysisProfile requestedProfile,
}) {
  return showDialog<AlreadyReviewedAction>(
    context: context,
    barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
    builder: (_) => AlreadyReviewedDialog(
      savedReview: savedReview,
      requestedProfile: requestedProfile,
    ),
  );
}

class AlreadyReviewedDialog extends StatelessWidget {
  const AlreadyReviewedDialog({
    super.key,
    required this.savedReview,
    required this.requestedProfile,
  });

  final ArchivedGame savedReview;
  final AnalysisProfile requestedProfile;

  @override
  Widget build(BuildContext context) {
    final savedModeLabel = reviewProviderModeLabelFor(
      savedReview.analysisProfile.id,
    );
    return Dialog(
      key: const ValueKey('already-reviewed-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassPanel.dialog(
        accentColor: ApexColors.sapphire,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bookmark_added_rounded,
                  color: ApexColors.sapphireBright,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Already reviewed',
                    style: ApexTypography.titleMedium.copyWith(
                      color: ApexColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('already-reviewed-close'),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: ApexColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Saved mode: $savedModeLabel',
              key: const ValueKey('already-reviewed-current-mode'),
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 13,
              ),
            ),
            if (_requestedLabel != savedModeLabel) ...[
              const SizedBox(height: 4),
              Text(
                'Selected: $_requestedLabel',
                key: const ValueKey('already-reviewed-requested-mode'),
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('already-reviewed-preview'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(AlreadyReviewedAction.preview),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ApexColors.sapphireBright,
                      side: BorderSide(
                        color: ApexColors.sapphireBright.withValues(
                          alpha: 0.42,
                        ),
                        width: 0.7,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    key: const ValueKey('already-reviewed-analyze-anyway'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(AlreadyReviewedAction.analyzeAnyway),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ApexColors.sapphire,
                      foregroundColor: ApexColors.darkSurface,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Analyze anyway'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _requestedLabel => switch (requestedProfile.id) {
    AnalysisProfileId.fastReview => reviewProviderModeLabelFor(
      AnalysisProfileId.fastReview,
    ),
    AnalysisProfileId.offlineReview => reviewProviderModeLabelFor(
      AnalysisProfileId.offlineReview,
    ),
    AnalysisProfileId.deepReview => reviewProviderModeLabelFor(
      AnalysisProfileId.deepReview,
    ),
  };
}
