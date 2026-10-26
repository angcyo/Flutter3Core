import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layout.dart';
import 'package:flutter/widgets.dart' as ui;
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

export 'package:flame/camera.dart';
export 'package:flame/collisions.dart';
export 'package:flame/components.dart';
export 'package:flame/effects.dart';
export 'package:flame/events.dart';
export 'package:flame/experimental.dart';
export 'package:flame/extensions.dart';
export 'package:flame/flame.dart';
export 'package:flame/game.dart';
export 'package:flame/geometry.dart';
export 'package:flame/input.dart' hide ButtonState;
export 'package:flame/palette.dart';
export 'package:flame/parallax.dart';
export 'package:flame/particles.dart';
export 'package:flame/layout.dart';

export 'src/debug/child_counter_component.dart';
export 'src/debug/time_track_component.dart';
export 'src/flame/audio/audio.dart';
export 'src/flame/components/flame_text_component.dart';
export 'src/flame/components/flow_component.dart';
export 'src/flame/components/fullscreen_route.dart';
export 'src/flame/components/split_layout.dart';
export 'src/widgets/widgets.dart';

// @formatter:off

part 'src/flame/component_mix.dart';
part 'src/flame/flame_mix.dart';
part 'src/flame/sprite_mix.dart';

// @formatter:on

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/22
///

//#region sample

const bool isDebugMode = fb.isDebug;

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
ui.Widget createGameWorld<W extends World, T extends Game>(
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
  //CircularViewport();

  //AlignComponent

  return GameWidget(
    game: game ?? (FlameGame(world: world)..debugMode = debugMode),
  );
}

//#endregion
