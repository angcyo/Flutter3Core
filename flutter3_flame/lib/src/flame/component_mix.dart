part of "../../flutter3_flame.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// 组件混合
/// - 扩展
extension ComponentEx on Component {
  /// 组件的位置
  Vector2? get componentPosition =>
      this is PositionComponent ? (this as PositionComponent).position : null;

  /// 获取游戏可见世界矩形边界
  Rect get worldVisibleRect => findGame()?.visibleWorldRect ?? Rect.zero;

  /// 当前组件是否在[Forge2DWorld]世界中
  bool get isInForge2DWorld =>
      findParent<World>(includeSelf: true) is Forge2DWorld;

  /// 像素要缩放多少倍, 才能对应物理世界的M米
  ///
  /// ```
  /// px * pixelsScale = m
  /// ```
  double get pixelsScale {
    double scale = 1;
    final world = findParent<World>(includeSelf: true);
    if (world is Forge2DWorld) {
      final viewfinder = findGame()?.camera.viewfinder;
      if (viewfinder is Forge2DViewfinder) {
        scale = 1 / viewfinder.metersToPixels;
      }
    }
    return scale;
  }

  //--

  /// 组件是否添加到游戏
  bool get isAddedToGame => findGame() != null;

  /// 游戏是否暂停
  bool get isGamePaused => findGame()?.paused ?? true;

  //--

  /// 打印所有子元素日志
  void logAllChildren() {
    final children = this.children;
    final buffer = StringBuffer();
    buffer.write("[${classHash()}]所有子元素如下[${children.length}]:");
    for (final (index, child) in children.indexed) {
      buffer.write("\n[$index]->$child");
    }
    fb.l.d(buffer.toString());
  }

  /// 清空游戏, 仅保留游戏必备组件
  void clearGameChildren([bool Function(Component component)? or]) {
    removeWhere(
      (component) =>
          (component is CameraComponent && component is World) ||
          (or?.call(component) ?? false),
    );
  }

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
  /// 获取组件在世界中的边界
  /// - 支持2d世界
  Rect get worldRect {
    final child = this;
    final childSize = child.size;
    final childPosition = child.topLeftPosition;
    final sizeScale = pixelsScale;
    final positionScale = pixelsScale;
    return Rect.fromLTWH(
      childPosition.x * positionScale,
      childPosition.y * positionScale,
      childSize.x * sizeScale,
      childSize.y * sizeScale,
    );
  }

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
