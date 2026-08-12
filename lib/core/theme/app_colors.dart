import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // NEW PALETTE — Extracted from attached image (3-band teal set)
  // ═══════════════════════════════════════════════════════════════

  // Band 1 (left) — Deep Muted Teal: primary element color
  // Used for: AppBar, BottomNavBar, filled buttons, switch active
  static const Color deepTeal = Color(0xFF7DA9A6);

  // Band 2 (middle) — Mid Blue-Teal: secondary / accent color
  // Used for: FAB, highlights, toggles, card borders, indicators
  static const Color midTeal = Color(0xFF8DBDBD);

  // Band 3 (right) — Warm Cream: background / surface color
  // Used for: Scaffold, cards, input fills, unfilled surfaces
  static const Color warmCream = Color(0xFFFEFEF0);

  // ═══════════════════════════════════════════════════════════════
  // LIGHT MODE — Semantic tokens
  // ═══════════════════════════════════════════════════════════════

  // Surface / background for light mode
  static const Color lightBackground = warmCream;
  // Slightly deeper cream for elevated surfaces / cards
  // Slightly deeper cream for elevated surfaces / cards in light mode
  static const Color lightSurface = Color(0xFFF2F2E4);
  // Border color for cards and inputs
  static const Color lightBorder = midTeal;

  // ═══════════════════════════════════════════════════════════════
  // HIGH-CONTRAST SLATE TOKENS — used for dark text on cream/light surfaces
  // Matches the Settings screen "high-contrast" standard
  // ═══════════════════════════════════════════════════════════════

  /// Primary header / title text on light surfaces: deep navy-slate
  static const Color darkSlate = Color(0xFF1E293B);

  /// Secondary / body / subtitle text on light surfaces: slate-grey
  static const Color slateGrey = Color(0xFF475569);

  /// Muted / caption text on light surfaces: lighter slate
  static const Color mutedSlate = Color(0xFF64748B);

  /// Section label text (bold, high-contrast teal-dark) on light surfaces
  static const Color sectionLabelDark = Color(0xFF1A2E2B);

  // Text on cream backgrounds — use slate for true legibility on warm-cream
  static const Color lightTextPrimary = darkSlate;       // #1E293B — was teal-dark
  static const Color lightTextSecondary = slateGrey;     // #475569 — was mid-teal (washed out)
  static const Color lightTextMuted = mutedSlate;        // #64748B — was teal-muted (washed out)

  // Text on deepTeal surfaces (app bar, buttons) — warm cream for contrast
  static const Color onDeepTeal = warmCream;

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE — Derived from deepTeal palette
  // ═══════════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF0E100E);
  static const Color darkSurface = Color(0xFF1C1E1C);
  static const Color darkSurfaceCard = Color(0xFF1C1E1C);
  static const Color darkSurfaceCardElevated = Color(0xFF1C1E1C);
  static const Color darkSurfaceBorder = Color(0xFF1C1E1C); // Transparent/Merged border

  // New Lime Accent
  static const Color accentLime = Color(0xFF91E335);

  // Text on dark mode surfaces
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextMuted = Color(0xFF6B7280);

  // ═══════════════════════════════════════════════════════════════
  // SHARED — Status, emergency, gradients
  // ═══════════════════════════════════════════════════════════════

  static const Color vitalRed = Color(0xFFE53935);
  static const Color vitalRedGlow = Color(0xFFE53935);
  static const Color successEmerald = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color emergencyRed = Color(0xFFE53935);

  // Circuit / ECG art
  static const Color circuitLine = midTeal;
  static const Color circuitNode = Color(0xFFB2D8D8);
  static const Color ecgLineColor = warmCream;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepTeal, midTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [darkSurfaceCardElevated, darkSurfaceCard],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vitalRedGradient = LinearGradient(
    colors: [vitalRed, darkBackground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // LEGACY ALIASES — Keep for backward compat, redirect to new tokens
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = deepTeal;
  static const Color accent = midTeal;
  static const Color bgUnfilled = warmCream;
  static const Color elementBlue = deepTeal;
  static const Color accentBlue = midTeal;
  static const Color onElementBlue = onDeepTeal;
  static const Color lightTeal = midTeal;
  static const Color lightCyan = Color(0xFFB2D8D8);
  static const Color paleCyan = Color(0xFFD4EDED);
  static const Color badgeColor = darkSurfaceCardElevated;
  static const Color textPrimaryDark = darkTextPrimary;
  static const Color textSecondaryDark = darkTextSecondary;
  static const Color textMutedDark = darkTextMuted;
  static const Color textPrimaryLight = lightTextPrimary;
  static const Color textSecondaryLight = lightTextSecondary;
  static const Color textMutedLight = lightTextMuted;
  static const Color cardGradient = darkSurfaceCard; // legacy compat
  static const Color ecgLineWhite = onDeepTeal;
}
