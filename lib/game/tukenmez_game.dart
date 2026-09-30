import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../app/palette.dart';
import '../app/paper_theme.dart';
import '../domain/scoring/ink_state.dart';
import '../domain/scoring/level_score.dart';
import 'components/effects/floating_text.dart';
import 'components/effects/notification_bubble.dart';
import 'components/effects/paper_decal.dart';
import 'components/effects/stamp.dart';
import 'components/ink_trail.dart';
import 'components/lane_object.dart';
import 'components/paper_background.dart';
import 'components/pen.dart';
import 'components/spawner.dart';
import 'config/game_config.dart';
import 'config/item_catalog.dart';
import 'doodle/art_cache.dart';
import 'doodle/item_art.dart';
import 'hud_state.dart';
import 'input/input_buffer.dart';
import 'input/swipe_detector.dart';
import 'level_setup.dart';
import 'page_map.dart';
import 'systems/collision_rules.dart';
import 'systems/effect_state.dart';
import 'systems/lane_system.dart';
import 'systems/speed_curve.dart';

enum RunState { ready, running, finished }

/// Haptik geri bildirim için oyun olayları (ses de Faz 5'te buraya bağlanır).
enum GameFeedback { collect, hit }

/// Katman sırası (world içindeki öncelikler).
abstract final class Layers {
  static const paper = 0;
  static const decals = 1;
  static const trail = 2;
  static const objects = 3;
  static const pen = 4;
  static const popups = 5;
  static const overlay = 6;
}

/// Tek bir level (sınav). Kamera ve kalem sabittir; kayan olan içeriktir.
class TukenmezGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  TukenmezGame(this.setup, {this.onFinished});

  static const overlayStart = 'start';
  static const overlayHud = 'hud';
  static const overlayPause = 'pause';
  static const overlaySummary = 'summary';

  final LevelSetup setup;
  void Function(LevelOutcome outcome)? onFinished;
  void Function(GameFeedback feedback)? onFeedback;

  GameConfig get config => setup.config;
  ItemCatalog get catalog => setup.catalog;

  late final LaneSystem lanes = LaneSystem(
    laneCount: config.laneCount,
    laneWidth: config.laneWidth,
    worldWidth: config.worldWidth,
  );
  late final SpeedCurve curve = SpeedCurve(
    setup.level.speed,
    semesterMultiplier: setup.semesterMultiplier,
  );
  late final InkState ink = InkState(
    max: config.inkMax,
    lowThreshold: config.inkLowThreshold,
  );
  final LevelScoreTracker tracker = LevelScoreTracker();
  final EffectState effects = EffectState();
  final HudState hud = HudState();
  late final SwipeDetector swipe = SwipeDetector(
    minDistance: config.minSwipeDistance,
    minFlingVelocity: config.minFlingVelocity,
  );
  late final InputBuffer inputBuffer = InputBuffer(config.inputBufferSeconds);
  late final Random rng = Random(setup.level.seed);
  late final ArtCache art = ArtCache(
    variants: config.boilVariants,
    wobble: config.wobble,
    text: ArtText(friendBubble: setup.strings.friendBubble),
  );
  late final PageMap pageMap = PageMap(
    width: config.worldWidth,
    totalDistance: setup.plan.totalDistance,
    sampleDistance: config.mapSampleDistance,
    maxSamples: config.maxMapPoints,
  );

  late final Pen pen;
  late final Spawner spawner;
  late final NotificationBubble notification;
  Stamp? _finalStamp;

  RunState state = RunState.ready;
  LevelOutcome? outcome;

  /// Toplam kaydırma mesafesi (dünya birimi).
  double distance = 0;

  /// Bu karedeki kaydırma miktarı.
  double scrollDelta = 0;

  /// Animasyon saati; oyun hazır beklerken de akar.
  double animTime = 0;

  double viewWidth = 0;
  double viewHeight = 0;
  double viewLeft = 0;
  double _shakeLeft = 0;

  double get totalDistance => setup.plan.totalDistance;
  double get progress => (distance / totalDistance).clamp(0.0, 1.0);
  double get penY => viewHeight - config.penTipFromBottom;
  int get boilFrame => (animTime * config.boilFps).floor();

  /// Dünya koordinatında ekranın alt kenarı.
  double get viewBottom => viewHeight;

  /// Belirli bir kaydırma mesafesine bağlı bir noktanın ekrandaki y'si.
  double yForDistance(double d) => penY - (d - distance);

  @override
  Color backgroundColor() => PaperTheme.of(setup.paper).endShade;

  @override
  Future<void> onLoad() async {
    _layout(size);
    camera.viewfinder.anchor = Anchor.topLeft;
    _applyCamera(Vector2.zero());
    pen = Pen()..priority = Layers.pen;
    spawner = Spawner(setup.plan.events);
    notification = NotificationBubble()..priority = Layers.overlay;
    world.addAll([
      PaperBackground()..priority = Layers.paper,
      InkTrail()..priority = Layers.trail,
      spawner,
      pen,
      notification,
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout(size);
    if (isLoaded) _applyCamera(Vector2.zero());
  }

  void _layout(Vector2 canvas) {
    if (canvas.x <= 0 || canvas.y <= 0) return;
    final zoom = min(
      canvas.x / config.worldWidth,
      canvas.y / config.minVisibleHeight,
    );
    viewWidth = canvas.x / zoom;
    viewHeight = canvas.y / zoom;
    viewLeft = -(viewWidth - config.worldWidth) / 2;
    camera.viewfinder.zoom = zoom;
  }

  void _applyCamera(Vector2 shake) {
    camera.viewfinder.position = Vector2(viewLeft + shake.x, shake.y);
  }

  void start() {
    if (state != RunState.ready) return;
    state = RunState.running;
    overlays
      ..remove(overlayStart)
      ..add(overlayHud);
  }

  void pauseGame() {
    if (state != RunState.running || paused) return;
    pauseEngine();
    overlays.add(overlayPause);
  }

  void resumeGame() {
    overlays.remove(overlayPause);
    resumeEngine();
  }

  @override
  void update(double dt) {
    animTime += dt;
    scrollDelta = 0;
    if (state == RunState.running) _step(dt);
    super.update(dt);
    if (state == RunState.running) _checkEnd();
  }

  void _step(double dt) {
    effects.update(dt);
    final speed =
        config.baseSpeed * curve.multiplierAt(progress) * effects.timeScale;
    scrollDelta = speed * dt;
    distance += scrollDelta;
    inputBuffer.update(dt, _tryExecute);
    spawner.advance();
    pageMap.sample(pen.x, distance, pen.pose == PenPose.airborne);

    if (_finalStamp == null && progress >= config.finalStretchProgress) {
      _finalStamp = Stamp(setup.strings.finalStretch)
        ..priority = Layers.overlay
        ..position = Vector2(config.worldWidth - 70, 70);
      world.add(_finalStamp!);
    }

    if (_shakeLeft > 0) {
      _shakeLeft -= dt;
      final a = config.shakeAmplitude * (_shakeLeft / config.shakeSeconds);
      _applyCamera(
        _shakeLeft > 0
            ? Vector2(
                (rng.nextDouble() * 2 - 1) * a,
                (rng.nextDouble() * 2 - 1) * a,
              )
            : Vector2.zero(),
      );
    }

    hud.update(
      rawPoints: tracker.rawPoints,
      maxPoints: tracker.maxPoints,
      inkFraction: ink.fraction,
      isInkLow: ink.isLow,
      progressValue: progress,
      multiplier: effects.scoreMultiplier > 1,
      slow: effects.timeScale < 1,
      reverse: effects.controlsReversed,
    );
  }

  void _checkEnd() {
    if (ink.isEmpty) {
      _finish();
    } else if (distance >= totalDistance) {
      _finish();
    }
  }

  void _finish() {
    state = RunState.finished;
    final result = tracker.finish(
      rules: setup.scoreRules,
      inkRemaining: ink.current,
      inkDepleted: ink.isEmpty,
    );
    final o = LevelOutcome(
      score: result,
      inkRemaining: ink.current,
      collectedCount: tracker.collectedCount,
      hitCount: tracker.hitCount,
      bonusCount: tracker.bonusCount,
      map: pageMap,
    );
    outcome = o;
    overlays
      ..remove(overlayHud)
      ..remove(overlayPause)
      ..add(overlaySummary);
    onFinished?.call(o);
  }

  // ---------------------------------------------------------------- girdi

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    swipe.start();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final d = swipe.update(event.deviceDelta.x, event.deviceDelta.y);
    if (d != null) handleSwipe(d);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    final d = swipe.end(event.velocity.x, event.velocity.y);
    if (d != null) handleSwipe(d);
  }

  /// Swipe'ı (debuff'ları hesaba katarak) kaleme iletir.
  void handleSwipe(SwipeDirection direction) {
    if (state != RunState.running) return;
    var d = direction;
    if (effects.controlsReversed) {
      d = switch (d) {
        SwipeDirection.left => SwipeDirection.right,
        SwipeDirection.right => SwipeDirection.left,
        _ => d,
      };
    }
    if (!_tryExecute(d)) inputBuffer.push(d);
  }

  bool _tryExecute(SwipeDirection d) => switch (d) {
    SwipeDirection.left => pen.changeLane(-1),
    SwipeDirection.right => pen.changeLane(1),
    SwipeDirection.up => pen.tryJump(),
    SwipeDirection.down => pen.duckOrFastFall(),
  };

  // ------------------------------------------------------------ çarpışma

  void handleContact(LaneObject obj) {
    if (obj.resolved || state != RunState.running) return;
    final def = obj.def;
    switch (CollisionRules.resolve(def.kind, pen.pose)) {
      case ContactOutcome.ignore:
        return;
      case ContactOutcome.collect:
        obj.resolved = true;
        _collect(def, obj.position);
        obj.removeFromParent();
      case ContactOutcome.hit:
        obj.resolved = true;
        _hit(def, obj);
    }
  }

  /// (+) popup rengi: koyu kağıtta mürekkep mavisi okunmaz.
  late final Color _positive = PaperTheme.of(setup.paper).isDark
      ? PaperTheme.of(setup.paper).trail
      : Palette.ink;

  void _collect(ItemDef def, Vector2 at) {
    final strings = setup.strings;
    switch (def.kind) {
      case ItemKind.collectible:
        final mult = effects.scoreMultiplier;
        tracker.collect(def.points, multiplier: mult);
        _popup('+${(def.points * mult).round()}', at, _positive);
      case ItemKind.bonus:
        tracker.addExtraCredit(def.extraCredit);
        _popup(
          strings.extraCredit.replaceAll('{n}', '${def.extraCredit.round()}'),
          at,
          Palette.teacherRed,
        );
      case ItemKind.powerUp:
        final e = def.effect!;
        switch (e.type) {
          case EffectType.scoreMultiplier:
            effects.startMultiplier(e.value, e.duration);
            _popup(strings.doublePoints, at, _positive);
          case EffectType.slowMotion:
            effects.startSlow(e.value, e.duration);
            _popup(strings.focusMode, at, Palette.coffee);
          case EffectType.ink:
            ink.apply(e.value);
            _popup(
              strings.inkRefill.replaceAll('{n}', '${e.value.round()}'),
              at,
              Palette.ink,
            );
          default:
            break;
        }
      default:
        break;
    }
    world.add(
      PaperDecal(MapMarkerKind.star, pen.x, distance)..priority = Layers.decals,
    );
    pageMap.mark(pen.x, distance, MapMarkerKind.star);
    onFeedback?.call(GameFeedback.collect);
  }

  void _hit(ItemDef def, LaneObject obj) {
    tracker.penalize(def.points);
    ink.apply(def.ink);
    _shakeLeft = config.shakeSeconds;
    _popup('${def.points.round()}', obj.position, Palette.teacherRed);
    world.add(
      PaperDecal(MapMarkerKind.stain, pen.x, distance)
        ..priority = Layers.decals,
    );
    pageMap.mark(pen.x, distance, MapMarkerKind.stain);
    onFeedback?.call(GameFeedback.hit);

    final e = def.effect;
    switch (e?.type) {
      case EffectType.notification:
        effects.startNotification(e!.duration);
        notification.show(rng.nextBool());
      case EffectType.reverseControls:
        effects.startReverse(e!.duration);
      case EffectType.pullLane:
        final lane = pen.targetLane;
        final dir = lane == 0
            ? 1
            : lane == config.laneCount - 1
            ? -1
            : (rng.nextBool() ? 1 : -1);
        pen.forceLane(lane + dir);
      default:
        break;
    }
    if (def.kind == ItemKind.distraction) {
      obj.removeFromParent();
    } else {
      pen.stumble();
      obj.markHit();
    }
  }

  void _popup(String text, Vector2 at, Color color) {
    world.add(
      FloatingText(text, color, duration: config.popupSeconds)
        ..priority = Layers.popups
        ..position = Vector2(at.x, at.y - 20),
    );
  }

  @override
  void onRemove() {
    art.dispose();
    super.onRemove();
  }
}
