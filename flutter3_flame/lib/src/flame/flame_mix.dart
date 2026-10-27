part of "../../flutter3_flame.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// Flame混合
extension GameEx on Game {
  /// 游戏环境是否已准备好
  /// - [isMounted]
  bool get isGameReady =>
      this is FlameGame ? (this as FlameGame).camera.parent != null : false;

  /// 可见世界矩形
  /// - 如果是[Flame2DGame], 则返回的mm坐标值
  Rect get visibleWorldRect => this is FlameGame
      ? (this as FlameGame).camera.visibleWorldRect
      : Rect.zero;

  //MARK: base

  /// 弹出路由
  void pop({dynamic result, bool maybePop = false}) {
    buildContext?.pop(result: result, maybePop: maybePop);
  }

  //MARK: image

  /// 缓存图片
  /// - 稍后从直接从缓存读取数据
  Future<Image> loadImageCache(
    String fileName, {
    String? key,
    String? package,
  }) {
    return images.load(fileName, key: key, package: package);
  }

  /// 从缓存中加载图片
  Image loadImageFromCache(String name) {
    return images.fromCache(name);
  }

  //MARK: Router

  /// 获取游戏路由组件
  RouterComponent? get router => this is FlameGame
      ? (this as FlameGame).findChild<RouterComponent>(
          (e) => e is RouterComponent,
        )
      : null;
}

extension RouterComponentEx on RouterComponent {
  /// 可能弹出路由
  void maybePop() {
    if (canPop()) {
      pop();
    }
  }
}

extension UiSizeEx on Size {
  Vector2 toVector2() {
    return Vector2(width, height);
  }
}

extension Vector2Ex on Vector2 {
  Size toSize() {
    return Size(x, y);
  }
}
