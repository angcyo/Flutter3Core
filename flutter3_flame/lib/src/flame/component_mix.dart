part of "../../flutter3_flame.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// 组件混合
/// - 扩展
extension ComponentEx on Component {
  /// 游戏是否暂停
  bool get isGamePaused => findGame()?.paused ?? true;

  /// 移除所有子元素
  void removeAllChildren([bool Function(Component component)? test]) {
    removeWhere(test ?? (component) => true);
  }

  /// 移除所有效果
  /// - [Effect]
  void removeAllEffect({bool Function(Component component)? test}) {
    removeWhere(test ?? (component) => component is Effect);
  }

  /// 查找符合条件的子元素集合
  Iterable<T> findChildren<T extends Component>(
    bool Function(Component component) test, {
    bool includeSelf = false,
    bool reversed = false,
  }) {
    return descendants(
      includeSelf: includeSelf,
      reversed: reversed,
    ).where(test).cast<T>();
  }

  /// 查找符合条件的子元素
  T? findChild<T extends Component>(
    bool Function(Component component) test, {
    bool includeSelf = false,
    bool reversed = false,
  }) {
    return findChildren(
          test,
          includeSelf: includeSelf,
          reversed: reversed,
        ).firstOrNull
        as T?;
  }

  /// 是否有指定key的子元素
  bool hasChild(
    ComponentKey key, {
    bool includeSelf = false,
    bool reversed = false,
  }) {
    return findChild(
          (component) => component.key == key,
          includeSelf: includeSelf,
          reversed: reversed,
        ) !=
        null;
  }

  //MARK: Component

  /// 为组件添加内边距
  PaddingComponent padding(
    ui.EdgeInsets? padding, {
    bool inflateChild = false,
    Vector2? size,
  }) {
    padding ??= .zero;
    return PaddingComponent(
      padding: padding,
      inflateChild: inflateChild,
      size:
          size ??
          (this is PositionComponent
              ? (this as PositionComponent).scaledSize +
                    Vector2(padding.horizontal, padding.vertical)
              : null),
      child: this is PositionComponent ? this as PositionComponent : null,
    );
  }

  /// 使用[ButtonComponent]组件包裹当前组件
  ButtonComponent button(
    void Function()? onPressed, {
    PositionComponent? buttonDown,
    void Function()? onReleased,
    void Function()? onCancelled,
    //--响应Up的点击
    bool useTapUp = true,
    //--
    Vector2? size,
    Vector2? scale,
    double? angle,
  }) {
    final that = this;
    assert(that is PositionComponent);
    Anchor? anchor;
    if (buttonDown == null && that is SpriteComponent) {
      buttonDown = AlignComponent(
        alignment: .center,
        child: SpriteComponent(
          sprite: that.sprite,
          scale: that.scale * 0.8,
          anchor: anchor = that.anchor,
        )..debugMode = false,
      );
    }
    return ButtonComponent(
      button: (that as PositionComponent)..position = that.scaleAnchorOffset,
      onPressed: useTapUp ? null : onPressed,
      buttonDown: buttonDown,
      onReleased: useTapUp ? (onPressed ?? onReleased) : onReleased,
      onCancelled: onCancelled,
      size: size ?? that.scaledSize,
      scale: scale,
      angle: angle,
      /*anchor: anchor,*/
    )..debugMode = false;
  }

  /// 使一个组件居中显示
  AlignComponent align({
    Anchor alignment = .center,
    double? widthFactor,
    double? heightFactor,
    bool keepChildAnchor = false,
  }) {
    final that = this;
    assert(that is PositionComponent);
    return AlignComponent(
      alignment: alignment,
      child: that as PositionComponent,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      keepChildAnchor: keepChildAnchor,
    );
  }

  /// 点击之后, 切换精灵
  ButtonComponent toggleSprite(
    Sprite? Function()? onTap, {
    //--
    Vector2? size,
    Vector2? scale,
    double? angle,
  }) {
    assert(this is SpriteComponent);
    final that = this as SpriteComponent;
    return that.button(
      () {
        that.sprite = onTap?.call();
      },
      useTapUp: true,
      size: size,
      scale: scale,
      angle: angle,
    );
  }
}

extension PositionComponentEx on PositionComponent {
  /// 获取缩放对应的的偏移量
  Vector2 get scaleOffset {
    final child = this;
    final childSize = child.size;

    double offsetX = 0.0;
    double offsetY = 0.0;
    double sx = child.scale.x;
    double sy = child.scale.y;

    if (sx < 0) {
      //需要偏移
      offsetX -= sx * childSize.x;
    }

    if (sy < 0) {
      //需要偏移
      offsetY -= sy * childSize.y;
    }

    return Vector2(offsetX, offsetY);
  }

  /// 获取缩放锚点对应的偏移量
  Vector2 get scaleAnchorOffset {
    final child = this;
    final childSize = child.scaledSize;

    final offset = scaleOffset;
    double offsetX = offset.x;
    double offsetY = offset.y;
    double ax = child.anchor.x;
    double ay = child.anchor.y;
    if (ax > 0) {
      offsetX = childSize.x * ax;
    }
    if (ay > 0) {
      offsetY = childSize.y * ay;
    }
    return Vector2(offsetX, offsetY);
  }
}

extension IterableComponentEx on Iterable<Component> {
  /// 从parent中移除
  void removeFromParent() {
    for (final component in this) {
      component.removeFromParent();
    }
  }
}
