import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flame/effects.dart';
import 'package:flame/geometry.dart';

export 'package:flame/flame.dart';
export 'package:flame/game.dart';
export 'package:flame/components.dart';
export 'package:flame/events.dart';
export 'package:flame/palette.dart';
export 'package:flame/effects.dart';
export 'package:flame/geometry.dart';
export 'package:flame/experimental.dart';
export 'package:flame/extensions.dart';
export 'package:flame/collisions.dart';
export 'package:flame/palette.dart';
export 'package:flame/particles.dart';
export 'package:flame/particles.dart';
export 'src/debug/child_counter_component.dart';
export 'src/debug/time_track_component.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/22
///

//#region sample

/// 创建一个游戏世界
///
/// # 碰撞检测
/// https://docs.flame-engine.org/latest/flame/collision_detection.html
/// - [HasCollisionDetection]
/// - [CollisionCallbacks]
///
/// # 路由
///
/// https://docs.flame-engine.org/latest/flame/router.html
///
/// - [RouterComponent]
///
Widget createGameWorld<W extends World, T extends Game>(
  W? world, {
  T? game,
  bool debugMode = false,
}) {
  //ChildCounterComponent();
  //TimeTrackComponent();

  /*final effect = ScaleEffect.to(
    Vector2.all(0.5),
    EffectController(duration: 0.5),
  );*/
  return GameWidget(
    game: game ?? (FlameGame(world: world)..debugMode = debugMode),
  );
}

//#endregion
