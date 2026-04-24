/// Apex Chess — "Deep Space Cinematic" Design System
///
/// The visual language is built around three ideas:
///
///   * **Deep space canvas** — cool, almost-black blues for backgrounds so
///     accent colours read as light sources rather than decoration.
///   * **Sapphire → Ruby accent spectrum** — primary actions glow in sapphire;
///     destructive / warning states shift warmer through ruby.
///   * **Glass materials** — elevated surfaces use [BackdropFilter] blur with
///     subtle gradient borders (see [GlassPanel]).
///
/// Legacy identifiers from the previous "Quiet Power" theme are kept as
/// aliases so existing feature code keeps compiling; new work should prefer
/// the [ApexColors.sapphire] / [ApexColors.ruby] palette.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

class ApexColors {
  ApexColors._();

  // ── Deep-space background spectrum ─────────────────────────────────────
  /// The void behind everything — used for scaffold background on hero screens.
  static const Color spaceVoid       = Color(0xFF050814);
  /// Standard surface — dashboards, list screens.
  static const Color deepSpace       = Color(0xFF0A1024);
  /// Slightly lifted — app-bar, persistent chrome.
  static const Color nebula          = Color(0xFF121A38);
  /// Dialog / modal background under the glass blur.
  static const Color cosmicDust      = Color(0xFF1A2448);
  /// Subtle separators inside glass panels.
  static const Color stardustLine    = Color(0x33A0B6FF);

  // ── Sapphire accent (primary) ──────────────────────────────────────────
  static const Color sapphire        = Color(0xFF4DA6FF);
  static const Color sapphireBright  = Color(0xFF7CC4FF);
  static const Color sapphireDeep    = Color(0xFF1D5FD2);
  static const Color sapphireGlow    = Color(0xFFB8DEFF);

  // ── Ruby accent (danger / highlight) ───────────────────────────────────
  static const Color ruby            = Color(0xFFFF4D7A);
  static const Color rubyBright      = Color(0xFFFF7FA2);
  static const Color rubyDeep        = Color(0xFFC01F4E);

  // ── Aurora accent (brilliant moments, victory) ─────────────────────────
  static const Color aurora          = Color(0xFF00F0FF);
  static const Color auroraSoft      = Color(0xFF7BFFFF);

  // ── Emerald / Neon accent (Phase 4 VFX — Quantum Shatter, Great-Move aura) ─
  /// Vibrant emerald used for the shatter-loader core and "Best Move" aura.
  static const Color emerald         = Color(0xFF10F0A5);
  /// Lighter rim used for shard highlights and XP ring fills.
  static const Color emeraldBright   = Color(0xFF7BFFD0);
  /// Deep emerald for gradient bases.
  static const Color emeraldDeep     = Color(0xFF0A8A5F);
  /// Electric neon used for crackling arcs + Great-Move aura.
  static const Color electricNeon    = Color(0xFF3FA0FF);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary     = Color(0xFFF4F7FF);
  static const Color textSecondary   = Color(0xFFB4C0E0);
  static const Color textTertiary    = Color(0xFF7A87B0);
  static const Color textOnAccent    = Color(0xFF050814);

  // ── Move-quality semantic colours ──────────────────────────────────────
  static const Color brilliant       = aurora;                // !!
  static const Color best            = sapphire;              // ★
  static const Color great           = Color(0xFF4DE98B);     // !
  static const Color inaccuracy      = Color(0xFFFFC857);     // ?!
  static const Color mistake         = Color(0xFFFF8C3A);     // ?
  static const Color blunder         = ruby;                  // ??
  static const Color book            = Color(0xFFB98CFF);     // book

  // ── Legacy aliases (old "Quiet Power" names) ───────────────────────────
  // These map the previous charcoal + cyan identifiers onto the new palette
  // so existing widgets keep rendering without a simultaneous rewrite.
  static const Color trueBlack       = spaceVoid;
  static const Color darkSurface     = deepSpace;
  static const Color elevatedSurface = nebula;
  static const Color cardSurface     = cosmicDust;
  static const Color subtleBorder    = Color(0xFF243058);

  static const Color electricBlue    = sapphire;
  static const Color brightCyan      = sapphireBright;
  static const Color mutedCyan       = sapphireDeep;
  static const Color deepCyan        = Color(0xFF0C3A80);
  static const Color cyanGlow        = sapphireGlow;

  static const Color royalGold       = sapphire;
  static const Color brightGold      = sapphireBright;
  static const Color mutedGold       = sapphireDeep;
  static const Color deepGold        = deepCyan;
  static const Color goldShimmer     = sapphireGlow;
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradients
// ─────────────────────────────────────────────────────────────────────────────

class ApexGradients {
  ApexGradients._();

  /// Sapphire primary action gradient (buttons, CTAs).
  static const LinearGradient sapphire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ApexColors.sapphireBright, ApexColors.sapphireDeep],
  );

  /// Sapphire → Ruby — hero moments, premium touches.
  static const LinearGradient sapphireRuby = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ApexColors.sapphire, ApexColors.ruby],
  );

  /// Brilliant move glow — aurora → sapphire.
  static const LinearGradient brilliant = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ApexColors.aurora, ApexColors.sapphireBright],
  );

  /// Ruby warning / blunder.
  static const LinearGradient ruby = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ApexColors.rubyBright, ApexColors.rubyDeep],
  );

  /// Ambient space canvas — subtle vertical falloff for Scaffolds.
  static const LinearGradient spaceCanvas = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [ApexColors.deepSpace, ApexColors.spaceVoid],
  );

  /// Gradient border for glass panels (top-lit).
  static const LinearGradient glassEdge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x55A0B6FF), Color(0x1522356A)],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Typography — futuristic stack via google_fonts
// ─────────────────────────────────────────────────────────────────────────────

class ApexTypography {
  ApexTypography._();

  static TextStyle _sora(double size, FontWeight w,
          {Color color = ApexColors.textPrimary,
          double letterSpacing = 0,
          double height = 1.2}) =>
      GoogleFonts.sora(
        fontSize: size,
        fontWeight: w,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  static TextStyle _spaceGrotesk(double size, FontWeight w,
          {Color color = ApexColors.textSecondary,
          double letterSpacing = 0,
          double height = 1.45}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: w,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  static TextStyle _mono(double size, FontWeight w,
          {Color color = ApexColors.sapphire,
          double letterSpacing = 0.5,
          double height = 1.0}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: w,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  /// Hero display — app title, splash.
  static TextStyle get displayLarge =>
      _sora(40, FontWeight.w700, letterSpacing: -1.2, height: 1.15);

  /// Screen-level heading.
  static TextStyle get headlineMedium =>
      _sora(24, FontWeight.w600, letterSpacing: -0.3, height: 1.25);

  /// Card / dialog title.
  static TextStyle get titleMedium =>
      _sora(16, FontWeight.w600, letterSpacing: 0, height: 1.35);

  /// Body paragraph — `Space Grotesk`, optimal for UI copy.
  static TextStyle get bodyLarge =>
      _spaceGrotesk(16, FontWeight.w400, height: 1.5);

  /// Body small — labels, secondary copy.
  static TextStyle get bodyMedium =>
      _spaceGrotesk(14, FontWeight.w400, height: 1.45);

  /// Button labels — all-caps-friendly, sapphire by default.
  static TextStyle get labelLarge => _sora(
        14,
        FontWeight.w600,
        letterSpacing: 0.6,
        color: ApexColors.sapphire,
        height: 1.2,
      );

  /// Mono eval bar — "+1.4", "M5".
  static TextStyle get monoEval =>
      _mono(18, FontWeight.w700, letterSpacing: 0.5);
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme data
// ─────────────────────────────────────────────────────────────────────────────

class ApexTheme {
  ApexTheme._();

  static ThemeData get dark {
    final ColorScheme colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: ApexColors.sapphire,
      onPrimary: ApexColors.textOnAccent,
      primaryContainer: ApexColors.sapphireDeep,
      onPrimaryContainer: ApexColors.sapphireGlow,
      secondary: ApexColors.ruby,
      onSecondary: ApexColors.textPrimary,
      surface: ApexColors.deepSpace,
      onSurface: ApexColors.textPrimary,
      error: ApexColors.ruby,
      onError: ApexColors.textPrimary,
      outline: ApexColors.subtleBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ApexColors.deepSpace,
      textTheme: TextTheme(
        displayLarge: ApexTypography.displayLarge,
        headlineMedium: ApexTypography.headlineMedium,
        titleMedium: ApexTypography.titleMedium,
        bodyLarge: ApexTypography.bodyLarge,
        bodyMedium: ApexTypography.bodyMedium,
        labelLarge: ApexTypography.labelLarge,
      ),

      // ── App bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: ApexColors.deepSpace,
        foregroundColor: ApexColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: ApexTypography.titleMedium.copyWith(
          color: ApexColors.sapphire,
          letterSpacing: 1.5,
        ),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: ApexColors.cosmicDust.withValues(alpha: 0.72),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: ApexColors.subtleBorder, width: 0.5),
        ),
      ),

      // ── Elevated buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ApexColors.sapphireDeep,
          foregroundColor: ApexColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: ApexTypography.labelLarge.copyWith(
            color: ApexColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ── Outlined buttons ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ApexColors.sapphire,
          side: const BorderSide(color: ApexColors.sapphireDeep, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: ApexTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ── Icon buttons ──
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ApexColors.textSecondary),
      ),

      // ── Bottom nav ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ApexColors.deepSpace,
        selectedItemColor: ApexColors.sapphire,
        unselectedItemColor: ApexColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Dividers ──
      dividerTheme: const DividerThemeData(
        color: ApexColors.subtleBorder,
        thickness: 0.5,
        space: 0,
      ),

      // ── Dialogs — styled to be compatible with [GlassPanel] wrappers. ──
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: ApexTypography.headlineMedium,
        contentTextStyle: ApexTypography.bodyLarge,
      ),

      // ── Sliders ──
      sliderTheme: SliderThemeData(
        activeTrackColor: ApexColors.sapphire,
        inactiveTrackColor: ApexColors.subtleBorder,
        thumbColor: ApexColors.sapphireBright,
        overlayColor: ApexColors.sapphire.withValues(alpha: 0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),

      // ── Text selection ──
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ApexColors.sapphire,
        selectionColor: ApexColors.sapphire.withValues(alpha: 0.24),
        selectionHandleColor: ApexColors.sapphireBright,
      ),

      // ── Tooltips ──
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ApexColors.nebula,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
        ),
        textStyle: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textPrimary,
        ),
      ),
    );
  }
}
