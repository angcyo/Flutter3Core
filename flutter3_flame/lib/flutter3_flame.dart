import 'dart:developer';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layout.dart';
import 'package:flame_forge2d/contact.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/forge2d_viewfinder.dart';
import 'package:flame_forge2d/forge2d_world.dart';
import 'package:flutter/painting.dart';
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

export 'src/combat/combat_system.dart';
export 'src/debug/child_counter_component.dart';
export 'src/debug/time_track_component.dart';
export 'src/flame/base_flame_game.dart';
export 'src/flame/base_flame_world.dart';
export 'src/flame/audio/audio.dart';
export 'src/flame/components/animated_number_component.dart';
export 'src/flame/components/countdown_component.dart';
export 'src/flame/components/damage_text_component.dart';
export 'src/flame/components/flame_text_component.dart';
export 'src/flame/components/flow_component.dart';
export 'src/flame/components/fullscreen_route.dart';
export 'src/flame/components/split_layout.dart';
export 'src/flame/components/sprite_state_mixin.dart';
export 'src/flame/components/tap_move_mixin.dart';
export 'src/flame/components/game_button_component.dart';
export 'src/flame/core/game_colors.dart';
export 'src/flame/core/text_align_paint.dart';
export 'src/flame/effects/blink_effect.dart';
export 'src/flame/effects/interval_effect.dart';
export 'src/flame/effects/off_screen_remove_effect.dart';
export 'src/flame/forge2d/forge2d_mix.dart';
export 'src/scheduler/game_phase.dart';
export 'src/scheduler/game_timeline.dart';
export 'src/scheduler/time_scheduler.dart';
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
typedef FShapeGeometry = fd.ShapeGeometry;
typedef FPolygon = fd.Polygon;
typedef FSegment = fd.Segment;
typedef FCapsule = fd.Capsule;
typedef FCircle = fd.Circle;
typedef FShape = fd.Shape;
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

/// 使用两个点之间的位移计算冲量
/// 弹弓式发射：拖得越远，发射越快
Vector2 calculateImpulse(
  Vector2 p1,
  Vector2 p2, {
  double strength = 5.0,
  double maxImpulse = 30.0,
}) {
  final impulse = (p1 - p2) * strength;

  // 限制最大冲量，避免拖动距离过大导致物体飞得过远。
  final length = impulse.length;
  if (length > maxImpulse) {
    impulse.scale(maxImpulse / length);
  }

  return impulse;
}

/// 根据冲量, 质量计算速度
/// - [impulse] 冲量
/// - [mass] 质量
/// @return 增量的速度, 如果有原始速度, 则需要累加
Vector2 calculateVelocity(Vector2 impulse, double mass) {
  debugger(when: mass <= 0);
  return impulse / mass.ensureValid(1);
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
double calculateStrength(
  Duration dragDuration, {
  double minStrength = 2.0,
  double maxStrength = 20.0,
  double minDurationMs = 100.0,
  double maxDurationMs = 1000.0,
}) {
  final ms = dragDuration.inMilliseconds.toDouble();

  final t = ((maxDurationMs - ms) / (maxDurationMs - minDurationMs)).clamp(
    0.0,
    1.0,
  );

  return minStrength + (maxStrength - minStrength) * t;
}

/// 根据半径和质量，计算密度
/// - [radius] 半径
/// - [mass] 质量
double densityForMass(double radius, double mass) {
  return mass / (fb.$pi * radius * radius);
}

/// 预测轨迹
List<Vector2> predictTrajectory({
  required Vector2 start,
  required Vector2 velocity,
  required double gravity,
  double duration = 2.0,
  double step = 0.05,
  //--边界
  Vector2? min,
  Vector2? max,
}) {
  final points = <Vector2>[];

  for (double t = 0; t <= duration; t += step) {
    final x = start.x + velocity.x * t;
    final y = start.y + velocity.y * t + 0.5 * gravity * t * t;
    points.add(Vector2(x, y));
    if (min != null && max != null) {
      if (x < min.x || x > max.x || y < min.y || y > max.y) {
        break;
      }
    }
  }

  return points;
}

/// 生成弧形的折点坐标 / 多边形
/// 计算圆弧的所有折点，包含起点和终点。
///
/// [start]      圆弧起点
/// [center]     圆心
/// [sweepAngle] 扫过的角度，单位为弧度；正值沿屏幕顺时针方向旋转, 负值沿屏幕逆时针方向旋转
/// [segments]   分段数，必须大于 0
///
/// 返回 segments + 1 个点。
List<Vector2> generateArcPoints({
  required Vector2 start,
  required Vector2 center,
  required double sweepAngle,
  int segments = 16,
}) {
  if (segments <= 0) {
    throw ArgumentError.value(segments, 'segments', '必须大于 0');
  }

  final dx = start.x - center.x;
  final dy = start.y - center.y;
  final radius = math.sqrt(dx * dx + dy * dy);

  if (radius == 0) {
    throw ArgumentError('起点不能与圆心重合');
  }

  // 起点相对于圆心的初始角度
  final startAngle = math.atan2(dy, dx);

  // 每段扫过的角度
  final angleStep = sweepAngle / segments;

  return List.generate(segments + 1, (i) {
    final angle = startAngle + angleStep * i;

    return Vector2(
      center.x + radius * math.cos(angle),
      center.y + radius * math.sin(angle),
    );
  });
}

/// 根据中心坐标和半径生成椭圆折点。
///
/// center   : 椭圆中心坐标
/// rx       : X 轴半径
/// ry       : Y 轴半径
/// segments : 分段数
///
/// 返回 segments 个折点，不重复最后一个闭合点。
List<Vector2> generateEllipsePoints({
  required Vector2 center,
  required double rx,
  required double ry,
  int segments = 64,
}) {
  if (rx <= 0 || ry <= 0) {
    throw ArgumentError('rx 和 ry 必须大于 0');
  }

  if (segments < 3) {
    throw ArgumentError('segments 必须大于等于 3');
  }

  return List.generate(segments, (i) {
    final angle = 2 * math.pi * i / segments;

    final x = center.x + rx * math.cos(angle);
    final y = center.y + ry * math.sin(angle);

    return Vector2(x, y);
  });
}

/// 根据宽高生成箭的多边形折点。
///
/// width  : 箭的总长度
/// height : 箭的最大高度
///
/// 返回箭的多边形顶点，箭头朝右。
List<Vector2> generateArrowPoints({
  required double width,
  required double height,
  double? maxHeadWidth,
  double? maxTailWidth,
  double? headLength,
  double? tailLength,
  double? shaftWidth,
}) {
  assert(width > 0 && height > 0);

  // 箭头、箭尾的最大高度
  final headW = min(maxHeadWidth ?? height * 0.9, height);
  final tailW = min(maxTailWidth ?? height * 0.7, height);

  // 箭头和箭尾长度
  final headL = min(headLength ?? width * 0.25, width * 0.5);
  final tailL = min(tailLength ?? width * 0.18, width * 0.5);

  // 箭身宽度：不会超过箭头和箭尾宽度
  final bodyW = min(shaftWidth ?? min(headW, tailW) * 0.18, min(headW, tailW));

  final cy = height / 2;

  // X 轴分段
  final x0 = 0.0;
  final x1 = tailL;
  final x2 = width - headL;
  final x3 = width;

  final points = <Vector2>[
    // 箭尾
    Vector2(x0, cy - tailW / 2),
    Vector2(x1, cy - bodyW / 2),

    // 箭身
    Vector2(x2, cy - bodyW / 2),

    // 箭头
    Vector2(x2, cy - headW / 2),
    Vector2(x3, cy),

    Vector2(x2, cy + headW / 2),

    // 箭身
    Vector2(x2, cy + bodyW / 2),
    Vector2(x1, cy + bodyW / 2),

    // 箭尾
    Vector2(x0, cy + tailW / 2),
  ];

  return points;
}

//#endregion
