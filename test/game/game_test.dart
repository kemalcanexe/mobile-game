import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tukenmez_gpa_run/game/input/swipe_detector.dart';
import 'package:tukenmez_gpa_run/game/systems/collision_rules.dart';
import 'package:tukenmez_gpa_run/game/systems/level_generator.dart';
import 'package:tukenmez_gpa_run/game/tukenmez_game.dart';

import '../helpers/game_fixtures.dart';

void main() {
  const center = 1;

  group('Şerit değişimi', () {
    testWithGame<TukenmezGame>(
      'sağa ve sola swipe şerit değiştirir',
      () => buildTestGame(const []),
      (game) async {
        game.start();
        expect(game.pen.lane, center);
        game.handleSwipe(SwipeDirection.right);
        game.runFor(0.3);
        expect(game.pen.lane, 2);
        expect(game.pen.x, closeTo(game.lanes.laneX(2), 0.01));

        game.handleSwipe(SwipeDirection.right);
        game.runFor(0.3);
        expect(game.pen.lane, 2, reason: 'kenar şeritten dışarı çıkılmaz');

        game.handleSwipe(SwipeDirection.left);
        game.handleSwipe(SwipeDirection.left);
        game.runFor(0.3);
        expect(game.pen.lane, 0, reason: 'hızlı çift swipe iki şerit atlatır');
      },
    );

    testWithGame<TukenmezGame>(
      'oyun başlamadan girdi alınmaz',
      () => buildTestGame(const []),
      (game) async {
        game.handleSwipe(SwipeDirection.left);
        game.runFor(0.3);
        expect(game.pen.lane, center);
        expect(game.distance, 0, reason: 'hazır ekranında sayfa akmaz');
      },
    );

    testWithGame<TukenmezGame>(
      'oyun konsolu debuff\'ı sol/sağı ters çevirir',
      () => buildTestGame(const [SpawnEvent(700, center, 'gc')]),
      (game) async {
        game.start();
        game.runUntilDistance(760);
        expect(game.effects.controlsReversed, isTrue);
        game.handleSwipe(SwipeDirection.left);
        game.runFor(0.3);
        expect(game.pen.lane, 2);
      },
    );
  });

  group('Zıplama ve eğilme', () {
    testWithGame<TukenmezGame>(
      'zıplarken yer engeline çarpılmaz',
      () => buildTestGame(const [SpawnEvent(700, center, 'og')]),
      (game) async {
        game.start();
        game.runUntilDistance(700, pixelsAway: 40);
        game.handleSwipe(SwipeDirection.up);
        expect(game.pen.pose, PenPose.airborne);
        game.runFor(0.7);
        expect(game.tracker.hitCount, 0);
        expect(game.ink.current, 100);
      },
    );

    testWithGame<TukenmezGame>(
      'zıplamadan yer engeline çarpılır (−5 puan, −10 mürekkep)',
      () => buildTestGame(const [SpawnEvent(700, center, 'og')]),
      (game) async {
        game.start();
        game.runUntilDistance(820);
        expect(game.tracker.hitCount, 1);
        expect(game.tracker.penaltyPoints, 5);
        expect(game.ink.current, 90);
      },
    );

    testWithGame<TukenmezGame>(
      'eğikken hava engeline çarpılmaz, zıplarken çarpılır',
      () => buildTestGame(const [
        SpawnEvent(700, center, 'oa'),
        SpawnEvent(1500, center, 'oa'),
      ]),
      (game) async {
        game.start();
        game.runUntilDistance(700, pixelsAway: 40);
        game.handleSwipe(SwipeDirection.down);
        expect(game.pen.pose, PenPose.ducking);
        game.runFor(0.7);
        expect(game.tracker.hitCount, 0);

        game.runUntilDistance(1500, pixelsAway: 40);
        game.handleSwipe(SwipeDirection.up);
        game.runFor(0.4);
        expect(game.tracker.hitCount, 1);
      },
    );

    testWithGame<TukenmezGame>(
      'havadayken aşağı swipe hızla indirir (fast-fall)',
      () => buildTestGame(const []),
      (game) async {
        game.start();
        game.handleSwipe(SwipeDirection.up);
        game.runFor(0.1);
        game.handleSwipe(SwipeDirection.down);
        expect(game.pen.pose, PenPose.ducking);
      },
    );

    testWithGame<TukenmezGame>(
      'havadayken zıpla swipe\'ı inişte (buffer süresi içinde) uygulanır',
      () => buildTestGame(const []),
      (game) async {
        game.start();
        game.handleSwipe(SwipeDirection.up);
        game.runFor(game.config.jumpSeconds - 0.05);
        game.handleSwipe(SwipeDirection.up);
        expect(game.inputBuffer.pending, SwipeDirection.up);
        game.runFor(0.1);
        expect(game.pen.pose, PenPose.airborne);
        expect(game.inputBuffer.pending, isNull);
      },
    );

    testWithGame<TukenmezGame>(
      'duvar her durumda çarpar',
      () => buildTestGame(const [SpawnEvent(700, center, 'ow')]),
      (game) async {
        game.start();
        game.runUntilDistance(700, pixelsAway: 40);
        game.handleSwipe(SwipeDirection.up);
        game.runFor(0.5);
        expect(game.tracker.hitCount, 1);
      },
    );
  });

  group('Toplama ve skor', () {
    testWithGame<TukenmezGame>(
      'ders notu toplamak skoru artırır, zıplarken de toplanır',
      () => buildTestGame(const [
        SpawnEvent(700, center, 'nt'),
        SpawnEvent(1200, center, 'fc'),
        SpawnEvent(1200, 0, 'bk'),
      ]),
      (game) async {
        game.start();
        game.runUntilDistance(760);
        expect(game.tracker.collectedPoints, 10);
        expect(game.hud.score.value, 10);

        game.runUntilDistance(1200, pixelsAway: 30);
        game.handleSwipe(SwipeDirection.up);
        game.runFor(0.4);
        expect(game.tracker.collectedPoints, 15);
        expect(
          game.tracker.maxPoints,
          40,
          reason: 'kitap spawn oldu ama toplanmadı',
        );
      },
    );

    testWithGame<TukenmezGame>(
      'Fosforlu Kalem puanları 2 katına çıkarır',
      () => buildTestGame(const [
        SpawnEvent(700, center, 'hl'),
        SpawnEvent(900, center, 'nt'),
      ]),
      (game) async {
        game.start();
        game.runUntilDistance(960);
        expect(game.effects.scoreMultiplier, 2);
        expect(game.tracker.collectedPoints, 20);
        expect(game.tracker.maxPoints, 10);
      },
    );

    testWithGame<TukenmezGame>(
      'Kahve oyunu %30 yavaşlatır, Kartuş mürekkep doldurur',
      () => buildTestGame(const [
        SpawnEvent(600, center, 'ph'),
        SpawnEvent(800, center, 'ik'),
        SpawnEvent(1000, center, 'cf'),
      ]),
      (game) async {
        game.start();
        game.runUntilDistance(700);
        expect(game.ink.current, 90);
        expect(game.effects.notificationVisible, isTrue);
        game.runUntilDistance(900);
        expect(game.ink.current, 100);
        game.runUntilDistance(1060);
        final before = game.distance;
        game.runFor(1);
        expect(game.distance - before, closeTo(game.config.baseSpeed * 0.7, 6));
      },
    );

    testWithGame<TukenmezGame>(
      'kötü arkadaş Tüki\'yi bir şerit kenara çeker',
      () => buildTestGame(const [SpawnEvent(700, 0, 'fr')]),
      (game) async {
        game.start();
        game.handleSwipe(SwipeDirection.left);
        game.runUntilDistance(780);
        game.runFor(0.3);
        expect(game.pen.lane, 1);
        expect(game.tracker.penaltyPoints, 15);
      },
    );
  });

  group('Level sonu', () {
    testWithGame<TukenmezGame>(
      'sayfa sonuna ulaşınca level biter ve skor hesaplanır',
      () => buildTestGame(const [
        SpawnEvent(700, center, 'nt'),
        SpawnEvent(900, 0, 'nt'),
      ], totalDistance: 1200),
      (game) async {
        game.start();
        game.runFor(5);
        expect(game.state, RunState.finished);
        final o = game.outcome!;
        expect(o.score.baseScore, 50);
        expect(o.score.cleanPaperCredit, 2);
        expect(o.score.score, 52);
        expect(game.overlays.isActive(TukenmezGame.overlaySummary), isTrue);
        expect(o.map.trail, isNotEmpty);
        expect(o.map.markers, hasLength(1));
      },
    );

    testWithGame<TukenmezGame>(
      'mürekkep bitince level erken biter, skor en fazla 50',
      () => buildTestGame([
        const SpawnEvent(600, center, 'nt'),
        for (var i = 0; i < 10; i++) SpawnEvent(800.0 + i * 150, center, 'ow'),
      ], totalDistance: 5000),
      (game) async {
        game.start();
        game.runFor(10);
        expect(game.state, RunState.finished);
        expect(game.distance, lessThan(5000));
        final o = game.outcome!;
        expect(o.score.inkDepleted, isTrue);
        expect(o.score.score, lessThanOrEqualTo(50));
        expect(o.inkRemaining, 0);
      },
    );
  });

  group('Performans', () {
    testWithGame<TukenmezGame>(
      'nesneler havuzdan yeniden kullanılır, iz noktaları sınırlı',
      () => buildTestGame([
        for (var i = 0; i < 200; i++) SpawnEvent(600.0 + i * 40, i % 3, 'fc'),
      ], totalDistance: 9000),
      (game) async {
        game.start();
        game.handleSwipe(SwipeDirection.left);
        game.runFor(20);
        expect(game.spawner.spawnedCount, greaterThan(100));
        expect(game.spawner.active.length, lessThan(40));
        expect(game.world.children.whereType<Object>().length, lessThan(80));
      },
    );
  });
}
