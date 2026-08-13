import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────
  // DARK THEME — Deep teal dark backgrounds, warm cream text
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentLime,
        secondary: AppColors.accentLime,
        surface: AppColors.darkSurfaceCard,
        surfaceContainerHighest: AppColors.darkSurfaceCardElevated,
        error: AppColors.emergencyRed,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkTextPrimary,
        // Border / divider color for dark mode
        outlineVariant: AppColors.darkSurfaceBorder,
        // Secondary / muted text on dark surfaces
        onSurfaceVariant: AppColors.darkTextSecondary,
      ),
      hintColor: AppColors.darkTextMuted,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary, fontSize: 28),
        displaySmall: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary, fontSize: 24),
        headlineLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary, fontSize: 20),
        headlineSmall: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: AppTypography.titleMedium.copyWith(color: AppColors.darkTextSecondary, fontSize: 13),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary, fontSize: 12),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: AppTypography.labelLarge.copyWith(color: AppColors.darkTextSecondary, fontSize: 12),
        labelSmall: AppTypography.caption.copyWith(color: AppColors.darkTextMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: const BorderSide(color: AppColors.darkSurfaceBorder),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkSurfaceCard,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentLime,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        indicatorColor: AppColors.darkSurface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentLime);
          }
          return IconThemeData(color: AppColors.darkTextPrimary.withValues(alpha: 0.7));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.accentLime, fontWeight: FontWeight.w700);
          }
          return TextStyle(color: AppColors.darkTextPrimary.withValues(alpha: 0.7));
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.accentLime : AppColors.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accentLime.withValues(alpha: 0.2)
              : AppColors.darkSurfaceCard;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceCard,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.button,
          borderSide: const BorderSide(color: AppColors.accentLime, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.button,
          borderSide: const BorderSide(color: AppColors.darkSurfaceBorder, width: 1.2),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // LIGHT THEME — Warm cream backgrounds, deep teal primary elements
  // ─────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.warmCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepTeal,
        secondary: AppColors.midTeal,
        surface: AppColors.warmCream,
        // Slightly darker cream for elevated containers / snackbars
        surfaceContainerHighest: AppColors.lightSurface,
        error: AppColors.emergencyRed,
        // Warm cream text on deepTeal surfaces (buttons, nav bar, app bar)
        onPrimary: AppColors.onDeepTeal,
        // Dark teal text on secondary surfaces
        onSecondary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onError: AppColors.warmCream,
        // Border / divider color for light mode
        outlineVariant: AppColors.lightBorder,
        // Secondary / muted text on light surfaces
        onSurfaceVariant: AppColors.lightTextSecondary,
      ),
      hintColor: AppColors.lightTextMuted,
      // Enforce legible dark text globally in light mode
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary, fontSize: 28),
        displaySmall: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary, fontSize: 24),
        headlineLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary, fontSize: 20),
        headlineSmall: AppTypography.titleMedium.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.lightTextPrimary),
        titleSmall: AppTypography.titleMedium.copyWith(color: AppColors.lightTextSecondary, fontSize: 13),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextPrimary),
        bodySmall: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary, fontSize: 12),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: AppTypography.labelLarge.copyWith(color: AppColors.lightTextSecondary, fontSize: 12),
        labelSmall: AppTypography.caption.copyWith(color: AppColors.lightTextMuted),
      ),
      // AppBar: deepTeal background, warm cream text
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepTeal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.onDeepTeal,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.onDeepTeal),
      ),
      // Cards: warm cream surface, midTeal border
      cardTheme: CardThemeData(
        color: AppColors.warmCream,
        elevation: 2,
        shadowColor: AppColors.deepTeal.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: const BorderSide(color: AppColors.midTeal, width: 1.2),
        ),
      ),
      // Elevated buttons: deepTeal fill, warm cream text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepTeal,
          foregroundColor: AppColors.onDeepTeal,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
        ),
      ),
      // Bottom Nav Bar: deepTeal background, cream selected
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.deepTeal,
        indicatorColor: AppColors.midTeal,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.onDeepTeal);
          }
          return const IconThemeData(color: AppColors.onDeepTeal);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.onDeepTeal, fontWeight: FontWeight.w700);
          }
          return const TextStyle(color: AppColors.onDeepTeal);
        }),
      ),
      // Switch: deepTeal active, midTeal inactive
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.deepTeal : AppColors.midTeal;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.deepTeal.withValues(alpha: 0.4)
              : AppColors.midTeal.withValues(alpha: 0.25);
        }),
      ),
      // Input fields: cream fill, deepTeal focus, midTeal border, dark hint text
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmCream,
        hintStyle: const TextStyle(color: AppColors.mutedSlate),
        labelStyle: const TextStyle(color: AppColors.slateGrey),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.button,
          borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.button,
          borderSide: const BorderSide(color: AppColors.midTeal, width: 1.2),
        ),
      ),
      // Snackbars: light surface with dark text so text is legible on cream
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.lightSurface,
        contentTextStyle: TextStyle(color: AppColors.darkSlate),
      ),
      // Dialogs: light surface with dark text
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        titleTextStyle: TextStyle(
          color: AppColors.darkSlate,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: AppColors.slateGrey, fontSize: 14),
      ),
    );
  }
}
