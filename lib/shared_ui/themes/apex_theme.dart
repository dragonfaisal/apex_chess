/// Apex Chess Material-inspired product design system.
///
/// The palette stays true to Apex: deep navy, electric blue, cyan, and rare
/// glow for important states. Legacy identifiers remain as aliases so existing
/// screens can migrate incrementally.
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
  static const Color spaceVoid = Color(0xFF07101F);

  /// Standard surface — dashboards, list screens.
  static const Color deepSpace = Color(0xFF07101F);

  /// Slightly lifted — app-bar, persistent chrome.
  static const Color nebula = Color(0xFF111A2E);

  /// Dialog / modal background under the glass blur.
  static const Color cosmicDust = Color(0xFF15223A);

  /// Subtle separators inside glass panels.
  static const Color stardustLine = Color(0x33A0B6FF);

  // ── Sapphire accent (primary) ──────────────────────────────────────────
  static const Color sapphire = Color(0xFF2979FF);
  static const Color sapphireBright = Color(0xFF4FC3FF);
  static const Color sapphireDeep = Color(0xFF1555D1);
  static const Color sapphireGlow = Color(0xFFB8DEFF);

  // ── Ruby accent (danger / highlight) ───────────────────────────────────
  static const Color ruby = Color(0xFFFF4D7A);
  static const Color rubyBright = Color(0xFFFF7FA2);
  static const Color rubyDeep = Color(0xFFC01F4E);

  // ── Aurora accent (brilliant moments, victory) ─────────────────────────
  static const Color aurora = Color(0xFF00E5FF);
  static const Color auroraSoft = Color(0xFF7BFFFF);

  // ── Emerald / Neon accent (Phase 4 VFX — Quantum Shatter, Great-Move aura) ─
  /// Vibrant emerald used for the shatter-loader core and "Best Move" aura.
  static const Color emerald = Color(0xFF10F0A5);

  /// Lighter rim used for shard highlights and XP ring fills.
  static const Color emeraldBright = Color(0xFF7BFFD0);

  /// Deep emerald for gradient bases.
  static const Color emeraldDeep = Color(0xFF0A8A5F);

  /// Electric neon used for crackling arcs + Great-Move aura.
  static const Color electricNeon = Color(0xFF3FA0FF);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFFB4C0E0);
  static const Color textTertiary = Color(0xFF7A87B0);
  static const Color textOnAccent = Color(0xFF050814);

  // ── Move-quality semantic colours ──────────────────────────────────────
  static const Color brilliant = aurora; // !!
  static const Color best = Color(0xFF00E676); // ★
  static const Color great = Color(0xFF2196F3); // !
  static const Color excellent = Color(0xFF69F0AE);
  static const Color good = Color(0xFF26A69A);
  static const Color inaccuracy = Color(0xFFFFC857); // ?!
  static const Color mistake = Color(0xFFFF8C3A); // ?
  static const Color miss = Color(0xFFFF7043);
  static const Color blunder = Color(0xFFFF5252); // ??
  static const Color book = Color(0xFFC8A46A); // book
  static const Color checkmate = Color(0xFFB388FF);

  // ── Legacy aliases (old "Quiet Power" names) ───────────────────────────
  // These map the previous charcoal + cyan identifiers onto the new palette
  // so existing widgets keep rendering without a simultaneous rewrite.
  static const Color trueBlack = spaceVoid;
  static const Color darkSurface = deepSpace;
  static const Color elevatedSurface = nebula;
  static const Color cardSurface = cosmicDust;
  static const Color subtleBorder = Color(0xFF243058);

  static const Color electricBlue = sapphire;
  static const Color brightCyan = sapphireBright;
  static const Color mutedCyan = sapphireDeep;
  static const Color deepCyan = Color(0xFF0C3A80);
  static const Color cyanGlow = sapphireGlow;

  static const Color royalGold = sapphire;
  static const Color brightGold = sapphireBright;
  static const Color mutedGold = sapphireDeep;
  static const Color deepGold = deepCyan;
  static const Color goldShimmer = sapphireGlow;
}

class ApexSpacing {
  ApexSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class ApexRadius {
  ApexRadius._();

  static const double chip = 10;
  static const double button = 16;
  static const double card = 18;
  static const double sheet = 24;
  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );
}

class ApexMotion {
  ApexMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve standard = Curves.easeOutCubic;
}

class ApexSemanticMoveColors {
  ApexSemanticMoveColors._();

  static const Color brilliant = ApexColors.brilliant;
  static const Color great = ApexColors.great;
  static const Color best = ApexColors.best;
  static const Color excellent = ApexColors.excellent;
  static const Color good = ApexColors.good;
  static const Color book = ApexColors.book;
  static const Color inaccuracy = ApexColors.inaccuracy;
  static const Color mistake = ApexColors.mistake;
  static const Color miss = ApexColors.miss;
  static const Color blunder = ApexColors.blunder;
  static const Color checkmate = ApexColors.checkmate;
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

  static TextStyle _display(
    double size,
    FontWeight w, {
    Color color = ApexColors.textPrimary,
    double letterSpacing = 0,
    double height = 1.2,
  }) => GoogleFonts.outfit(
    fontSize: size,
    fontWeight: w,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  );

  static TextStyle _body(
    double size,
    FontWeight w, {
    Color color = ApexColors.textSecondary,
    double letterSpacing = 0,
    double height = 1.45,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  );

  static TextStyle _mono(
    double size,
    FontWeight w, {
    Color color = ApexColors.sapphire,
    double letterSpacing = 0.5,
    double height = 1.0,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: w,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  );

  /// Hero display — app title, splash.
  static TextStyle get displayLarge =>
      _display(40, FontWeight.w700, letterSpacing: 0, height: 1.15);

  /// Screen-level heading.
  static TextStyle get headlineMedium =>
      _display(24, FontWeight.w600, letterSpacing: 0, height: 1.25);

  /// Card / dialog title.
  static TextStyle get titleMedium =>
      _display(16, FontWeight.w600, letterSpacing: 0, height: 1.35);

  /// Body paragraph — `Space Grotesk`, optimal for UI copy.
  static TextStyle get bodyLarge => _body(16, FontWeight.w400, height: 1.5);

  /// Body small — labels, secondary copy.
  static TextStyle get bodyMedium => _body(14, FontWeight.w400, height: 1.45);

  /// Button labels — all-caps-friendly, sapphire by default.
  static TextStyle get labelLarge => _display(
    14,
    FontWeight.w600,
    letterSpacing: 0,
    color: ApexColors.sapphire,
    height: 1.2,
  );

  /// Mono eval bar — "+1.4", "M5".
  static TextStyle get monoEval =>
      _mono(18, FontWeight.w700, letterSpacing: 0.5);
}

class ApexTextStyles {
  ApexTextStyles._();

  static TextStyle get display => ApexTypography.displayLarge;
  static TextStyle get heading => ApexTypography.headlineMedium;
  static TextStyle get title => ApexTypography.titleMedium;
  static TextStyle get body => ApexTypography.bodyLarge;
  static TextStyle get bodySmall => ApexTypography.bodyMedium;
  static TextStyle get label => ApexTypography.labelLarge;
  static TextStyle get number => ApexTypography.monoEval;
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
      splashColor: ApexColors.sapphire.withValues(alpha: 0.10),
      highlightColor: ApexColors.sapphire.withValues(alpha: 0.08),
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
            borderRadius: BorderRadius.circular(ApexRadius.button),
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
            borderRadius: BorderRadius.circular(ApexRadius.button),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ApexColors.sapphireBright,
          textStyle: ApexTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ApexRadius.button),
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

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ApexColors.nebula.withValues(alpha: 0.96),
        indicatorColor: ApexColors.sapphire.withValues(alpha: 0.18),
        elevation: 0,
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => ApexTypography.bodyMedium.copyWith(
            color: states.contains(WidgetState.selected)
                ? ApexColors.textPrimary
                : ApexColors.textTertiary,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? ApexColors.sapphireBright
                : ApexColors.textTertiary,
            size: 22,
          ),
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ApexColors.nebula.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textTertiary,
        ),
        labelStyle: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ApexColors.stardustLine.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ApexColors.sapphire.withValues(alpha: 0.75),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ApexColors.ruby),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ApexColors.rubyBright),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: ApexColors.nebula.withValues(alpha: 0.70),
        selectedColor: ApexColors.sapphire.withValues(alpha: 0.20),
        disabledColor: ApexColors.nebula.withValues(alpha: 0.38),
        side: const BorderSide(color: ApexColors.subtleBorder, width: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexRadius.chip),
        ),
        labelStyle: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textSecondary,
          fontSize: 12,
        ),
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
