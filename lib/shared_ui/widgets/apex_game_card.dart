/// Shared Apex game-card foundation.
///
/// This widget is intentionally presentation-only: feature screens adapt their
/// own domain objects into [ApexGameCardDisplayModel] and keep engine / review
/// logic out of the shared UI layer.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';
import 'package:apex_chess/shared_ui/widgets/apex_side_marker.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

enum GameResultTone { won, lost, draw, unknown }

extension GameResultToneDisplay on GameResultTone {
  String get label => switch (this) {
    GameResultTone.won => 'Won',
    GameResultTone.lost => 'Lost',
    GameResultTone.draw => 'Draw',
    GameResultTone.unknown => 'Result',
  };

  Color get color => switch (this) {
    GameResultTone.won => ApexColors.emerald,
    GameResultTone.lost => ApexColors.blunder,
    GameResultTone.draw => ApexColors.inaccuracy,
    GameResultTone.unknown => ApexColors.sapphire,
  };
}

enum ApexPlayerSide { white, black }

class ApexGamePlayerDisplay {
  const ApexGamePlayerDisplay({
    required this.side,
    required this.name,
    this.rating,
    this.isUser = false,
    this.avatarUrl,
    this.platform = PlayerIdentityPlatform.unknown,
  });

  final ApexPlayerSide side;
  final String name;
  final String? rating;
  final bool isUser;
  final String? avatarUrl;
  final PlayerIdentityPlatform platform;

  String get sideLabel => switch (side) {
    ApexPlayerSide.white => 'White',
    ApexPlayerSide.black => 'Black',
  };

  PlayerIdentityDisplay get identity => PlayerIdentityDisplay.fromRaw(
    username: name,
    platform: platform,
    rating: rating,
    avatarUrl: avatarUrl,
    isConnectedUser: isUser,
    isOpponent: !isUser,
    side: side == ApexPlayerSide.white
        ? PlayerIdentitySide.white
        : PlayerIdentitySide.black,
  );
}

class ApexGameCardDisplayModel {
  const ApexGameCardDisplayModel({
    required this.resultTone,
    required this.white,
    required this.black,
    this.resultLabel,
    this.primaryMeta,
    this.secondaryMeta,
    this.badges = const [],
  });

  final GameResultTone resultTone;
  final String? resultLabel;
  final ApexGamePlayerDisplay white;
  final ApexGamePlayerDisplay black;
  final String? primaryMeta;
  final String? secondaryMeta;
  final List<String> badges;

  String get resolvedResultLabel => resultLabel ?? resultTone.label;
}

class ApexGameCard extends StatefulWidget {
  const ApexGameCard({
    super.key,
    required this.model,
    this.onTap,
    this.actions = const [],
    this.trailing,
    this.dense = false,
    this.enableHaptic = true,
  });

  final ApexGameCardDisplayModel model;
  final VoidCallback? onTap;
  final List<Widget> actions;
  final Widget? trailing;
  final bool dense;
  final bool enableHaptic;

  @override
  State<ApexGameCard> createState() => _ApexGameCardState();
}

class _ApexGameCardState extends State<ApexGameCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tone = widget.model.resultTone;
    final accent = tone.color;
    final radius = widget.dense ? 14.0 : 16.0;
    final padding = widget.dense
        ? const EdgeInsets.fromLTRB(12, 10, 12, 10)
        : const EdgeInsets.fromLTRB(14, 13, 14, 12);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: ApexMotion.fast,
      curve: ApexMotion.standard,
      child: GlassPanel(
        padding: EdgeInsets.zero,
        margin: null,
        borderRadius: radius,
        accentColor: accent,
        accentAlpha: _pressed ? 0.46 : 0.24,
        fillAlpha: widget.dense ? 0.40 : 0.46,
        showGlow: _pressed,
        glowIntensity: _pressed ? 0.24 : 0.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap == null
                ? null
                : () {
                    if (widget.enableHaptic) HapticFeedback.selectionClick();
                    widget.onTap?.call();
                  },
            onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
            onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
            onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(radius),
            splashColor: accent.withValues(alpha: 0.12),
            highlightColor: accent.withValues(alpha: 0.08),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ApexResultChip(
                        label: widget.model.resolvedResultLabel,
                        tone: tone,
                        active: _pressed,
                      ),
                      const Spacer(),
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
                  SizedBox(height: widget.dense ? 8 : 10),
                  ApexPlayerSideRow(player: widget.model.white),
                  SizedBox(height: widget.dense ? 5 : 6),
                  ApexPlayerSideRow(player: widget.model.black),
                  if (_hasMeta) ...[
                    SizedBox(height: widget.dense ? 8 : 10),
                    if (widget.model.primaryMeta != null)
                      _MetaLine(
                        text: widget.model.primaryMeta!,
                        prominent: true,
                        dense: widget.dense,
                      ),
                    if (widget.model.secondaryMeta != null) ...[
                      const SizedBox(height: 3),
                      _MetaLine(
                        text: widget.model.secondaryMeta!,
                        prominent: false,
                        dense: widget.dense,
                      ),
                    ],
                  ],
                  if (widget.model.badges.isNotEmpty) ...[
                    SizedBox(height: widget.dense ? 8 : 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        for (final badge in widget.model.badges)
                          _ApexCardBadge(label: badge, tone: tone),
                      ],
                    ),
                  ],
                  if (widget.actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < widget.actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: widget.actions[i]),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasMeta =>
      widget.model.primaryMeta != null || widget.model.secondaryMeta != null;
}

class ApexResultChip extends StatelessWidget {
  const ApexResultChip({
    super.key,
    required this.label,
    required this.tone,
    this.active = false,
  });

  final String label;
  final GameResultTone tone;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    return AnimatedContainer(
      duration: ApexMotion.fast,
      curve: ApexMotion.standard,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.52 : 0.32),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: active ? 0.34 : 0.16),
            blurRadius: active ? 16 : 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ApexTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class ApexPlayerSideRow extends StatelessWidget {
  const ApexPlayerSideRow({super.key, required this.player});

  final ApexGamePlayerDisplay player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ApexSideMarker(side: player.side.markerSide, showLabel: true),
        const SizedBox(width: 8),
        ApexPlayerAvatar(
          identity: player.identity,
          size: ApexPlayerAvatarSize.small,
          showConnectedBadge: player.isUser,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            player.name.trim().isEmpty ? 'Unknown' : player.name.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 13,
              fontWeight: player.isUser ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        if (player.rating != null && player.rating!.trim().isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            player.rating!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.monoEval.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (player.isUser) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ApexColors.sapphire.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: ApexColors.sapphireBright.withValues(alpha: 0.24),
                width: 0.5,
              ),
            ),
            child: Text(
              'YOU',
              style: ApexTypography.labelLarge.copyWith(
                color: ApexColors.sapphireBright,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

extension on ApexPlayerSide {
  ApexSideMarkerSide get markerSide => switch (this) {
    ApexPlayerSide.white => ApexSideMarkerSide.white,
    ApexPlayerSide.black => ApexSideMarkerSide.black,
  };
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.text,
    required this.prominent,
    required this.dense,
  });

  final String text;
  final bool prominent;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: dense ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: ApexTypography.bodyMedium.copyWith(
        color: prominent ? ApexColors.textSecondary : ApexColors.textTertiary,
        fontSize: prominent ? 11.5 : 10.7,
        fontWeight: prominent ? FontWeight.w700 : FontWeight.w600,
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _ApexCardBadge extends StatelessWidget {
  const _ApexCardBadge({required this.label, required this.tone});

  final String label;
  final GameResultTone tone;

  @override
  Widget build(BuildContext context) {
    final lower = label.toLowerCase();
    final color = lower.contains(ApexCopy.brilliantLabel.toLowerCase())
        ? ApexColors.brilliant
        : lower.contains('great')
        ? ApexColors.sapphireBright
        : lower.contains('blunder')
        ? ApexColors.blunder
        : lower.contains('miss')
        ? ApexColors.miss
        : tone.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24), width: 0.5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ApexTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
