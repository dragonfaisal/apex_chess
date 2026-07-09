import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';

abstract final class AnalysisDevDiagnosticsEntryConfigKeys {
  static const enabled = 'APEX_ANALYSIS_DEV_DIAGNOSTICS_ENTRY';
}

class AnalysisDevDiagnosticsEntryConfig {
  const AnalysisDevDiagnosticsEntryConfig({required this.enabled});

  const AnalysisDevDiagnosticsEntryConfig.disabled() : enabled = false;

  const AnalysisDevDiagnosticsEntryConfig.enabled() : enabled = true;

  factory AnalysisDevDiagnosticsEntryConfig.fromMap(
    Map<String, String> values,
  ) {
    return AnalysisDevDiagnosticsEntryConfig(
      enabled:
          values[AnalysisDevDiagnosticsEntryConfigKeys.enabled]
              ?.trim()
              .toLowerCase() ==
          'true',
    );
  }

  static AnalysisDevDiagnosticsEntryConfig fromEnvironment() {
    const enabled = bool.fromEnvironment(
      AnalysisDevDiagnosticsEntryConfigKeys.enabled,
    );
    return const AnalysisDevDiagnosticsEntryConfig(enabled: enabled);
  }

  final bool enabled;
}

class AnalysisDevDiagnosticsEntry extends StatelessWidget {
  const AnalysisDevDiagnosticsEntry({super.key, this.config, this.preview});

  final AnalysisDevDiagnosticsEntryConfig? config;
  final AnalyzerNeutralReviewPreviewDisplayModel? preview;

  @override
  Widget build(BuildContext context) {
    final effectiveConfig =
        config ?? AnalysisDevDiagnosticsEntryConfig.fromEnvironment();
    return effectiveConfig.enabled
        ? _AnalysisDevDiagnosticsEnabled(preview: preview)
        : const _AnalysisDevDiagnosticsDisabled();
  }
}

class _AnalysisDevDiagnosticsDisabled extends StatelessWidget {
  const _AnalysisDevDiagnosticsDisabled();

  @override
  Widget build(BuildContext context) {
    return const _DiagnosticsScaffold(
      key: ValueKey('analysis-dev-diagnostics-entry-disabled'),
      title: 'Developer diagnostics disabled',
      message: 'Enable the explicit dev flag to open this diagnostics shell.',
      showPreviewArea: false,
    );
  }
}

class _AnalysisDevDiagnosticsEnabled extends StatelessWidget {
  const _AnalysisDevDiagnosticsEnabled({required this.preview});

  final AnalyzerNeutralReviewPreviewDisplayModel? preview;

  @override
  Widget build(BuildContext context) {
    return _DiagnosticsScaffold(
      key: const ValueKey('analysis-dev-diagnostics-entry-enabled'),
      title: 'Developer diagnostics enabled',
      message: 'Developer diagnostics only. No review surface is active.',
      preview: preview,
      showPreviewArea: true,
    );
  }
}

class _DiagnosticsScaffold extends StatelessWidget {
  const _DiagnosticsScaffold({
    super.key,
    required this.title,
    required this.message,
    required this.showPreviewArea,
    this.preview,
  });

  final String title;
  final String message;
  final bool showPreviewArea;
  final AnalyzerNeutralReviewPreviewDisplayModel? preview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ApexColors.deepSpace,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(ApexSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ApexColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ApexColors.subtleBorder,
                            width: 0.7,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(ApexSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                title,
                                style: ApexTypography.titleMedium.copyWith(
                                  color: ApexColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: ApexSpacing.sm),
                              Text(
                                message,
                                style: ApexTypography.bodyMedium.copyWith(
                                  color: ApexColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              if (showPreviewArea && preview == null) ...[
                                const SizedBox(height: ApexSpacing.md),
                                const _DiagnosticsEmptyState(),
                              ] else if (showPreviewArea) ...[
                                const SizedBox(height: ApexSpacing.md),
                                _NeutralPreviewRows(preview: preview!),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DiagnosticsEmptyState extends StatelessWidget {
  const _DiagnosticsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const _DiagnosticsRow(
      label: 'neutralPreviewModel',
      value: 'not provided',
    );
  }
}

class _NeutralPreviewRows extends StatelessWidget {
  const _NeutralPreviewRows({required this.preview});

  final AnalyzerNeutralReviewPreviewDisplayModel preview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DiagnosticsSectionLabel('Neutral preview display model'),
        _DiagnosticsRow(
          label: 'displayModelReady',
          value: preview.displayModelReady.toString(),
        ),
        _DiagnosticsRow(
          label: 'unavailableReason',
          value: preview.unavailableReason.wire,
        ),
        _DiagnosticsRow(
          label: 'planningAllowed',
          value: preview.planningAllowed.toString(),
        ),
        _DiagnosticsRow(
          label: 'uiRenderingAllowed',
          value: _blockedValue(preview.uiRenderingAllowed),
        ),
        _DiagnosticsRow(
          label: 'savedAnalysisAllowed',
          value: _blockedValue(preview.savedAnalysisAllowed),
        ),
        _DiagnosticsRow(
          label: 'archiveStatsAllowed',
          value: _blockedValue(preview.archiveStatsAllowed),
        ),
        _DiagnosticsRow(
          label: 'publicLabelsAllowed',
          value: _blockedValue(preview.publicLabelsAllowed),
        ),
        _DiagnosticsRow(
          label: 'officialMetricsAllowed',
          value: _blockedValue(preview.officialMetricsAllowed),
        ),
        _DiagnosticsRow(
          label: 'totalPrivateEntries',
          value: preview.totalPrivateEntries.toString(),
        ),
        _DiagnosticsRow(
          label: 'positiveCandidateCount',
          value: preview.positiveCandidateCount.toString(),
        ),
        _DiagnosticsRow(
          label: 'neutralCandidateCount',
          value: preview.neutralCandidateCount.toString(),
        ),
        _DiagnosticsRow(
          label: 'negativeCandidateCount',
          value: preview.negativeCandidateCount.toString(),
        ),
        _DiagnosticsRow(
          label: 'unavailableCount',
          value: preview.unavailableCount.toString(),
        ),
        const SizedBox(height: ApexSpacing.sm),
        const _DiagnosticsSectionLabel('Guardrails'),
        const _DiagnosticsRow(label: 'UI rendering', value: 'blocked'),
        const _DiagnosticsRow(label: 'Public labels', value: 'blocked'),
        const _DiagnosticsRow(label: 'Official metrics', value: 'blocked'),
        const _DiagnosticsRow(label: 'Saved/archive', value: 'blocked'),
      ],
    );
  }

  static String _blockedValue(bool value) => value ? 'true' : 'false blocked';
}

class _DiagnosticsSectionLabel extends StatelessWidget {
  const _DiagnosticsSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ApexSpacing.xs),
      child: Text(
        label,
        style: ApexTypography.labelLarge.copyWith(
          color: ApexColors.sapphireBright,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DiagnosticsRow extends StatelessWidget {
  const _DiagnosticsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: ApexSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
