import 'package:flutter/material.dart';

import 'palette.dart';

abstract final class AppTheme {
  static const handFont = 'Caveat';
  static const uiFont = 'PatrickHand';

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: uiFont,
      scaffoldBackgroundColor: Palette.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.ink,
        surface: Palette.paper,
        primary: Palette.ink,
        error: Palette.teacherRed,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: Palette.darkText,
        displayColor: Palette.ink,
      ),
    );
  }

  static TextStyle hand(
    double size, {
    Color color = Palette.ink,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: handFont,
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: 1.05,
  );

  static TextStyle ui(
    double size, {
    Color color = Palette.darkText,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: uiFont,
    fontSize: size,
    color: color,
    fontWeight: weight,
  );
}
