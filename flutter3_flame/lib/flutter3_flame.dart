import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layout.dart';
import 'package:flame_forge2d/contact.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flutter/widgets.dart' as ui;
import 'package:flutter3_basics/flutter3_basics.dart' as fb;
import 'package:forge2d/forge2d.dart' as fd;

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
export 'package:flame/layout.dart';
export 'package:flame/palette.dart';
export 'package:flame/parallax.dart';
export 'package:flame/particles.dart';
export 'package:flame_forge2d/body_component.dart';
export 'package:flame_forge2d/forge2d_game.dart';
export 'package:flame_forge2d/forge2d_world.dart';

export 'src/debug/child_counter_component.dart';
export 'src/debug/time_track_component.dart';
export 'src/flame/audio/audio.dart';
export 'src/flame/components/flame_text_component.dart';
export 'src/flame/components/flow_component.dart';
export 'src/flame/components/fullscreen_route.dart';
export 'src/flame/components/split_layout.dart';
export 'src/flame/forge2d/forge2d_mix.dart';
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

typedef FBody = fd.Body;
typedef FBodyDef = fd.BodyDef;
typedef FShapeDef = fd.ShapeDef;
typedef FPolygon = fd.Polygon;
typedef FContactCallbacks = ContactCallbacks;
typedef FContact = Contact;

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
ui.Widget createGameWorld<W extends World, T extends Game>(W? world, {
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
    game: game ?? (FlameGame(world: world)
      ..debugMode = debugMode),
  );
}

/// 使用两个点之间的位移计算冲量
/// 弹弓式发射：拖得越远，发射越快
Vector2 calculateImpulse(Vector2 p1, Vector2 p2,
    {double strength = 5.0, double maxImpulse = 30.0}) {
  final impulse = (p1 - p2) * strength;

  // 限制最大冲量，避免拖动距离过大导致物体飞得过远。
  final length = impulse.length;
  if (length > maxImpulse) {
    impulse.scale(maxImpulse / length);
  }

  return impulse;
}

/// 根据拖动时间，计算发射的力度
///
/// 拖动时间	计算结果
/// 50 ms	20.0（达到上限）
/// 100 ms	20.0
/// 200 ms	20.0
/// 300 ms	20.0
/// 500 ms	12.0
/// 1000 ms	6.0
/// 2000 ms	3.0
///
/// ```
/// double calculateStrength(
///   Duration dragDuration, {
///   double minStrength = 2.0,
///   double maxStrength = 20.0,
///   double referenceMs = 300.0,
/// }) {
///   final ms = dragDuration.inMilliseconds
///       .toDouble()
///       .clamp(1.0, double.infinity);
///
///   // 时间越短，strength 越大
///   final strength = maxStrength * referenceMs / ms;
///
///   return strength.clamp(minStrength, maxStrength);
/// }
/// ```
///
/// 此时：
/// - 100 ms 或更短：strength = 20
/// - 550 ms：strength = 11
/// - 1000 ms 或更长：strength = 2
double calculateStrength(Duration dragDuration, {
  double minStrength = 2.0,
  double maxStrength = 20.0,
  double minDurationMs = 100.0,
  double maxDurationMs = 1000.0,
}) {
  final ms = dragDuration.inMilliseconds.toDouble();

  final t = ((maxDurationMs - ms) /
      (maxDurationMs - minDurationMs))
      .clamp(0.0, 1.0);

  return minStrength + (maxStrength - minStrength) * t;
}

/// 根据半径和质量，计算密度
/// - [radius] 半径
/// - [mass] 质量
double densityForMass(double radius, double mass) {
  return mass / (fb.$pi * radius * radius);
}

//#endregion
