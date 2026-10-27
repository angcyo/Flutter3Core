import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

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
      fb.l.d("applyLinearImpulseEx: $impulse");
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
}
