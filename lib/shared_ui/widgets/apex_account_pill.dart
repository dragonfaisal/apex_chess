/// Compact connected-account identity pill.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class ApexAccountPill extends StatelessWidget {
  const ApexAccountPill({super.key, required this.identity, this.onTap});

  final PlayerIdentityDisplay identity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cached = identity.isCached;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          key: const ValueKey('apex-home-account-pill'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ApexColors.nebula.withValues(alpha: 0.56),
            border: Border.all(
              color:
                  (cached ? ApexColors.inaccuracy : ApexColors.sapphireBright)
                      .withValues(alpha: cached ? 0.30 : 0.34),
              width: 0.75,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                identity.platformLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ApexTypography.bodyMedium.copyWith(
                  color: cached
                      ? ApexColors.textTertiary
                      : ApexColors.sapphireBright,
                  fontSize: 11,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '·',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  identity.displayUsername,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 11,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
