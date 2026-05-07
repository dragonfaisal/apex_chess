/// Shared compact platform badge for player identity surfaces.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

@immutable
class ApexPlatformBadgeDisplay {
  const ApexPlatformBadgeDisplay({
    required this.platform,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.accent,
  });

  factory ApexPlatformBadgeDisplay.fromPlatform(
    PlayerIdentityPlatform platform,
  ) {
    return switch (platform) {
      PlayerIdentityPlatform.chessCom => const ApexPlatformBadgeDisplay(
        platform: PlayerIdentityPlatform.chessCom,
        label: 'Chess.com',
        shortLabel: 'Chess.com',
        icon: Icons.language_rounded,
        accent: ApexColors.sapphireBright,
      ),
      PlayerIdentityPlatform.lichess => const ApexPlatformBadgeDisplay(
        platform: PlayerIdentityPlatform.lichess,
        label: 'Lichess',
        shortLabel: 'Lichess',
        icon: Icons.bolt_rounded,
        accent: ApexColors.aurora,
      ),
      PlayerIdentityPlatform.pgn => const ApexPlatformBadgeDisplay(
        platform: PlayerIdentityPlatform.pgn,
        label: 'PGN',
        shortLabel: 'PGN',
        icon: Icons.description_rounded,
        accent: ApexColors.textSecondary,
      ),
      PlayerIdentityPlatform.unknown => const ApexPlatformBadgeDisplay(
        platform: PlayerIdentityPlatform.unknown,
        label: 'Unknown',
        shortLabel: 'Profile',
        icon: Icons.person_rounded,
        accent: ApexColors.textTertiary,
      ),
    };
  }

  final PlayerIdentityPlatform platform;
  final String label;
  final String shortLabel;
  final IconData icon;
  final Color accent;
}

class ApexPlatformBadge extends StatelessWidget {
  const ApexPlatformBadge({
    super.key,
    required this.platform,
    this.compact = false,
    this.selected = false,
  });

  final PlayerIdentityPlatform platform;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final display = ApexPlatformBadgeDisplay.fromPlatform(platform);
    final accent = selected ? ApexColors.sapphireBright : display.accent;
    return Semantics(
      label: display.label,
      child: Container(
        key: ValueKey('apex-platform-${platform.name}-badge'),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: selected ? 0.18 : 0.11),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: accent.withValues(alpha: selected ? 0.48 : 0.30),
            width: 0.65,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              display.icon,
              size: compact ? 11 : 12.5,
              color: accent.withValues(alpha: selected ? 1 : 0.90),
            ),
            SizedBox(width: compact ? 4 : 5),
            Text(
              compact ? display.shortLabel : display.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: accent,
                fontSize: compact ? 9.5 : 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData iconFor(PlayerIdentityPlatform platform) {
    return ApexPlatformBadgeDisplay.fromPlatform(platform).icon;
  }
}
