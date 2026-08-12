import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;

  static final BorderRadius small = BorderRadius.circular(xs);
  static final BorderRadius medium = BorderRadius.circular(md);
  static final BorderRadius large = BorderRadius.circular(lg);
  static final BorderRadius extraLarge = BorderRadius.circular(xl);
  
  static final BorderRadius card = large; // 20.0
  static final BorderRadius button = medium; // 16.0
  static final BorderRadius dialog = extraLarge; // 24.0
}
