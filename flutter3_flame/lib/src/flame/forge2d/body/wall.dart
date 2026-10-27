import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

import 'glowing_body.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/26
///
/// 游戏中的一堵墙
class Wall extends BodyComponent with GlowingBody {
  final double strokeWidth;
  final Vector2 start;
  final Vector2 end;
  final Color color;
  final String? tag;

  Wall({
    required this.start,
    required this.end,
    @fb.defInjectMark double? strokeWidth,
    @fb.defInjectMark Color? color,
    this.tag,
  }) : strokeWidth = strokeWidth ?? 0.15,
       color = color ?? Color(0xFF64748B) {
    paint = Paint()
      ..color = this.color
      ..strokeCap = .round
      ..strokeJoin = .round;
  }

  @override
  double get outlineWidth => strokeWidth;

  /// 创建物理体 / 刚体
  /// https://box2d.org/documentation/group__body.html
  @override
  Body createBody() {
    // The default material gives the walls enough grip for bodies to come
    // to rest against them instead of sliding along.
    final shapeDef = ShapeDef(enableContactEvents: true);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: Vector2.zero(),
    );
    return world.createBody(bodyDef)
      ..createShape(Segment(point1: start, point2: end), shapeDef);
  }

  /// 当从世界中移除时
  @override
  void onRemove() {
    super.onRemove();
  }

  @override
  String toString() {
    return tag ?? '墙(start: $start, end: $end, color: $color)';
  }
}
