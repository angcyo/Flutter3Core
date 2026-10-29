import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

import '../../../../flutter3_flame.dart' as ff;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/26
///
/// 刚体 相关混合操作
///
/// 在 Flutter forge2d 中，这四个方法用于控制刚体的平移和旋转：
/// - [Body.applyForce] ：施加线性力，影响平移，也可能引起旋转。
/// - [Body.applyTorque] ：施加扭矩，影响旋转。
/// - [Body.applyLinearImpulse] ：施加线性冲量，立即改变线速度，也可能引起旋转。
/// - [Body.applyAngularImpulse] ：施加角冲量，立即改变角速度。
extension BodyEx on Body {
  /// 刚体是否包含某个点?
  bool containsPoint(Vector2 point) {
    for (final shape in shapes) {
      if (shape.testPoint(point)) {
        return true;
      }
    }
    return false;
  }

  //MARK: 速度

  /// 判断刚体是否停止滚动
  bool isStopped({
    double linearThreshold = 0.05,
    double angularThreshold = 0.05,
  }) {
    return linearVelocity.length < linearThreshold &&
        angularVelocity.abs() < angularThreshold;
  }

  /// 给刚体（Body）施加瞬时线性冲量，从而立即改变刚体的线速度。常见用途包括：物体被击飞、碰撞反弹、角色跳跃、爆炸冲击等。
  /// - [impulse]	Vector2	冲量向量，决定施加冲量的方向和大小
  /// - [point]	Vector2?	冲量的施加位置；通常是世界坐标系中的位置。为 null 时，通常表示作用于刚体质心
  /// - [wake]	bool	是否唤醒休眠刚体，默认 true
  ///
  /// 冲量不是速度，也不是持续作用的力。它的效果取决于刚体质量、当前速度以及物理引擎的坐标和单位设置。
  /// 在其他条件相同的情况下，冲量越大，速度变化越大；质量越大，同样的冲量产生的速度变化越小。
  ///
  /// - [Body.localCenterOfMass] 刚体的质心位置，局部坐标系
  /// - [Body.worldCenterOfMass] 刚体的质心位置，世界坐标系
  void applyLinearImpulseEx(
    Vector2 impulse, {
    Vector2? point,
    bool wake = true,
  }) {
    //Vector2.random() * 1000
    assert(() {
      fb.l.d("[${classHash()}]applyLinearImpulseEx: $impulse");
      return true;
    }());
    applyLinearImpulse(impulse, point: point, wake: wake);
  }

  /// 给刚体（Body）施加线性力，从而改变刚体的线速度和角速度。常见用途包括：施加重力、风力、电磁力等。
  /// - [force]	Vector2	力向量，决定施加力的方向和大小
  /// - [point]	Vector2?	力的施加位置；通常是世界坐标系中的位置。为 null 时，通常表示作用于刚体质心
  /// - [wake]	bool	是否唤醒休眠刚体，默认 true
  void applyForceEx(Vector2 force, {Vector2? point, bool wake = true}) {
    applyForce(force, point: point, wake: wake);
  }

  //MARK: 角速度

  /// 给刚体（Body）施加瞬时角冲量，从而立即改变刚体的角速度。常见用途包括：物体旋转、碰撞反弹、角色跳跃、爆炸冲击等。
  /// - [impulse]	double	冲量值，决定施加冲量的大小
  /// - [wake]	bool	是否唤醒休眠刚体，默认 true
  void applyAngularImpulseEx(double impulse, {bool wake = true}) {
    applyAngularImpulse(impulse, wake: wake);
  }

  /// 给刚体（Body）施加扭矩，从而改变刚体的角速度。常见用途包括：施加旋转力、扭矩、力矩等。
  /// - [torque]	double	扭矩值，决定施加扭矩的大小
  /// - [wake]	bool	是否唤醒休眠刚体，默认 true
  void applyTorqueEx(double torque, {bool wake = true}) {
    applyTorque(torque, wake: wake);
  }

  //MARK: body

  /// 获取刚体的大小
  /// - 不包含旋转因素
  Vector2 getSize() {
    double? minX;
    double? minY;
    double? maxX;
    double? maxY;
    for (final shape in shapes) {
      final aabb = shape.aabb;
      minX ??= aabb.lowerBound.x;
      minY ??= aabb.lowerBound.y;
      maxX ??= aabb.upperBound.x;
      maxY ??= aabb.upperBound.y;
      minX = fb.minOf(aabb.lowerBound.x, minX);
      minY = fb.minOf(aabb.lowerBound.y, minY);
      maxX = fb.maxOf(maxX, aabb.upperBound.x);
      maxY = fb.maxOf(maxY, aabb.upperBound.y);
    }
    if (minX == null || minY == null || maxX == null || maxY == null) {
      return Vector2.zero();
    }
    return Vector2(maxX - minX, maxY - minY);
  }

  /// 创建N个线段的几何形状
  List<Shape> createSegmentGeometry(
    List<Vector2> points, {
    ShapeDef? shapeDef,
    // 摩擦系数
    double friction = 0.6,
    // 弹性
    double restitution = 0,
    // 滚动阻力
    double rollingResistance = 0,
    // 颜色 0xrrggbb
    @fb.implementation int customColor = 0,
  }) {
    // 每两个相邻点构成一段碰撞边界。
    final shapes = <Shape>[];
    for (var i = 0; i < points.length - 1; i++) {
      shapes.add(
        createShape(
          Segment(point1: points[i], point2: points[i + 1]),
          shapeDef ??
              ShapeDef(
                material: SurfaceMaterial(
                  friction: friction,
                  restitution: restitution,
                  customColor: customColor,
                ),
              ),
        ),
      );
    }
    return shapes;
  }
}

/// 刚体组件扩展
extension BodyComponentEx on BodyComponent {
  /// 父组件的边界
  /// - [pixelsScale]
  @fb.mm
  ui.Rect? get parentRect {
    final parent = findParent<PositionComponent>();
    if (parent == null) {
      return null;
    }
    final childPosition = parent.topLeftPosition;
    return ui.Rect.fromLTWH(
      childPosition.x,
      childPosition.y,
      parent.size.x,
      parent.size.y,
    );
  }

  /// 父组件在世界中的边界
  @fb.mm
  ui.Rect get parentWorldRect =>
      findParent<PositionComponent>()?.worldRect ?? worldVisibleRect;

  /// 获取刚体的大小
  Vector2 get bodySize => body.getSize();

  /// 向物理世界中创建一个刚体
  /// - [def] 刚体的属性
  ///   - 位置
  ///   - 线速度
  ///   - 角速度
  /// - [geometry] 刚体的几何形状
  ///   - [Segment] 线段
  ///   - [Capsule] 胶囊
  ///   - [Polygon] 多边形, 最小3个点, 最多8个点[Polygon.maxVertices]
  ///   - [Circle] 圆形
  /// - [shapeDef] 刚体的几何形状属性
  ///   - 密度
  ///   - 材质
  ///     - 静摩擦
  ///     - 动摩擦
  ///     - 弹性
  Body worldCreateBody({
    BodyDef? def,
    ShapeGeometry? geometry,
    ShapeDef? shapeDef,
  }) {
    final body = world.createBody(def);
    if (geometry != null) {
      body.createShape(geometry, shapeDef);
    }
    return body;
  }
}

/// 刚体组件
class FBodyComponent<T extends Forge2DGame> extends BodyComponent<T>
    with ContactCallbacks {
  final String? tag;
  final String? debugLabel;

  //MARK: Body

  /// 刚体的位置, 是相对于[Forge2DGame].[Forge2DWorld]的,
  /// 所以这里不能是相对于父的坐标
  Vector2 bodyPosition;
  BodyType bodyType;

  /// 是否启用刚体, 关闭后, 刚体将不会响应物理模拟
  bool isEnabled;

  //MARK: Shape

  /// 球的材质, 摩擦力 / 反弹力 / 阻力
  SurfaceMaterial? material;
  bool enableContactEvents;
  bool enableSensorEvents;

  /// 球的密度 / 影响质量
  double density;

  FBodyComponent({
    super.paint,
    super.children,
    super.priority,
    super.renderBody = true,
    super.bodyDef,
    super.shapeSpecs,
    super.key,
    //--
    fb.UiColor? color,
    this.tag,
    this.debugLabel,
    //--
    Vector2? position,
    this.bodyType = .static,
    this.isEnabled = true,
    //--
    this.material,
    this.enableContactEvents = true,
    this.enableSensorEvents = true,
    this.density = 1,
  }) : bodyPosition = position ?? Vector2.zero() {
    if (color != null) {
      super.paint.color = color;
    }
  }

  /// 加载刚体
  @override
  Future<void> onLoad() {
    return super.onLoad();
  }

  @override
  Body createBody() {
    final bodyDef =
        this.bodyDef ??
        BodyDef(
          userData: (enableContactEvents || enableSensorEvents) ? this : null,
          angularDamping: 0,
          position: bodyPosition,
          type: bodyType,
          isEnabled: isEnabled,
        );
    final body = world.createBody(bodyDef);
    //--
    final bodyHasCallbacks = bodyDef.userData is ContactCallbacks;
    for (final spec in shapeSpecs ?? const <ShapeSpec>[]) {
      final definition = spec.definition ?? ShapeDef();
      if (bodyHasCallbacks || definition.userData is ContactCallbacks) {
        definition.enableContactEvents = true;
        definition.enableSensorEvents = true;
      }
      body.createShape(spec.geometry, definition);
    }
    //--
    final geometry = createGeometry(body);
    if (geometry != null) {
      body.createShape(
        geometry,
        ShapeDef(
          material: material,
          enableContactEvents: enableContactEvents,
          enableSensorEvents: enableSensorEvents,
          density: density,
        ),
      );
    }
    return body;
  }

  /// 创建刚体的几何形状
  @fb.overridePoint
  ShapeGeometry? createGeometry(Body body) {
    return null;
  }

  /// 重新加载刚体
  void reloadBody() {
    if (!world.isRemoving || world.destroyBodiesOnRemove) {
      world.destroyBody(body);
    }
    body = createBody();
  }

  //--

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (debugLabel != null) {
      assert(() {
        fb.l.d("[$this] 与 [$other]开始接触, 传感器: ${contact.isSensorEvent}");
        return true;
      }());
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    if (debugLabel != null) {
      assert(() {
        fb.l.i("[$this] 与 [$other]结束接触, 传感器: ${contact.isSensorEvent}");
        return true;
      }());
    }
  }

  //--

  @override
  String toString() {
    return "${classHash()}${tag?.wph ?? ""}";
  }
}
