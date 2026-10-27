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

  /// 球的密度 / 影响质量
  @fb.configProperty
  double density;

  late Paint originalPaint;
  final Vector2 bodyPosition;
  final BodyType bodyType;

  final double strokeWidth;
  final String? tag;
  final bool enableContactEvents;
  final bool enableSensorEvents;
  final Object? userData;

  /// 是否启用刚体, 关闭后, 刚体将不会响应物理模拟
  final bool isEnabled;

  /// 球的材质, 摩擦力 / 反弹力 / 阻力
  @fb.defInjectMark
  final SurfaceMaterial? material;

  //--
  Ball({
    this.tag,
    Vector2? position,
    this.bodyType = .dynamic,
    @fb.mm this.radius = 0.2,
    @fb.mm this.strokeWidth = 0.01,
    Color? color,
    super.renderBody = true,
    this.enableContactEvents = true,
    this.enableSensorEvents = true,
    this.isEnabled = true,
    this.userData,
    this.material,
    this.density = 1,
    void Function(Ball component)? onStoppedAction,
  }) : bodyPosition = position ?? Vector2.zero() {
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
      material: material ?? SurfaceMaterial(restitution: 0.7),
      enableContactEvents: enableContactEvents,
      enableSensorEvents: enableSensorEvents,
      density: density,
    );

    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      position: bodyPosition,
      type: bodyType,
      isEnabled: isEnabled,
    );

    final body = world.createBody(bodyDef);
    final shape = body.createShape(Circle(radius: radius), shapeDef);
    return body;
  }

  final _impulseForce = Vector2(0, 1000);

  @override
  @mustCallSuper
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
