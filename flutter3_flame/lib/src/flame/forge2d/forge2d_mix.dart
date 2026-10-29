import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;
import 'package:forge2d/forge2d.dart';

import '../../../flutter3_flame.dart' as ff;
import 'body/wall.dart';

export 'base_forge2d_game.dart';
export 'base_forge2d_world.dart';
export 'body/ball.dart';
export 'body/body_mix.dart';
export 'body/bucket.dart';
export 'body/wall.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/26
///
/// https://docs.flame-engine.org/main/bridge_packages/flame_forge2d/forge2d.html
///
/// 游戏中的单位按照 米-千克-秒 (MKS) 进行
///
/// https://box2d.org/documentation/index.html
///
/// # 刚体类型
/// https://box2d.org/documentation/md_simulation.html#autotoc_md30
/// - [BodyType.static] 静态物体
///   静态物体在模拟过程中不会移动，其行为如同具有无限大的质量。Box2D 内部将静态物体的质量和质量倒数存储为零。
///   静态物体的速度为零。静态物体不会与其他静态物体或运动物体发生碰撞。
/// - [BodyType.kinematic] 运动物体
///   运动体在模拟过程中会根据其速度移动。运动体不受力的影响。运动体通过设置其速度来移动。
///   运动体的行为如同具有无限质量，但 Box2D 会将质量及其倒数存储为零。
///   运动体不会与其他运动体或静态体发生碰撞。
///   通常，如果您希望某个形状具有动画效果且不受力或碰撞的影响，则应使用运动体。
/// - [BodyType.dynamic] 动态物体
///   动态物体经过完全模拟，并根据力和力矩运动。
///   动态物体可以与所有类型的物体发生碰撞。
///   动态物体必须始终具有有限的非零质量。
BodyComponent createBodyComponent({
  BodyType type = .dynamic,
  @fb.mm Vector2? position,
}) {
  return BodyComponent(
    bodyDef: BodyDef(type: type, position: position),
    shapeSpecs: [
      /*ShapeSpec(
        Circle(radius: 0.5),
        ShapeDef(material: SurfaceMaterial(restitution: 0.8)),
      ),*/
      ShapeSpec(
        Circle(radius: 0.1),
        ShapeDef(material: SurfaceMaterial(restitution: 0.8)),
      ),
    ],
    renderBody: true,
  )..debugMode = true;
}

extension Forge2DGameEx on Forge2DGame {
  /// 为游戏添加边界墙
  /// - [reset]是否重置之前的[Wall]
  List<Wall> addBoundariesWall(
    Forge2DGame game, {
    ff.Component? target,
    @fb.mm double? marginLeft,
    @fb.mm double? marginRight,
    @fb.mm double? marginTop,
    @fb.mm double? marginBottom,
    //--
    @fb.mm double? strokeWidth = 0,
    @fb.defInjectMark fb.UiColor? color,
    bool? reset = true,
  }) {
    //Rect.fromLTRB(-8.3, -4.0, 8.3, 4.0)
    @fb.mm
    final visibleRect = game.camera.visibleWorldRect;
    final topLeft =
        visibleRect.topLeft.toVector2() +
        Vector2(marginLeft ?? 0, marginTop ?? 0);
    final topRight =
        visibleRect.topRight.toVector2() +
        Vector2(-(marginRight ?? 0), marginTop ?? 0);
    final bottomRight =
        visibleRect.bottomRight.toVector2() +
        Vector2(-(marginRight ?? 0), -(marginBottom ?? 0));
    final bottomLeft =
        visibleRect.bottomLeft.toVector2() +
        Vector2(marginLeft ?? 0, -(marginBottom ?? 0));
    //--
    final result = [
      Wall(
        start: topLeft,
        end: topRight,
        strokeWidth: strokeWidth,
        color: color,
        tag: '上边墙',
      ),
      Wall(
        start: topRight,
        end: bottomRight,
        strokeWidth: strokeWidth,
        color: color,
        tag: '右边墙',
      ),
      Wall(
        start: bottomLeft,
        end: bottomRight,
        strokeWidth: strokeWidth,
        tag: '下边墙',
        color: color,
      ),
      Wall(
        start: topLeft,
        end: bottomLeft,
        strokeWidth: strokeWidth,
        color: color,
        tag: '左边墙',
      ),
    ];
    //--
    if (reset == true) {
      (target ?? game.world).removeAllChildren((e) => e is Wall);
    }
    (target ?? game.world).addAll(result);
    return result;
  }
}
