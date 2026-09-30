import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/app/app.dart';
import 'package:tukenmez_gpa_run/app/game_content.dart';
import 'package:tukenmez_gpa_run/app/progress_controller.dart';
import 'package:tukenmez_gpa_run/app/providers.dart';
import 'package:tukenmez_gpa_run/data/save_repository.dart';

import '../helpers/config_fixtures.dart';

void main() {
  late GameContent content;

  setUpAll(() async {
    content = await GameContent.load(DiskAssetBundle());
  });

  Widget app(MemoryStore store) => ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
      contentProvider.overrideWith((ref) async => content),
    ],
    child: const TukenmezApp(),
  );

  testWidgets('ana menü → ders seçimi → ders ekranı', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemoryStore()));
    await tester.pumpAndSettle();
    expect(find.text('TÜKENMEZ'), findsOneWidget);
    expect(find.text('—'), findsOneWidget, reason: 'henüz GPA yok');
    expect(find.text('1. dönem'), findsOneWidget);

    await tester.tap(find.text('Ders seçimine git'));
    await tester.pumpAndSettle();
    expect(find.text('Ders Seçimi'), findsOneWidget);
    expect(find.text('3 ders seçildi · en az 3, en fazla 4'), findsOneWidget);
    await tester.tap(find.text('Kaydımı yap'));
    await tester.pumpAndSettle();

    expect(find.text('Bu dönemin dersleri'), findsOneWidget);
    expect(find.text('PHYS 101'), findsOneWidget);
    await tester.tap(find.text('CALC 101'));
    await tester.pumpAndSettle();
    expect(find.text('İzlence'), findsOneWidget);
    expect(find.text('Sınava gir: Quiz 1'), findsOneWidget);
    expect(find.text('%30'), findsNWidgets(2));
  });

  testWidgets('transkript ekranı açılır', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(MemoryStore()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transkript'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz tamamlanmış ders yok.'), findsOneWidget);
    expect(find.text('Mezuniyet: 0/8 dönem'), findsOneWidget);
  });
}
