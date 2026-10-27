import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/26
///
/// 游戏中的一个桶
class Bucket extends BodyComponent with ContactCallbacks {
  @fb.mm
  final double width;
  @fb.mm
  final double height;

  /// 桶壁的厚度, 用来判断在桶内
  @fb.mm
  final double wallThickness;

  @fb.mm
  final double cornerRadius;
  final int arcSegments;

  //--
  final Color color;

  final double bodyAngle;
  final Vector2 bodyPosition;

  /// 桶的材质, 摩擦力 / 反弹力 / 阻力
  @fb.defInjectMark
  final SurfaceMaterial? material;

  /// 桶内[BodyComponent]元素改变通知
  void Function(List<Object>)? onBucketBodyChanged;

  Bucket({
    this.width = 1.0,
    this.height = 0.5,
    this.wallThickness = 0.05,
    double? cornerRadius,
    this.arcSegments = 12,
    double angle = -0.3,
    Vector2? position,
    Color? color,
    this.material,
    this.onBucketBodyChanged,
    super.priority,
  }) : bodyAngle = angle,
       bodyPosition = position ?? Vector2.zero(),
       color = color ?? Colors.redAccent,
       cornerRadius = cornerRadius ?? math.min(width, height) / 2;

  Vector2 get bucketSize => Vector2(width, height);

  /// 这里绘制的坐标也是mm坐标
  @override
  void render(Canvas canvas) {
    //super.render(canvas);
    if (renderBody) {
      for (final shape in body.shapes) {
        if (!shape.isSensor || debugMode) {
          paint.color = shape.isSensor ? color.withAlpha(40) : color;
          renderShape(canvas, shape);
        }
      }
    }
    if (debugMode) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, bucketSize.x, bucketSize.y),
        Paint()
          ..color = debugColor
          ..strokeWidth = 0
          ..style = .stroke,
      );
      /*final size = body.getSize();
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color = debugColor
          ..strokeWidth = 0
          ..style = .stroke,
      );*/
    }
  }

  @override
  void renderDebugMode(Canvas canvas) {
    //super.renderDebugMode(canvas);
  }

  @override
  Body createBody() {
    assert(width > 0 && height > 0);
    assert(cornerRadius > 0);
    assert(cornerRadius <= width / 2);
    assert(cornerRadius <= height / 2);
    assert(arcSegments >= 2);

    final halfW = width / 2;
    final halfH = height / 2;
    final r = cornerRadius;
    final left = 0.0;
    final right = width;
    final top = 0.0;
    final bottom = height - r * 2;

    // 所有点均为桶自身的局部坐标。
    final points = <Vector2>[];

    // 左侧直壁的上端。
    points.add(Vector2(left, top));

    // 左侧直壁延伸到左下圆弧起点。
    points.add(Vector2(left, bottom + r));

    // 左下圆弧：从左侧平滑过渡到桶底。
    for (var i = 1; i <= arcSegments; i++) {
      final t = math.pi - (math.pi / 2) * i / arcSegments;

      points.add(
        Vector2(left + r + r * math.cos(t), bottom + r + r * math.sin(t)),
      );
    }

    // 右下圆弧：从桶底平滑过渡到右侧壁。
    for (var i = 1; i <= arcSegments; i++) {
      final t = math.pi / 2 - (math.pi / 2) * i / arcSegments;

      points.add(
        Vector2(right - r + r * math.cos(t), bottom + r + r * math.sin(t)),
      );
    }

    // 右侧直壁的上端。
    points.add(Vector2(right, top));

    //--

    // 创建静态桶体，并设置整体旋转。
    final body = world.createBody(
      BodyDef(
        type: .static,
        position: bodyPosition,
        rotation: Rot.fromAngle(bodyAngle),
        userData: this,
      ),
    );

    final shapeDef = ShapeDef(
      material: material ?? SurfaceMaterial(friction: 0.6, restitution: 0.05),
      userData: null,
      enableSensorEvents: false,
      enableContactEvents: false,
      enableHitEvents: false,
    );

    // 每两个相邻点构成一段碰撞边界。
    for (var i = 0; i < points.length - 1; i++) {
      body.createShape(
        Segment(point1: points[i], point2: points[i + 1]),
        shapeDef,
      );
    }

    // 创建一个传感器, 用来检测球是否在桶内。
    final sensorShapeDef = ShapeDef(
      /*userData: runtimeType,*/
      /*userData: this,*/
      isSensor: true,
      enableContactEvents: false,
      enableSensorEvents: true,
    );
    final wl = left + wallThickness;
    final tp = top + wallThickness;
    final wr = right - wallThickness;
    final wb = height - wallThickness;
    final sr = r / 2;
    body.createShape(
      Polygon([
        Vector2(wl, tp),
        Vector2(wl, wb - sr),
        Vector2(wl + sr, wb),
        Vector2(wr - sr, wb),
        Vector2(wr, wb - sr),
        Vector2(wr, tp),
      ]),
      sensorShapeDef,
    );

    return body;
  }

  /// 桶内的[BodyComponent]元素
  final List<Object> _bucketBody = [];

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    /*final isSensor1 = contact.shapeA.isSensor;
    final isSensor2 = contact.shapeB.isSensor;
    final isSensorEvent = contact.isSensorEvent;
    final userDatas = contact.userDatas;*/
    //debugger(when: isSensor1 || isSensor2 || isSensorEvent);
    if (contact.isSensorEvent) {
      _bucketBody.add(other);
      onBucketBodyChanged?.call(_bucketBody);
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    /*assert(() {
      fb.l.d('endContact this:$this other:$other');
      return true;
    }());*/
    if (contact.isSensorEvent) {
      _bucketBody.remove(other);
      onBucketBodyChanged?.call(_bucketBody);
    }
  }

  @override
  String toString() {
    return 'Bucket($bodyAngle, $bodyPosition, $color, $width, $height, $cornerRadius, $arcSegments)';
  }
}
