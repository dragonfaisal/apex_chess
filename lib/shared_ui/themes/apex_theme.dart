import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Apex Chess — "Quiet Power" Cyber Design System
// ─────────────────────────────────────────────────────────────────────────────
// Charcoal canvas, Electric Blue accents, clean mono typography.
// Every surface is deliberately dark so the cyan glows.
// ─────────────────────────────────────────────────────────────────────────────

/// ── Color Palette ───────────────────────────────────────────────────────────

class ApexColors {
  ApexColors._();

  // Backgrounds
  static const Color trueBlack       = Color(0xFF111111);
  static const Color darkSurface     = Color(0xFF1A1A1A);
  static const Color elevatedSurface = Color(0xFF222222);
  static const Color cardSurface     = Color(0xFF2A2A2A);
  static const Color subtleBorder    = Color(0xFF3A3A3A);

  // Electric Blue / Cyan Spectrum
  static const Color electricBlue    = Color(0xFF00BFFF);
  static const Color brightCyan      = Color(0xFF33CFFF);
  static const Color mutedCyan       = Color(0xFF0088B3);
  static const Color deepCyan        = Color(0xFF006080);
  static const Color cyanGlow        = Color(0xFFB3ECFF);

  // Legacy gold aliases (keeps old code compiling — maps to cyan)
  static const Color royalGold       = electricBlue;
  static const Color brightGold      = brightCyan;
  static const Color mutedGold       = mutedCyan;
  static const Color deepGold        = deepCyan;
  static const Color goldShimmer     = cyanGlow;

  // Text
  static const Color textPrimary     = Color(0xFFF0F0F0);
  static const Color textSecondary   = Color(0xFFB0B0B0);
  static const Color textTertiary    = Color(0xFF707070);
  static const Color textOnAccent    = Color(0xFF0A0A0A);

  // Semantic (Move Quality)
  static const Color brilliant       = Color(0xFF00E5FF); // !! brilliant
  static const Color great           = Color(0xFF22C55E); // !  great
  static const Color inaccuracy      = Color(0xFFFBBF24); // ?! inaccuracy
  static const Color mistake         = Color(0xFFF97316); // ?  mistake
  static const Color blunder         = Color(0xFFEF4444); // ?? blunder
  static const Color book            = Color(0xFFA78BFA); // book move
  static const Color best            = Color(0xFF00BFFF); // ★  best/engine
}

/// ── Typography ──────────────────────────────────────────────────────────────

class ApexTypography {
  ApexTypography._();

  static const String _fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    color: ApexColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: ApexColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    color: ApexColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: ApexColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    color: ApexColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: ApexColors.electricBlue,
    height: 1.2,
  );

  static const TextStyle monoEval = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: ApexColors.electricBlue,
    height: 1.0,
  );
}

/// ── Theme Data ──────────────────────────────────────────────────────────────

class ApexTheme {
  ApexTheme._();

  static ThemeData get dark {
    final ColorScheme colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: ApexColors.electricBlue,
      onPrimary: ApexColors.textOnAccent,
      primaryContainer: ApexColors.deepCyan,
      onPrimaryContainer: ApexColors.cyanGlow,
      secondary: ApexColors.mutedCyan,
      onSecondary: ApexColors.textOnAccent,
      surface: ApexColors.darkSurface,
      onSurface: ApexColors.textPrimary,
      error: ApexColors.blunder,
      onError: ApexColors.textPrimary,
      outline: ApexColors.subtleBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ApexColors.darkSurface,
      fontFamily: 'Inter',

      // ── App Bar ──────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: ApexColors.darkSurface,
        foregroundColor: ApexColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: ApexTypography.titleMedium.copyWith(
          color: ApexColors.electricBlue,
          letterSpacing: 1.5,
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: ApexColors.cardSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ApexColors.subtleBorder, width: 0.5),
        ),
      ),

      // ── Elevated Buttons ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ApexColors.electricBlue,
          foregroundColor: ApexColors.textOnAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: ApexTypography.labelLarge.copyWith(
            color: ApexColors.textOnAccent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Outlined Buttons ─────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ApexColors.electricBlue,
          side: const BorderSide(color: ApexColors.mutedCyan, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: ApexTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Icon Buttons ─────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ApexColors.textSecondary,
        ),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ApexColors.darkSurface,
        selectedItemColor: ApexColors.electricBlue,
        unselectedItemColor: ApexColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Dividers ─────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ApexColors.subtleBorder,
        thickness: 0.5,
        space: 0,
      ),

      // ── Dialogs ──────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: ApexColors.elevatedSurface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ApexColors.subtleBorder, width: 0.5),
        ),
        titleTextStyle: ApexTypography.headlineMedium,
        contentTextStyle: ApexTypography.bodyLarge,
      ),

      // ── Sliders ──────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: ApexColors.electricBlue,
        inactiveTrackColor: ApexColors.subtleBorder,
        thumbColor: ApexColors.brightCyan,
        overlayColor: ApexColors.electricBlue.withAlpha(30),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),

      // ── Text Selection ───────────────────────────────────────────────
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ApexColors.electricBlue,
        selectionColor: ApexColors.electricBlue.withAlpha(60),
        selectionHandleColor: ApexColors.brightCyan,
      ),

      // ── Tooltips ─────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ApexColors.elevatedSurface,
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
