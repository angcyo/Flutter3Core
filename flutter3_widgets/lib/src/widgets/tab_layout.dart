part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/11
///
/// [SingleChildScrollView]
class TabLayout extends StatefulWidget {
  /// 子元素
  final List<Widget> children;

  /// 滚动方向
  final Axis scrollDirection;

  /// 反向滚动
  final bool reverse;

  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  const TabLayout({
    super.key,
    required this.children,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  State<TabLayout> createState() => _TabLayoutState();
}

class _TabLayoutState extends State<TabLayout> with ChildScrollMixin {
  @override
  Axis get scrollDirection => widget.scrollDirection;

  @override
  bool get reverse => widget.reverse;

  @override
  bool? get primary => widget.primary;

  @override
  ScrollViewKeyboardDismissBehavior get keyboardDismissBehavior =>
      widget.keyboardDismissBehavior;

  @override
  ScrollController? get controller => widget.controller;

  @override
  DragStartBehavior get dragStartBehavior => widget.dragStartBehavior;

  @override
  ScrollPhysics? get physics => widget.physics;

  @override
  ui.Clip get clipBehavior => widget.clipBehavior;

  @override
  String? get restorationId => widget.restorationId;

  @override
  Widget build(BuildContext context) {
    return buildScrollContainer(
        context,
        (context, position) => TabLayoutViewport(
              offset: position,
              axisDirection: _getDirection(context),
              padding: widget.padding,
              clipBehavior: widget.clipBehavior,
              children: widget.children,
            ));
  }
}

/// 滚动child的混合
/// [SingleChildScrollView]
mixin ChildScrollMixin {
  /// [PrimaryScrollController.scrollDirection]
  Axis scrollDirection = Axis.vertical;
  bool reverse = false;
  bool? primary;

  //---

  ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
      ScrollViewKeyboardDismissBehavior.manual;

  //---

  /// [Scrollable.controller]
  ScrollController? controller;

  /// [Scrollable.dragStartBehavior]
  DragStartBehavior dragStartBehavior = DragStartBehavior.start;

  /// [Scrollable.physics]
  ScrollPhysics? physics;

  /// [Scrollable.clipBehavior]
  Clip clipBehavior = Clip.hardEdge;

  /// [Scrollable.restorationId]
  String? restorationId;

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
      context,
      scrollDirection,
      reverse,
    );
  }

  /// 构建滚动容器
  @callPoint
  Widget buildScrollContainer(
    BuildContext context,
    ViewportBuilder viewportBuilder,
  ) {
    final AxisDirection axisDirection = _getDirection(context);
    //debugger();
    final bool effectivePrimary = primary ??
        controller == null &&
            PrimaryScrollController.shouldInherit(context, scrollDirection);

    final ScrollController? scrollController = effectivePrimary
        ? PrimaryScrollController.maybeOf(context)
        : controller;

    //滚动容器
    Widget scrollable = Scrollable(
      dragStartBehavior: dragStartBehavior,
      axisDirection: axisDirection,
      controller: scrollController,
      physics: physics,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      viewportBuilder: viewportBuilder,
    );

    if (keyboardDismissBehavior == ScrollViewKeyboardDismissBehavior.onDrag) {
      scrollable = NotificationListener<ScrollUpdateNotification>(
        child: scrollable,
        onNotification: (ScrollUpdateNotification notification) {
          final FocusScopeNode focusNode = FocusScope.of(context);
          if (notification.dragDetails != null && focusNode.hasFocus) {
            focusNode.unfocus();
          }
          return false;
        },
      );
    }

    return effectivePrimary && scrollController != null
        // Further descendant ScrollViews will not inherit the same
        // PrimaryScrollController
        ? PrimaryScrollController.none(child: scrollable)
        : scrollable;
  }
}

/// [TabLayout] 的子布局
class TabLayoutViewport extends MultiChildRenderObjectWidget {
  const TabLayoutViewport({
    super.key,
    super.children,
    required this.offset,
    this.axisDirection = AxisDirection.left,
    this.crossAxisDirection,
    this.padding,
    this.clipBehavior = Clip.hardEdge,
  });

  /// 确定原点位置
  final AxisDirection axisDirection;

  final AxisDirection? crossAxisDirection;

  /// 滚动偏移
  final ViewportOffset offset;

  /// The amount of space by which to inset the child.
  final EdgeInsetsGeometry? padding;

  final Clip clipBehavior;

  @override
  TabLayoutRender createRenderObject(BuildContext context) {
    return TabLayoutRender(
      axisDirection: axisDirection,
      clipBehavior: clipBehavior,
      crossAxisDirection: crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      offset: offset,
    );
  }

  @override
  void updateRenderObject(BuildContext context, TabLayoutRender renderObject) {
    renderObject
      ..axisDirection = axisDirection
      ..clipBehavior = clipBehavior
      ..crossAxisDirection = crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection)
      ..offset = offset;
  }
}

/// [SingleChildScrollView]
/// [_RenderSingleChildViewport]
class TabLayoutRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TabLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TabLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  TabLayoutRender({
    AxisDirection axisDirection = AxisDirection.right,
    required AxisDirection crossAxisDirection,
    required ViewportOffset offset,
    Clip clipBehavior = Clip.hardEdge,
  })  : _axisDirection = axisDirection,
        _crossAxisDirection = crossAxisDirection,
        _clipBehavior = clipBehavior,
        _offset = offset;

  /// [RenderViewportBase.axisDirection]
  AxisDirection get crossAxisDirection => _crossAxisDirection;
  AxisDirection _crossAxisDirection;

  set crossAxisDirection(AxisDirection value) {
    if (value == _crossAxisDirection) {
      return;
    }
    _crossAxisDirection = value;
    markNeedsLayout();
  }

  /// [AxisDirection.right] 从左边开始往右边布局
  /// [AxisDirection.left] 从右边开始往左边布局
  /// [AxisDirection.down] 从上边开始往下边布局
  /// [AxisDirection.up] 从下边开始往上边布局
  ///
  /// [RenderViewportBase.axisDirection]
  AxisDirection get axisDirection => _axisDirection;
  AxisDirection _axisDirection;

  set axisDirection(AxisDirection value) {
    if (value == _axisDirection) {
      return;
    }
    _axisDirection = value;
    markNeedsLayout();
  }

  Axis get axis => axisDirectionToAxis(axisDirection);

  /// [RenderViewportBase.offset]
  ViewportOffset get offset => _offset;
  ViewportOffset _offset;

  set offset(ViewportOffset value) {
    if (value == _offset) {
      return;
    }
    if (attached) {
      _offset.removeListener(_hasScrolled);
    }
    _offset = value;
    if (attached) {
      _offset.addListener(_hasScrolled);
    }
    // We need to go through layout even if the new offset has the same pixels
    // value as the old offset so that we will apply our viewport and content
    // dimensions.
    markNeedsLayout();
  }

  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.none;

  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  void _hasScrolled() {
    assert(() {
      l.d('offset:${offset.pixels}');
      return true;
    }());
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TabLayoutParentData) {
      child.parentData = TabLayoutParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_hasScrolled);
  }

  @override
  void detach() {
    _offset.removeListener(_hasScrolled);
    super.detach();
  }

  @override
  bool get isRepaintBoundary => true;

  double get _viewportExtent {
    assert(hasSize);
    switch (axis) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  double get _minScrollExtent {
    assert(hasSize);
    return 0.0;
  }

  double get _maxScrollExtent {
    assert(hasSize);
    if (childCount <= 0) {
      return 0.0;
    }
    switch (axis) {
      case Axis.horizontal:
        return max(0.0, getAllLinearChildWidth(getChildren()) - size.width);
      case Axis.vertical:
        return max(0.0, getAllLinearChildHeight(getChildren()) - size.height);
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    double width = 0;
    double height = 0;
    final children = getChildren();
    final (childMaxWidth, childMaxHeight) = measureWrapChildren(children);
    if (constraints.hasTightWidth) {
      width = constraints.maxWidth;
    } else {
      width = childMaxWidth;
    }
    if (constraints.hasTightHeight) {
      height = constraints.maxHeight;
    } else {
      height = childMaxHeight;
    }
    layoutLinearChildren(children, axis);
    //debugger();
    size = constraints.constrain(Size(width, height));
    //size = Size(width * 3, height);

    //scroll
    if (offset.hasPixels) {
      if (offset.pixels > _maxScrollExtent) {
        offset.correctBy(_maxScrollExtent - offset.pixels);
      } else if (offset.pixels < _minScrollExtent) {
        offset.correctBy(_minScrollExtent - offset.pixels);
      }
    }

    offset.applyViewportDimension(_viewportExtent);
    offset.applyContentDimensions(_minScrollExtent, _maxScrollExtent);
  }

  Offset get _paintOffset => _paintOffsetForPosition(offset.pixels);

  Offset _paintOffsetForPosition(double position) {
    switch (axisDirection) {
      case AxisDirection.up:
        return Offset(0.0,
            position - getAllLinearChildHeight(getChildren()) + size.height);
      case AxisDirection.down:
        return Offset(0.0, -position);
      case AxisDirection.left:
        return Offset(
            position - getAllLinearChildWidth(getChildren()) + size.width, 0.0);
      case AxisDirection.right:
        return Offset(-position, 0.0);
    }
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset) {
    switch (clipBehavior) {
      case Clip.none:
        return false;
      case Clip.hardEdge:
      case Clip.antiAlias:
      case Clip.antiAliasWithSaveLayer:
        return paintOffset.dx < 0 ||
            paintOffset.dy < 0 ||
            paintOffset.dx + getAllLinearChildWidth(getChildren()) >
                size.width ||
            paintOffset.dy + getAllLinearChildHeight(getChildren()) >
                size.height;
    }
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final Offset paintOffset = _paintOffset;

    void paintContents(PaintingContext context, Offset offset) {
      paintLayoutChildren(getChildren(), context, offset,
          paintOffset: paintOffset);
    }

    if (_shouldClipAtPaintOffset(paintOffset)) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        paintContents,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      paintContents(context, offset);
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = _paintOffset;
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return hitLayoutChildren(
      result,
      position: position,
      paintOffset: _paintOffset,
    );
  }
}

class TabLayoutParentData extends ContainerBoxParentData<RenderBox> {}
