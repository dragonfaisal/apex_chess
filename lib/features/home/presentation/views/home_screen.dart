/// Home Screen — Apex Chess "Deep Space Cinematic" edition.
///
/// Main Apex shell with Analyze / Archive / Stats / Academy navigation.
///
/// Layout is wrapped in a [SingleChildScrollView] so the content never
/// overflows on compact screens (previously caused the
/// "RenderFlex overflowed by 67 pixels" warning at this screen).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/account/presentation/views/connect_account_screen.dart';
import 'package:apex_chess/features/apex_academy/presentation/views/apex_academy_screen.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/features/global_dashboard/presentation/views/global_dashboard_screen.dart';
import 'package:apex_chess/features/import_match/presentation/views/import_match_screen.dart';
import 'package:apex_chess/features/live_play/presentation/views/live_play_screen.dart';
import 'package:apex_chess/features/mistake_vault/data/mistake_vault_save_hook.dart';
import 'package:apex_chess/features/home/presentation/pgn_paste_display_state.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/features/profile/presentation/views/profile_screen.dart';
import 'package:apex_chess/features/profile_scanner/presentation/views/profile_scanner_screen.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountControllerProvider).valueOrNull;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _AnalyzeTab(
            account: account,
            onPastePgn: () => _showPgnDialog(context, ref, account?.username),
          ),
          const ArchiveScreen(showBackButton: false),
          const GlobalDashboardScreen(showBackButton: false),
          const ApexAcademyScreen(showBackButton: false),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph_rounded),
            label: 'Analyze',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Archive',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Academy',
          ),
        ],
      ),
    );
  }

  void _showPgnDialog(
    BuildContext context,
    WidgetRef ref,
    String? connectedHandle,
  ) async {
    final result = await showDialog<_PgnPasteResult>(
      context: context,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => _PgnPasteDialog(connectedHandle: connectedHandle),
    );
    if (result == null) return;
    if (!context.mounted) return;
    _startLocalAnalysis(context, ref, result);
  }

  void _startLocalAnalysis(
    BuildContext context,
    WidgetRef ref,
    _PgnPasteResult result,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => _LocalAnalysisProgressDialog(
        pgn: result.pgn,
        profile: result.profile,
        userIsWhite: result.userIsWhite,
        userHandle: result.userHandle,
      ),
    );
  }
}

class _AnalyzeTab extends StatelessWidget {
  const _AnalyzeTab({required this.account, required this.onPastePgn});

  final ApexAccount? account;
  final VoidCallback onPastePgn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      _AccountStrip(account: account),
                      const SizedBox(height: 22),
                      Text(
                        ApexCopy.appTitle,
                        textAlign: TextAlign.center,
                        style: ApexTypography.displayLarge.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ApexCopy.tagline,
                        textAlign: TextAlign.center,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.sapphireBright.withValues(
                            alpha: 0.72,
                          ),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _HeroPlayCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LivePlayScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _HomeTileGrid(
                        children: [
                          _TileCard(
                            title: 'Import Games',
                            subtitle: 'Chess.com · Lichess',
                            icon: Icons.cloud_download_rounded,
                            accent: ApexColors.sapphire,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ImportMatchScreen(),
                              ),
                            ),
                          ),
                          _TileCard(
                            title: 'Paste PGN',
                            subtitle: 'Detected preview · review',
                            icon: Icons.auto_graph_rounded,
                            accent: ApexColors.aurora,
                            onTap: onPastePgn,
                          ),
                          _TileCard(
                            title: 'Opponent Insights',
                            subtitle: 'Profile review',
                            icon: Icons.person_search_rounded,
                            accent: ApexColors.ruby,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScannerScreen(),
                              ),
                            ),
                          ),
                          _TileCard(
                            title: 'Live',
                            subtitle: 'Play · feedback · review',
                            icon: Icons.play_arrow_rounded,
                            accent: ApexColors.emerald,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LivePlayScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        ApexCopy.liveEngineFooter,
                        textAlign: TextAlign.center,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Result of the PGN paste dialog — captures the text, user-side
/// preference, and analysis depth so the progress dialog + archive
/// record know what the user asked for.
///
/// Phase A audit § 3: the original dialog had a single "Run Scan" CTA
/// with no colour or mode input, which forced every PGN paste to run
/// through the default D14 analyzer with `userIsWhite = null`. That
/// produced misleading archives where White-as-user and Black-as-user
/// games were indistinguishable, and Quick scans silently claimed
/// Brilliants.
class _PgnPasteResult {
  const _PgnPasteResult({
    required this.pgn,
    required this.profile,
    required this.userIsWhite,
    required this.userHandle,
  });
  final String pgn;
  final AnalysisProfile profile;

  /// `true` → user played White, `false` → Black, `null` → unknown
  /// (ingest both sides' mistakes into the Vault; no board auto-flip).
  final bool? userIsWhite;

  /// Optional handle the user typed. Not wired into the archive
  /// metadata yet, but threaded down so future enhancements can plug
  /// into it without reshaping the dialog API.
  final String? userHandle;
}

/// PGN paste dialog with side selector, optional handle, and split
/// Quick / Deep analyse buttons. See [_PgnPasteResult] for why each
/// field is needed.
class _PgnPasteDialog extends StatefulWidget {
  const _PgnPasteDialog({this.connectedHandle});

  final String? connectedHandle;

  @override
  State<_PgnPasteDialog> createState() => _PgnPasteDialogState();
}

class _PgnPasteDialogState extends State<_PgnPasteDialog> {
  static const _identity = GameIdentityService();
  final _pgnController = TextEditingController();
  final _handleController = TextEditingController();
  final _pgnFocusNode = FocusNode();
  Timer? _pgnParseDebounce;
  // `null` == "unknown" — the default preserves the legacy PGN-paste
  // behaviour (both sides' mistakes ingested, no board flip).
  bool? _userIsWhite;
  bool _sideTouched = false;
  bool _pgnCollapsed = false;

  @override
  void dispose() {
    _pgnParseDebounce?.cancel();
    _pgnFocusNode.dispose();
    _pgnController.dispose();
    _handleController.dispose();
    super.dispose();
  }

  void _pop(AnalysisProfile profile) {
    final pgn = _pgnController.text.trim();
    if (pgn.isEmpty) return;
    final typedHandle = _handleController.text.trim();
    final handle = typedHandle.isEmpty ? widget.connectedHandle : typedHandle;
    Navigator.of(context).pop(
      _PgnPasteResult(
        pgn: pgn,
        profile: profile,
        userIsWhite: _effectiveUserIsWhite,
        userHandle: (handle?.trim().isEmpty ?? true) ? null : handle,
      ),
    );
  }

  bool? get _effectiveUserIsWhite {
    if (_sideTouched) return _userIsWhite;
    return _currentPreview.userIsWhite;
  }

  PgnGameIdentity get _currentPreview {
    final handle = _handleController.text.trim().isEmpty
        ? widget.connectedHandle
        : _handleController.text.trim();
    return _identity.parsePgn(
      _pgnController.text,
      userHandle: handle,
      selectedUserIsWhite: _userIsWhite,
    );
  }

  bool get _hasDetectedGame => PgnPasteDisplayState.shouldCollapseInput(
    pgn: _pgnController.text,
    identity: _currentPreview,
  );

  void _onPgnChanged(String value) {
    _pgnParseDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _pgnCollapsed = false);
      return;
    }
    setState(() {});
    _pgnParseDebounce = Timer(PgnPasteDisplayState.parseDebounce, () {
      if (!mounted) return;
      final shouldCollapse = PgnPasteDisplayState.shouldCollapseInput(
        pgn: _pgnController.text,
        identity: _currentPreview,
      );
      if (_pgnCollapsed == shouldCollapse) return;
      setState(() => _pgnCollapsed = shouldCollapse);
    });
  }

  void _expandPgnInput() {
    if (!_pgnCollapsed) return;
    setState(() => _pgnCollapsed = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final screen = MediaQuery.sizeOf(context);
    final preview = _currentPreview;
    final selectedSide = _sideTouched ? _userIsWhite : preview.userIsWhite;
    return AnimatedPadding(
      duration: ApexMotion.normal,
      curve: ApexMotion.standard,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screen.height - viewInsets.bottom - 48,
          ),
          child: GlassPanel.dialog(
            accentColor: ApexColors.sapphire,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: ApexSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_graph_rounded,
                        color: ApexColors.sapphire,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        ApexCopy.pgnDialogTitle,
                        style: ApexTypography.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AnimatedSize(
                    duration: ApexMotion.normal,
                    curve: ApexMotion.standard,
                    alignment: Alignment.topCenter,
                    child: TextField(
                      key: ValueKey(_pgnCollapsed),
                      controller: _pgnController,
                      focusNode: _pgnFocusNode,
                      minLines: _pgnCollapsed ? 3 : 5,
                      maxLines: _pgnCollapsed ? 4 : 8,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      cursorColor: ApexColors.sapphireBright,
                      autofillHints: const [],
                      enableSuggestions: false,
                      autocorrect: false,
                      onTap: _expandPgnInput,
                      style: ApexTypography.bodyMedium.copyWith(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        color: ApexColors.textPrimary,
                      ),
                      decoration: _dialogField(
                        hint: _pgnCollapsed
                            ? 'PGN detected. Tap to edit.'
                            : ApexCopy.pgnDialogHint,
                      ),
                      onChanged: _onPgnChanged,
                    ),
                  ),
                  if (widget.connectedHandle == null) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _handleController,
                      cursorColor: ApexColors.sapphireBright,
                      autofillHints: const [],
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      style: ApexTypography.bodyMedium.copyWith(
                        fontSize: 12,
                        color: ApexColors.textPrimary,
                      ),
                      decoration: _dialogField(
                        hint: 'Player name for side detection',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _PgnPreview(identity: preview, detected: _hasDetectedGame),
                  const SizedBox(height: 12),
                  _PerspectiveSelector(
                    value: selectedSide,
                    autoDetected: !_sideTouched && preview.userIsWhite != null,
                    onChanged: (v) => setState(() {
                      _sideTouched = true;
                      _userIsWhite = v;
                    }),
                    onSwitch: selectedSide == null
                        ? null
                        : () => setState(() {
                            _sideTouched = true;
                            _userIsWhite = !selectedSide;
                          }),
                  ),
                  const SizedBox(height: 16),
                  _ReviewModeButtons(onSelected: _pop),
                  const SizedBox(height: 8),
                  Text(
                    'Offline Review runs on this device and may be slower.',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 10,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dialogField({required String hint}) => InputDecoration(
    hintText: hint,
    hintStyle: ApexTypography.bodyMedium.copyWith(
      color: ApexColors.textTertiary,
    ),
    filled: true,
    fillColor: ApexColors.deepSpace.withValues(alpha: 0.55),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ApexColors.subtleBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ApexColors.subtleBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: ApexColors.sapphire.withValues(alpha: 0.55),
      ),
    ),
  );
}

class _PgnPreview extends StatelessWidget {
  const _PgnPreview({required this.identity, required this.detected});

  final PgnGameIdentity identity;
  final bool detected;

  @override
  Widget build(BuildContext context) {
    final opening = identity.opening ?? identity.eco ?? 'Opening not detected';
    final result = const GameIdentityService().resultLabel(
      identity.result,
      userIsWhite: identity.userIsWhite,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                detected
                    ? Icons.check_circle_rounded
                    : Icons.manage_search_rounded,
                size: 15,
                color: detected ? ApexColors.best : ApexColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                detected ? 'Detected Game Preview' : 'Paste a PGN to preview',
                style: ApexTypography.labelLarge.copyWith(
                  color: detected ? ApexColors.best : ApexColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PreviewPlayerCard(
                  label: 'White',
                  name: identity.white,
                  rating: identity.whiteRating,
                  isUser: identity.userIsWhite == true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PreviewPlayerCard(
                  label: 'Black',
                  name: identity.black,
                  rating: identity.blackRating,
                  isUser: identity.userIsWhite == false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewMetaRow(
            icon: Icons.flag_rounded,
            label: result,
            color: identity.userIsWhite == null
                ? ApexColors.textSecondary
                : ApexColors.sapphireBright,
          ),
          const SizedBox(height: 6),
          _PreviewMetaRow(
            icon: Icons.menu_book_rounded,
            label: opening,
            color: ApexColors.book,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _SmallPreviewFact(
                icon: Icons.format_list_numbered_rounded,
                label: '${identity.moveCount} moves',
              ),
              if (identity.date != null)
                _SmallPreviewFact(
                  icon: Icons.calendar_today_rounded,
                  label: identity.date!,
                ),
              if (identity.timeControl != null)
                _SmallPreviewFact(
                  icon: Icons.timer_outlined,
                  label: identity.timeControl!,
                ),
            ],
          ),
          if (identity.userIsWhite != null) ...[
            const SizedBox(height: 8),
            Text(
              'Detected perspective: You: ${identity.userIsWhite! ? 'White' : 'Black'}',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.sapphireBright,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewPlayerCard extends StatelessWidget {
  const _PreviewPlayerCard({
    required this.label,
    required this.name,
    required this.rating,
    required this.isUser,
  });

  final String label;
  final String name;
  final String? rating;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUser
            ? ApexColors.sapphire.withValues(alpha: 0.16)
            : ApexColors.deepSpace.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUser
              ? ApexColors.sapphire.withValues(alpha: 0.46)
              : ApexColors.subtleBorder,
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              if (isUser) ...[
                const Spacer(),
                Text(
                  'YOU',
                  style: ApexTypography.labelLarge.copyWith(
                    color: ApexColors.sapphireBright,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 13,
            ),
          ),
          if (rating != null) ...[
            const SizedBox(height: 2),
            Text(
              rating!,
              style: ApexTypography.monoEval.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewMetaRow extends StatelessWidget {
  const _PreviewMetaRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.bodyMedium.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallPreviewFact extends StatelessWidget {
  const _SmallPreviewFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: ApexColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PerspectiveSelector extends StatelessWidget {
  const _PerspectiveSelector({
    required this.value,
    required this.autoDetected,
    required this.onChanged,
    this.onSwitch,
  });

  final bool? value;
  final bool autoDetected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final title = value == null
        ? 'Choose your side'
        : autoDetected
        ? 'Side detected'
        : 'You: ${value! ? 'White' : 'Black'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ),
            if (onSwitch != null)
              TextButton.icon(
                onPressed: onSwitch,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Switch Side'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _SideChip(
                label: 'White',
                selected: value == true,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SideChip(
                label: 'Black',
                selected: value == false,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewModeButtons extends StatelessWidget {
  const _ReviewModeButtons({required this.onSelected});

  final ValueChanged<AnalysisProfile> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DialogPrimaryAction(
          label: 'Fast Review',
          icon: Icons.flash_on_rounded,
          onTap: () => onSelected(AnalysisProfile.fastReview),
        ),
        const SizedBox(height: 10),
        _DialogPrimaryAction(
          label: 'Deep Review',
          icon: Icons.auto_awesome_rounded,
          onTap: () => onSelected(AnalysisProfile.deepReview),
        ),
        const SizedBox(height: 10),
        _DialogPrimaryAction(
          label: 'Offline Review',
          icon: Icons.offline_bolt_rounded,
          onTap: () => onSelected(AnalysisProfile.offlineReview),
        ),
      ],
    );
  }
}

class _SideChip extends StatelessWidget {
  const _SideChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Phase 20.1 device feedback § 7: explicit splash/highlight colours
    // so Material's default ripple (yellow on Android) doesn't bleed
    // through the dark theme as a white/yellow flash on tap.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: ApexColors.sapphire.withValues(alpha: 0.18),
        highlightColor: ApexColors.sapphire.withValues(alpha: 0.10),
        hoverColor: ApexColors.sapphire.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? ApexColors.sapphire.withValues(alpha: 0.22)
                : ApexColors.elevatedSurface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? ApexColors.sapphire.withValues(alpha: 0.55)
                  : ApexColors.subtleBorder,
              width: 0.6,
            ),
          ),
          child: Text(
            label,
            style: ApexTypography.labelLarge.copyWith(
              color: selected
                  ? ApexColors.textPrimary
                  : ApexColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogPrimaryAction extends StatelessWidget {
  const _DialogPrimaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: ApexGradients.sapphire,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: ApexColors.textPrimary, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: ApexTypography.labelLarge.copyWith(
                    color: ApexColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard tiles — fixed two-column entries, each with its own accent theme.
// ─────────────────────────────────────────────────────────────────────────────

class _HeroPlayCard extends StatelessWidget {
  const _HeroPlayCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 128,
          decoration: BoxDecoration(
            gradient: ApexGradients.sapphireRuby,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: ApexColors.sapphire.withValues(alpha: 0.35),
                blurRadius: 32,
                spreadRadius: -8,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ApexCopy.playLive,
                      style: ApexTypography.displayLarge.copyWith(
                        fontSize: 22,
                        letterSpacing: 1.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Play · feedback · review',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTileGrid extends StatelessWidget {
  const _HomeTileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: tileWidth, height: 132, child: child),
          ],
        );
      },
    );
  }
}

class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      margin: null,
      borderRadius: 16,
      accentColor: accent,
      accentAlpha: 0.32,
      fillAlpha: 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: SizedBox(
              height: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.labelLarge.copyWith(
                          color: ApexColors.textPrimary,
                          letterSpacing: 1.1,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textTertiary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PGN review progress dialog — backed by LocalGameAnalyzer.
// ─────────────────────────────────────────────────────────────────────────────

class _LocalAnalysisProgressDialog extends ConsumerStatefulWidget {
  const _LocalAnalysisProgressDialog({
    required this.pgn,
    required this.profile,
    this.userIsWhite,
    this.userHandle,
  });
  final String pgn;
  final AnalysisProfile profile;

  /// `true` → user played White, `false` → Black, `null` → unknown.
  /// When non-null the review board auto-flips for Black users and the
  /// Mistake Vault hook only ingests that colour's plies.
  final bool? userIsWhite;

  /// Optional handle the user typed on the paste dialog. Reserved for
  /// future archive-metadata enhancements; currently unused by this
  /// dialog.
  final String? userHandle;

  @override
  ConsumerState<_LocalAnalysisProgressDialog> createState() =>
      _LocalAnalysisProgressDialogState();
}

class _LocalAnalysisProgressDialogState
    extends ConsumerState<_LocalAnalysisProgressDialog> {
  int _completed = 0;
  int _total = 1;
  bool _done = false;
  // Guards the post-frame navigation callback so it is enqueued at most once,
  // even if build() runs multiple times before the callback fires. Without
  // this, an ancestor rebuild between `_done = true` and the next frame would
  // queue a second pop→push pair and tear down the freshly-pushed review.
  bool _navigated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final pipeline = await ref.read(reviewAnalysisPipelineProvider.future);
      final result = await pipeline.analyzeGame(
        GameReviewRequest(
          pgn: widget.pgn,
          profile: widget.profile,
          userIsWhite: widget.userIsWhite,
          userHandle: widget.userHandle,
          onProgress: (c, t) {
            if (mounted) {
              setState(() {
                _completed = c;
                _total = t;
              });
            }
          },
        ),
      );
      final timeline = result.timeline;
      final mode = widget.profile.id == AnalysisProfileId.fastReview
          ? AnalysisMode.quick
          : AnalysisMode.deep;
      final depth = result.metadata.depth;
      if (mounted) {
        ref
            .read(reviewControllerProvider.notifier)
            .loadTimeline(
              timeline,
              // Auto-flip the board if the user told us they played
              // Black. Unknown-side PGNs keep White at the bottom.
              userIsBlack: widget.userIsWhite == false,
              // Phase 20.1: thread the analysis mode and the user's
              // colour so the coach card can attribute "Allowed
              // forced mate" correctly and surface the "Needs Deep
              // Scan" chip on Quick-mode ambiguous plies.
              mode: mode,
              userIsWhite: widget.userIsWhite,
            );
        // Archive save is awaited so we have the id to hand the
        // Mistake Vault hook; both are still best-effort and never
        // block the review flow on failure.
        final archiveId = await saveAnalysisToArchive(
          ref: ref,
          timeline: timeline,
          pgn: widget.pgn,
          depth: depth,
          source: ArchiveSource.pgn,
          analysisMode: mode,
        );
        if (archiveId != null) {
          unawaited(
            saveMistakeDrillsFromTimeline(
              ref: ref,
              timeline: timeline,
              archiveId: archiveId,
              // When the user specified a colour on the paste dialog, only
              // that side's mistakes flow into the Vault. Unknown-side
              // paste keeps the legacy both-sides behaviour.
              userIsWhite: widget.userIsWhite,
            ),
          );
        }
        if (!mounted) return;
        setState(() => _done = true);
      }
    } on LocalAnalysisException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } catch (e) {
      if (mounted) setState(() => _error = ApexCopy.analysisFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop();
        // Phase 20.1 § 3: land on the ReviewSummaryScreen first so the
        // user gets accuracy + counts + phase breakdown + CTAs before
        // jumping into move-by-move review. The summary screen's
        // "Review Moves" CTA pushes ReviewScreen itself.
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ReviewSummaryScreen()));
      });
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassPanel.dialog(
        accentColor: _error == null ? ApexColors.sapphire : ApexColors.ruby,
        child: _error != null ? _errorContent() : _progressContent(),
      ),
    );
  }

  Widget _progressContent() {
    final progress = _total > 0 ? _completed / _total : 0.0;
    return ApexLoadingScaffold(
      title: widget.profile.label,
      messages: const [
        'Reading PGN...',
        'Checking opening...',
        'Building review...',
        'Analyzing tactics...',
        'Saving review...',
      ],
      progress: progress,
      progressMessage: '$_completed / $_total plies analyzed',
      compact: true,
    );
  }

  Widget _errorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline_rounded, color: ApexColors.ruby, size: 22),
            const SizedBox(width: 10),
            Text(
              'Review Error',
              style: ApexTypography.titleMedium.copyWith(
                color: ApexColors.ruby,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_error!, style: ApexTypography.bodyLarge),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: ApexColors.sapphire)),
          ),
        ),
      ],
    );
  }
}

// ── Account strip (top of home) ─────────────────────────────────────────
//
// Connected state: shows the source label + handle next to a "Switch
// account" text button that re-opens onboarding.
// Disconnected state: compact "Connect account" CTA that opens the
// same onboarding screen.

class _AccountStrip extends ConsumerWidget {
  const _AccountStrip({required this.account});
  final ApexAccount? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (account == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: ApexColors.emerald,
            side: BorderSide(
              color: ApexColors.emerald.withValues(alpha: 0.55),
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          // Pop back to home once the connect / skip resolves so the
          // user doesn't get stuck on the connect screen with no
          // forward navigation. ConnectAccountScreen.onComplete is the
          // sole signal it watches before doing anything navigation-y.
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (innerCtx) => ConnectAccountScreen(
                onComplete: () => Navigator.of(innerCtx).pop(),
              ),
            ),
          ),
          icon: const Icon(Icons.link_rounded, size: 16),
          label: const Text('CONNECT ACCOUNT'),
        ),
      );
    }
    return Row(
      children: [
        // Verified-handle chip — also tappable as a quick portal to the
        // dedicated Profile screen (live ratings + logout cascade).
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ApexColors.emerald.withValues(alpha: 0.12),
                border: Border.all(
                  color: ApexColors.emerald.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: ApexColors.emeraldBright,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${account!.source.wire.toUpperCase()} · ${account!.username}',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textPrimary,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
          ),
          icon: const Icon(
            Icons.account_circle_outlined,
            size: 22,
            color: ApexColors.sapphireBright,
          ),
        ),
      ],
    );
  }
}
