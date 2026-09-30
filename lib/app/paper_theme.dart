import 'dart:ui';

import 'palette.dart';

enum PaperPattern { lined, grid, millimeter }

/// Dersin kağıt teması: hem oyundaki kayan sayfa hem menü zemini kullanır.
class PaperTheme {
  const PaperTheme({
    required this.pattern,
    required this.background,
    required this.line,
    required this.lineStrong,
    required this.hole,
    required this.laneGuide,
    required this.trail,
    required this.endShade,
    required this.endText,
    this.margin,
  });

  final PaperPattern pattern;
  final Color background;
  final Color line;
  final Color lineStrong;
  final Color hole;
  final Color laneGuide;
  final Color trail;
  final Color endShade;
  final Color endText;

  /// Çizgili kağıttaki kırmızı kenar çizgisi.
  final Color? margin;

  bool get isDark => background.computeLuminance() < 0.3;

  static const lined = PaperTheme(
    pattern: PaperPattern.lined,
    background: Palette.paper,
    line: Palette.paperLine,
    lineStrong: Palette.paperLine,
    hole: Palette.hole,
    laneGuide: Palette.pencilLight,
    trail: Palette.ink,
    endShade: Palette.paperShade,
    endText: Palette.pencil,
    margin: Palette.marginRed,
  );

  static const grid = PaperTheme(
    pattern: PaperPattern.grid,
    background: Palette.paper,
    line: Palette.gridLine,
    lineStrong: Palette.gridLine,
    hole: Palette.hole,
    laneGuide: Palette.pencilLight,
    trail: Palette.ink,
    endShade: Palette.paperShade,
    endText: Palette.pencil,
  );

  /// PHYS 101: turuncu milimetrik kağıt.
  static const millimeter = PaperTheme(
    pattern: PaperPattern.millimeter,
    background: Color(0xFFFFFCF4),
    line: Color(0x30E9955B),
    lineStrong: Color(0x66E07A3A),
    hole: Palette.hole,
    laneGuide: Color(0xFFB9A89A),
    trail: Palette.ink,
    endShade: Color(0xFFF3E8D6),
    endText: Color(0xFF9A7B62),
  );

  /// CS 101: koyu "terminal" sayfası, fosfor yeşili iz.
  static const terminal = PaperTheme(
    pattern: PaperPattern.grid,
    background: Color(0xFF18202C),
    line: Color(0xFF232E3E),
    lineStrong: Color(0xFF2C3A4E),
    hole: Color(0xFF0F151D),
    laneGuide: Color(0xFF3E4F66),
    trail: Color(0xFF7CE3A0),
    endShade: Color(0xFF111820),
    endText: Color(0xFF6E8199),
  );

  static PaperTheme of(String id) => switch (id) {
    'grid' => grid,
    'millimeter' => millimeter,
    'terminal' => terminal,
    _ => lined,
  };
}
