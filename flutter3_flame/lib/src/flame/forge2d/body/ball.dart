import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;
import 'package:flutter3_flame/src/flame/forge2d/body/bucket.dart';

import 'glowing_body.dart';
import 'stopped_callbacks.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/26
///
/// 游戏中的一个球
class Ball extends BodyComponent
    with ContactCallbacks, GlowingBody, StoppedCallbacks<Ball> {
  /// 球的半径
  @fb.configProperty
  double radius;

  late Paint originalPaint;

  double strokeWidth;
  String? tag;

  //MARK: shape

  /// 球的密度 / 影响质量
  @fb.configProperty
  double density;

  /// 球的摩擦系数
  @fb.configProperty
  double friction;

  /// 球的弹性
  @fb.configProperty
  double restitution;

  bool enableContactEvents;
  bool enableSensorEvents;

  /// 是否传感器, 传感器不会响应物理碰撞, 但会触发碰撞事件
  bool isSensor;

  /// 球的材质, 摩擦力 / 反弹力 / 阻力
  @fb.defInjectMark
  SurfaceMaterial? material;

  //MARK: body

  /// 初始位置
  Vector2 bodyPosition;

  /// 初始旋转
  Rot bodyRotation;

  /// 初始线性速度
  Vector2? linearVelocity;
  double angularVelocity;

  BodyType bodyType;

  /// 是否启用刚体, 关闭后, 刚体将不会响应物理模拟
  bool isEnabled;

  Object? userData;

  //--
  Ball({
    this.tag,
    @fb.mm this.radius = 0.2,
    @fb.mm this.strokeWidth = 0.01,
    Color? color,
    this.bodyType = .dynamic,
    Vector2? position,
    Rot? rotation,
    this.linearVelocity,
    this.angularVelocity = 0,
    super.renderBody = true,
    this.enableContactEvents = true,
    this.enableSensorEvents = true,
    this.isEnabled = true,
    this.isSensor = false,
    this.userData,
    this.material,
    this.density = 1,
    this.friction = 0.6,
    this.restitution = 0.7,
    void Function(Ball component)? onStoppedAction,
  }) : bodyPosition = position ?? Vector2.zero(),
       bodyRotation = rotation ?? Rot.identity() {
    originalPaint = Paint()..color = color ?? Colors.purple;
    paint = originalPaint;
    this.onStoppedAction = onStoppedAction;
  }

  @override
  double get outlineWidth => strokeWidth;

  /// 简单的计算球的质量
  /// \[
  /// m=\rho\pi r^2
  /// \]
  double get ballMass => density * fb.$pi * radius * radius;

  @override
  Body createBody() {
    final shapeDef = ShapeDef(
      material:
          material ??
          SurfaceMaterial(friction: friction, restitution: restitution),
      enableContactEvents: enableContactEvents,
      enableSensorEvents: enableSensorEvents,
      density: density,
      isSensor: isSensor,
    );

    final bodyDef = BodyDef(
      type: bodyType,
      isEnabled: isEnabled,
      userData: this,
      angularDamping: 0.8,
      position: bodyPosition,
      rotation: bodyRotation,
      linearVelocity: linearVelocity,
      angularVelocity: angularVelocity,
    );
    //--
    final body = world.createBody(bodyDef);
    final geometry = createBallGeometry(body);
    if (geometry != null) {
      body.createShape(geometry, shapeDef);
    }
    return body;
  }

  /// 创建Ball的几何形状
  @fb.overridePoint
  ShapeGeometry? createBallGeometry(Body body) {
    //body.createShape(ff.FPolygon(points));
    //body.createSegmentGeometry(ff.FPolygon(points));
    return Circle(radius: radius);
  }

  //final _impulseForce = Vector2(0, 1000);

  /// no op
  @override
  void update(double dt) {
    super.update(dt);
    /*_timeSinceNudge += dt;
    if (giveNudge) {
      giveNudge = false;
      if (_timeSinceNudge > _minNudgeRest) {
        body.applyLinearImpulse(_impulseForce);
        _timeSinceNudge = 0.0;
      }
    }*/
    /*assert(() {
      fb.l.d(
        '[${classHash()}][$tag] update $dt awake:${body.isAwake} valid:${body.isValid} stopped:${body.isStopped()}',
      );
      return true;
    }());*/
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    /*assert(() {
      fb.l.i('beginContact this:$this other:$other');
      return true;
    }());*/
    if (other is Ball) {
      //contact.userDatas
      //debugger();
    } else if (other is Bucket) {
      final isSensor1 = contact.shapeA.isSensor;
      final isSensor2 = contact.shapeB.isSensor;
      final isSensorEvent = contact.isSensorEvent;
      //final userDatas = contact.userDatas;
      //debugger(when: isSensor1 || isSensor2 || isSensorEvent);
      if (isSensorEvent) {
        fb.l.i('[$this]进入桶内...');
      }
    }
    /*if (other is Wall) {
      other.paint = paint;
    }

    if (other is WhiteBall) {
      return;
    }*/

    /*if (other is Ball) {
      if (paint != originalPaint) {
        paint = other.paint;
      } else {
        other.paint = paint;
      }
    }*/
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    /*assert(() {
      fb.l.d('endContact this:$this other:$other');
      return true;
    }());*/
    if (other is Ball) {
      //contact.userDatas
      //debugger();
    } else if (other is Bucket) {
      final isSensor1 = contact.shapeA.isSensor;
      final isSensor2 = contact.shapeB.isSensor;
      final isSensorEvent = contact.isSensorEvent;
      //final userDatas = contact.userDatas;
      //debugger(when: isSensor1 || isSensor2 || isSensorEvent);
      if (isSensorEvent) {
        fb.l.w('[$this]离开桶内...');
      }
    }
  }

  /*@override
  void onSelfStopped() {
    super.onSelfStopped();
    final contactEvents = world.physicsWorld.contactEvents;
    final sensorEvents = world.physicsWorld.sensorEvents;
    debugger();
  }*/

  @override
  String toString() {
    return "${classHash()}${tag?.wph ?? ""}";
  }
}
