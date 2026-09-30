import 'package:flutter/material.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';

/// Kağıda vurulmuş harf notu damgası.
class GradeStamp extends StatelessWidget {
  const GradeStamp({
    super.key,
    required this.letter,
    this.size = 96,
    this.tilt = -0.2,
  });

  final String letter;
  final double size;
  final double tilt;

  Color get _color => letter.startsWith('F')
      ? Palette.teacherRed
      : Palette.teacherRed.withValues(alpha: 0.92);

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: tilt,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _color, width: size * 0.06),
      ),
      child: Text(
        letter.replaceAll('-', '−'),
        style: AppTheme.hand(size * 0.55, color: _color),
      ),
    ),
  );
}
