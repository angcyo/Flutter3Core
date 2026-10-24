part of "../../flutter3_flame.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// 精灵混合
extension SpriteEx on Sprite {
  /// 转换成精灵组件
  SpriteComponent toSpriteComponent({Vector2? position, Vector2? size}) {
    return SpriteComponent(sprite: this, position: position, size: size);
  }
}
