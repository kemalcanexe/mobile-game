import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/domain/grading/grade_calculator.dart';
import 'package:tukenmez_gpa_run/domain/grading/letter_grade.dart';

import '../helpers/config_fixtures.dart';

void main() {
  final rules = loadGradingRules();
  final scale = rules.scale;

  group('Harf sınırları (alt dahil, üst hariç)', () {
    final cases = <double, String>{
      100: 'A+',
      97: 'A+',
      96.99: 'A',
      93: 'A',
      92.99: 'A-',
      90: 'A-',
      89.99: 'B+',
      87: 'B+',
      83: 'B',
      80: 'B-',
      79.99: 'C+',
      77: 'C+',
      73: 'C',
      70: 'C-',
      67: 'D+',
      63: 'D',
      60: 'D-',
      59.99: 'F',
      0: 'F',
    };
    cases.forEach((score, letter) {
      test('$score → $letter', () {
        expect(scale.gradeFor(score).symbol, letter);
      });
    });
  });

  test('harf puanları 4.0 skalasında', () {
    expect(scale.bySymbol('A+').points, 4.0);
    expect(scale.bySymbol('A').points, 4.0);
    expect(scale.bySymbol('A-').points, 3.7);
    expect(scale.bySymbol('B+').points, 3.3);
    expect(scale.bySymbol('C').points, 2.0);
    expect(scale.bySymbol('D-').points, 0.7);
    expect(scale.bySymbol('F').points, 0.0);
    expect(scale.bySymbol('F').isFailing, isTrue);
    expect(scale.bySymbol('D-').isFailing, isFalse);
  });

  test('kayan nokta hatası sınırda harfi düşürmez', () {
    // 97 × ağırlıklar toplamı kayan noktada 96.99999999999999 çıkabilir.
    expect(scale.gradeFor(96.99999999999999).symbol, 'A+');
    expect(scale.gradeFor(96.9999).symbol, 'A');
  });

  test('0 alt sınırı olmayan tablo reddedilir', () {
    expect(
      () =>
          GradeScale([const LetterGrade(symbol: 'A', minScore: 90, points: 4)]),
      throwsArgumentError,
    );
  });

  test('bilinmeyen harf hata verir', () {
    expect(() => scale.bySymbol('E'), throwsFormatException);
  });

  test('GradeCalculator.letterFor tabloyu kullanır', () {
    expect(GradeCalculator(rules).letterFor(88).symbol, 'B+');
  });
}
