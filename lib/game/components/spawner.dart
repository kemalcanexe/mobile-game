import 'package:flame/components.dart';

import '../systems/level_generator.dart';
import '../tukenmez_game.dart';
import 'lane_object.dart';

/// Spawn planını tüketir: nesneleri ekranın üstünde doğurur, aşağıda toplar.
/// Nesneler havuzdan gelir; her karede yeni nesne yaratılmaz.
class Spawner extends Component with HasGameReference<TukenmezGame> {
  Spawner(this.events);

  final List<SpawnEvent> events;
  int _next = 0;
  final List<LaneObject> active = [];
  final List<LaneObject> _pool = [];
  int _spawned = 0;

  int get spawnedCount => _spawned;

  void advance() {
    final g = game;
    final c = g.config;
    final ahead = g.penY + c.spawnMarginTop;
    while (_next < events.length &&
        events[_next].distance - g.distance <= ahead) {
      _spawn(events[_next++]);
    }
    final limit = g.viewBottom + c.despawnMarginBottom;
    for (var i = active.length - 1; i >= 0; i--) {
      final obj = active[i];
      obj.position.setValues(
        g.lanes.laneX(obj.lane),
        g.yForDistance(obj.eventDistance),
      );
      if (obj.y > limit) {
        active.removeAt(i);
        obj.removeFromParent();
      }
    }
  }

  void _spawn(SpawnEvent e) {
    final g = game;
    final def = g.catalog[e.code];
    final obj = _pool.isNotEmpty ? _pool.removeLast() : LaneObject();
    obj
      ..onRecycle = _recycle
      ..priority = Layers.objects;
    // reset `game` referansı gerektirir; ilk kullanımda parent atanmadan
    // önce HasGameReference oyunu bulamaz, bu yüzden açıkça verilir.
    obj.game = g;
    obj.reset(def, e.lane, e.distance, _spawned);
    obj.position.setValues(g.lanes.laneX(e.lane), g.yForDistance(e.distance));
    if (def.countsTowardMax) g.tracker.registerSpawn(def.points);
    _spawned++;
    active.add(obj);
    g.world.add(obj);
  }

  void _recycle(LaneObject obj) {
    active.remove(obj);
    _pool.add(obj);
  }
}
