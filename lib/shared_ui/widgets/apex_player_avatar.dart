/// Shared Apex player avatar.
///
/// This widget is display-only: it uses a public avatar URL when already
/// present in the caller's data and otherwise renders a deterministic Apex
/// fallback. It does not fetch profile data or create identity state.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_platform_badge.dart';

enum ApexPlayerAvatarSize {
  small(26),
  medium(40),
  large(64);

  const ApexPlayerAvatarSize(this.dimension);

  final double dimension;
}

class ApexPlayerAvatar extends StatelessWidget {
  const ApexPlayerAvatar({
    super.key,
    required this.identity,
    this.size = ApexPlayerAvatarSize.medium,
    this.showPlatformBadge = false,
    this.showConnectedBadge = false,
  });

  final PlayerIdentityDisplay identity;
  final ApexPlayerAvatarSize size;
  final bool showPlatformBadge;
  final bool showConnectedBadge;

  @override
  Widget build(BuildContext context) {
    final dimension = size.dimension;
    final avatar = Semantics(
      label: '${identity.displayUsername} avatar',
      image: true,
      child: Container(
        width: dimension,
        height: dimension,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _fallbackGradient(identity),
          border: Border.all(
            color: identity.isConnectedUser
                ? ApexColors.sapphireBright.withValues(alpha: 0.72)
                : ApexColors.stardustLine.withValues(alpha: 0.56),
            width: size == ApexPlayerAvatarSize.large ? 1.1 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: _accent(identity).withValues(alpha: 0.20),
              blurRadius: dimension * 0.36,
              spreadRadius: -dimension * 0.16,
            ),
          ],
        ),
        child: identity.avatarUrl == null
            ? _FallbackInitial(identity: identity, size: size)
            : Image.network(
                identity.avatarUrl!,
                key: ValueKey(
                  'apex-avatar-network-${identity.normalizedUsername}',
                ),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _FallbackInitial(identity: identity, size: size),
              ),
      ),
    );

    if (!showPlatformBadge && !showConnectedBadge) return avatar;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: avatar),
          Positioned(
            right: -1,
            bottom: -1,
            child: _AvatarBadge(
              identity: identity,
              showConnectedBadge: showConnectedBadge,
              avatarSize: size,
            ),
          ),
        ],
      ),
    );
  }

  static LinearGradient _fallbackGradient(PlayerIdentityDisplay identity) {
    final accent = _accent(identity);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withValues(alpha: 0.78),
        ApexColors.nebula.withValues(alpha: 0.88),
        ApexColors.deepSpace,
      ],
      stops: const [0, 0.58, 1],
    );
  }

  static Color _accent(PlayerIdentityDisplay identity) {
    if (identity.isConnectedUser) return ApexColors.sapphireBright;
    return switch (identity.side) {
      PlayerIdentitySide.white => ApexColors.textPrimary,
      PlayerIdentitySide.black => ApexColors.sapphire,
      PlayerIdentitySide.unknown => _seededAccent(identity.fallbackColorSeed),
    };
  }

  static Color _seededAccent(int seed) {
    const accents = [
      ApexColors.sapphireBright,
      ApexColors.electricBlue,
      ApexColors.aurora,
      ApexColors.brilliant,
      ApexColors.textSecondary,
    ];
    return accents[seed.abs() % accents.length];
  }
}

class _FallbackInitial extends StatelessWidget {
  const _FallbackInitial({required this.identity, required this.size});

  final PlayerIdentityDisplay identity;
  final ApexPlayerAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final dimension = size.dimension;
    return Center(
      child: Text(
        identity.fallbackInitial,
        key: ValueKey('apex-avatar-fallback-${identity.normalizedUsername}'),
        maxLines: 1,
        style: ApexTypography.labelLarge.copyWith(
          color: ApexColors.textPrimary,
          fontSize: dimension * 0.40,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.identity,
    required this.showConnectedBadge,
    required this.avatarSize,
  });

  final PlayerIdentityDisplay identity;
  final bool showConnectedBadge;
  final ApexPlayerAvatarSize avatarSize;

  @override
  Widget build(BuildContext context) {
    final size = avatarSize == ApexPlayerAvatarSize.large ? 18.0 : 13.0;
    final color = showConnectedBadge || identity.isConnectedUser
        ? ApexColors.emeraldBright
        : ApexColors.sapphireBright;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ApexColors.trueBlack.withValues(alpha: 0.92),
        border: Border.all(color: color.withValues(alpha: 0.82), width: 0.8),
      ),
      child: Icon(
        showConnectedBadge || identity.isConnectedUser
            ? Icons.check_rounded
            : ApexPlatformBadge.iconFor(identity.platform),
        color: color,
        size: size * 0.66,
      ),
    );
  }
}
