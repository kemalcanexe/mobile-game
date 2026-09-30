import 'json_read.dart';

/// assets/config/game.json: oyun hissini belirleyen bütün sabitler.
class GameConfig {
  GameConfig._(JsonReader r)
    : worldWidth = r.object('world').number('width'),
      minVisibleHeight = r.object('world').number('minVisibleHeight'),
      laneCount = r.object('world').integer('laneCount'),
      laneWidth = r.object('world').number('laneWidth'),
      penTipFromBottom = r.object('world').number('penTipFromBottom'),
      spawnMarginTop = r.object('world').number('spawnMarginTop'),
      despawnMarginBottom = r.object('world').number('despawnMarginBottom'),
      baseSpeed = r.object('scroll').number('baseSpeed'),
      rowSpacing = r.object('scroll').number('rowSpacing'),
      warmupSeconds = r.object('scroll').number('warmupSeconds'),
      endMarginRows = r.object('scroll').integer('endMarginRows'),
      finalStretchProgress = r.object('scroll').number('finalStretchProgress'),
      laneChangeSeconds = r.object('pen').number('laneChangeSeconds'),
      jumpSeconds = r.object('pen').number('jumpSeconds'),
      duckSeconds = r.object('pen').number('duckSeconds'),
      stumbleSeconds = r.object('pen').number('stumbleSeconds'),
      jumpScale = r.object('pen').number('jumpScale'),
      penHitboxWidth = r.object('pen').number('hitboxWidth'),
      penHitboxHeight = r.object('pen').number('hitboxHeight'),
      objectSize = r.object('objects').number('size'),
      wallSize = r.object('objects').number('wallSize'),
      objectHitboxInset = r.object('objects').number('hitboxInset'),
      minSwipeDistance = r.object('input').number('minSwipeDistance'),
      minFlingVelocity = r.object('input').number('minFlingVelocity'),
      inputBufferSeconds = r.object('input').number('bufferSeconds'),
      inkMax = r.object('ink').number('max'),
      inkLowThreshold = r.object('ink').number('lowThreshold'),
      trailSampleDistance = r.object('trail').number('sampleDistance'),
      trailMaxPoints = r.object('trail').integer('maxPoints'),
      trailStrokeWidth = r.object('trail').number('strokeWidth'),
      mapSampleDistance = r.object('trail').number('mapSampleDistance'),
      maxMapPoints = r.object('trail').integer('maxMapPoints'),
      boilFps = r.object('doodle').number('boilFps'),
      boilVariants = r.object('doodle').integer('boilVariants'),
      wobble = r.object('doodle').number('wobble'),
      shakeSeconds = r.object('juice').number('shakeSeconds'),
      shakeAmplitude = r.object('juice').number('shakeAmplitude'),
      popupSeconds = r.object('juice').number('popupSeconds');

  factory GameConfig.fromJson(Map<String, dynamic> json) =>
      GameConfig._(JsonReader(json, 'game.json'));

  final double worldWidth;
  final double minVisibleHeight;
  final int laneCount;
  final double laneWidth;
  final double penTipFromBottom;
  final double spawnMarginTop;
  final double despawnMarginBottom;

  final double baseSpeed;
  final double rowSpacing;
  final double warmupSeconds;
  final int endMarginRows;
  final double finalStretchProgress;

  final double laneChangeSeconds;
  final double jumpSeconds;
  final double duckSeconds;
  final double stumbleSeconds;
  final double jumpScale;
  final double penHitboxWidth;
  final double penHitboxHeight;

  final double objectSize;
  final double wallSize;
  final double objectHitboxInset;

  final double minSwipeDistance;
  final double minFlingVelocity;
  final double inputBufferSeconds;

  final double inkMax;
  final double inkLowThreshold;

  final double trailSampleDistance;
  final int trailMaxPoints;
  final double trailStrokeWidth;
  final double mapSampleDistance;
  final int maxMapPoints;

  final double boilFps;
  final int boilVariants;
  final double wobble;

  final double shakeSeconds;
  final double shakeAmplitude;
  final double popupSeconds;
}
