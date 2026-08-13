import 'package:flutter/material.dart';

/// Base typography scale — intentionally color-neutral.
///
/// Colors are injected by [AppTheme.lightTheme] and [AppTheme.darkTheme] via
/// [TextTheme], which Flutter propagates through [DefaultTextStyle].
/// DO NOT add colors here; doing so bakes a single mode's color into every
/// [copyWith] call that doesn't explicitly override the color.
class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.1,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    // color: null — inherits from theme textTheme
  );

  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    // color: null
  );

  static const TextStyle timerDisplay = TextStyle(
    fontFamily: 'monospace',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    // color: null
  );
}
