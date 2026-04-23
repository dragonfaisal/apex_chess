/// Home Screen — Main Menu for Apex Chess (Cloud-Only).
///
/// Three entry points: "Play Live", "Cloud Analyze PGN", and "Demo: Opera Game".
/// Charcoal + Electric Blue "Quiet Power" aesthetics.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/infrastructure/api/cloud_game_analyzer.dart';
import 'package:apex_chess/features/live_play/presentation/views/live_play_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ApexColors.darkSurface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.cloud_rounded,
                color: ApexColors.electricBlue, size: 48),
            const SizedBox(height: 16),
            Text('APEX CHESS',
                style: ApexTypography.displayLarge.copyWith(
                  color: ApexColors.textPrimary,
                  letterSpacing: 6, fontSize: 32)),
            const SizedBox(height: 6),
            Text('Cloud-First AI Coach',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.electricBlue.withAlpha(160),
                  letterSpacing: 2)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _CyberButton(
                label: 'PLAY LIVE',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LivePlayScreen())),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _CyberButton(
                label: 'CLOUD ANALYZE PGN',
                icon: Icons.cloud_sync_rounded,
                isPrimary: false,
                onTap: () => _showPgnDialog(context, ref),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _CyberButton(
                label: 'DEMO: OPERA GAME',
                icon: Icons.auto_awesome_mosaic_rounded,
                isPrimary: false,
                onTap: () => _launchOperaGameDemo(context, ref),
              ),
            ),
            const SizedBox(height: 48),
            Text('Powered by Lichess Cloud • Zero APK Bloat',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary, fontSize: 12)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _launchOperaGameDemo(BuildContext context, WidgetRef ref) {
    final mockApi = ref.read(mockAnalysisApiProvider);
    final timeline = mockApi.getOperaGameAnalysis();
    ref.read(reviewControllerProvider.notifier).loadTimeline(timeline);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReviewScreen()));
  }

  void _showPgnDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ApexColors.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: ApexColors.electricBlue.withAlpha(40), width: 0.5)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(Icons.cloud_sync_rounded,
                    color: ApexColors.electricBlue, size: 22),
                const SizedBox(width: 10),
                Text('Paste PGN',
                    style: ApexTypography.titleMedium.copyWith(
                        color: ApexColors.textPrimary)),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 8,
                style: ApexTypography.bodyMedium.copyWith(
                    fontFamily: 'JetBrains Mono', fontSize: 12,
                    color: ApexColors.textSecondary),
                decoration: InputDecoration(
                  hintText: '1. e4 e5 2. Nf3 Nc6 ...',
                  hintStyle: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary),
                  filled: true, fillColor: ApexColors.cardSurface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ApexColors.subtleBorder)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ApexColors.subtleBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: ApexColors.electricBlue.withAlpha(100))),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final pgn = controller.text.trim();
                  if (pgn.isEmpty) return;
                  Navigator.of(ctx).pop();
                  _startCloudAnalysis(context, ref, pgn);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ApexColors.electricBlue,
                    foregroundColor: ApexColors.textOnAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('CLOUD ANALYZE',
                    style: ApexTypography.labelLarge.copyWith(
                        color: ApexColors.textOnAccent, letterSpacing: 2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCloudAnalysis(BuildContext context, WidgetRef ref, String pgn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CloudAnalysisProgressDialog(pgn: pgn),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cloud Analysis Progress Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CloudAnalysisProgressDialog extends ConsumerStatefulWidget {
  final String pgn;
  const _CloudAnalysisProgressDialog({required this.pgn});
  @override
  ConsumerState<_CloudAnalysisProgressDialog> createState() =>
      _CloudAnalysisProgressDialogState();
}

class _CloudAnalysisProgressDialogState
    extends ConsumerState<_CloudAnalysisProgressDialog> {
  int _completed = 0;
  int _total = 1;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final analyzer = ref.read(cloudGameAnalyzerProvider);
      final timeline = await analyzer.analyzeFromPgn(widget.pgn,
          onProgress: (completed, total) {
        if (mounted) setState(() { _completed = completed; _total = total; });
      });
      if (mounted) {
        ref.read(reviewControllerProvider.notifier).loadTimeline(timeline);
        setState(() { _done = true; });
      }
    } on CloudAnalysisException catch (e) {
      if (mounted) setState(() { _error = e.userMessage; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AlertDialog(
        backgroundColor: ApexColors.elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: ApexColors.mistake.withAlpha(40))),
        title: Row(children: [
          Icon(Icons.cloud_off_rounded, color: ApexColors.mistake, size: 22),
          const SizedBox(width: 10),
          Text('Cloud Analysis Error',
              style: TextStyle(color: ApexColors.mistake, fontSize: 16)),
        ]),
        content: Text(_error!,
            style: TextStyle(color: ApexColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK',
                  style: TextStyle(color: ApexColors.electricBlue))),
        ],
      );
    }
    if (_done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ReviewScreen()));
      });
    }
    final progress = _total > 0 ? _completed / _total : 0.0;
    return Dialog(
      backgroundColor: ApexColors.elevatedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: ApexColors.electricBlue.withAlpha(40), width: 0.5)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 48, height: 48,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 3, color: ApexColors.electricBlue,
              backgroundColor: ApexColors.subtleBorder)),
          const SizedBox(height: 20),
          Text('Cloud analyzing…',
              style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary)),
          const SizedBox(height: 8),
          Text('$_completed / $_total moves',
              style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.electricBlue,
                  fontFamily: 'JetBrains Mono')),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_rounded,
                color: ApexColors.electricBlue.withAlpha(100), size: 12),
            const SizedBox(width: 4),
            Text('Lichess Cloud Eval + Opening Explorer',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary, fontSize: 10)),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress, minHeight: 4,
              color: ApexColors.electricBlue,
              backgroundColor: ApexColors.subtleBorder)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cyber Button
// ─────────────────────────────────────────────────────────────────────────────

class _CyberButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CyberButton({
    required this.label, required this.icon,
    required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: isPrimary
                    ? ApexColors.electricBlue.withAlpha(20)
                    : ApexColors.cardSurface.withAlpha(180),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPrimary
                      ? ApexColors.electricBlue.withAlpha(80)
                      : ApexColors.subtleBorder,
                  width: 0.8),
                boxShadow: isPrimary ? [
                  BoxShadow(
                    color: ApexColors.electricBlue.withAlpha(15),
                    blurRadius: 20, spreadRadius: -4),
                ] : null),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: isPrimary
                          ? ApexColors.electricBlue
                          : ApexColors.textSecondary,
                      size: 24),
                  const SizedBox(width: 12),
                  Text(label,
                      style: ApexTypography.labelLarge.copyWith(
                        color: isPrimary
                            ? ApexColors.electricBlue
                            : ApexColors.textSecondary,
                        letterSpacing: 2, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
