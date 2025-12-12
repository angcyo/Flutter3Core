part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/05/11
///
/// 滚动相关混入

/// 滚动child的混合
/// [SingleChildScrollView].
/// [ScrollView]->[CustomScrollView].
/// [ScrollView]->[BoxScrollView]->[ListView]
///
abstract class ScrollContainerWidget extends StatefulWidget {
  /// 子元素
  final List<Widget> children;

  /// 滚动方向
  /// [PrimaryScrollController.scrollDirection]
  final Axis scrollDirection;

  /// 反向滚动
  final bool reverse;

  /// 滚动内容的填充大小
  final EdgeInsets? padding;

  /// [Scrollable.controller]
  final ScrollController? scrollController;
  final bool? primary;

  /// [Scrollable.physics]
  final ScrollPhysics? physics;

  /// [Scrollable.dragStartBehavior]
  final DragStartBehavior dragStartBehavior;

  /// [Scrollable.clipBehavior]
  final Clip clipBehavior;

  /// [Scrollable.restorationId]
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  //---

  /// [ScrollContainerRenderBox.crossAxisAlignment]
  final CrossAxisAlignment? crossAxisAlignment;

  //---

  /// 自身约束
  final LayoutBoxConstraints? selfConstraints;

  const ScrollContainerWidget({
    super.key,
    required this.children,
    this.scrollController,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.selfConstraints,
  });
}

abstract class ScrollContainerState<T extends ScrollContainerWidget>
    extends State<T>
    with ScrollContainerStateMixin {}

/// 使用[Scrollable]包裹[ViewPort]的方式
mixin ScrollContainerStateMixin<T extends ScrollContainerWidget> on State<T> {
  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
      context,
      widget.scrollDirection,
      widget.reverse,
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
    final bool effectivePrimary =
        widget.primary ??
        widget.scrollController == null &&
            PrimaryScrollController.shouldInherit(
              context,
              widget.scrollDirection,
            );

    final ScrollController? scrollController = effectivePrimary
        ? PrimaryScrollController.maybeOf(context)
        : widget.scrollController;

    //滚动容器
    Widget scrollable = Scrollable(
      dragStartBehavior: widget.dragStartBehavior,
      axisDirection: axisDirection,
      controller: scrollController,
      physics: widget.physics,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      viewportBuilder: viewportBuilder,
    );

    if (widget.keyboardDismissBehavior ==
        ScrollViewKeyboardDismissBehavior.onDrag) {
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

/// [RenderBox]
/// 负责滚动时的测量/布局/绘制
/// 碰撞检测
/// [SingleChildScrollView]
/// [_RenderSingleChildViewport]
abstract class ScrollContainerRenderBox<
  ParentDataType extends ContainerBoxParentData<RenderBox>
>
    extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ParentDataType>,
        RenderBoxContainerDefaultsMixin<RenderBox, ParentDataType>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  ScrollContainerRenderBox({
    AxisDirection axisDirection = AxisDirection.right,
    required AxisDirection crossAxisDirection,
    required ViewportOffset viewport,
    Clip clipBehavior = Clip.hardEdge,
    this.scrollController,
    this.padding,
    this.gap = 0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.selfConstraints,
  }) : _axisDirection = axisDirection,
       _crossAxisDirection = crossAxisDirection,
       _clipBehavior = clipBehavior,
       _viewport = viewport;

  /// 滚动控制器
  /// [ScrollContainerController]
  ScrollController? scrollController;

  /// [scrollController]
  ScrollContainerController? get scrollContainerController {
    if (scrollController is ScrollContainerController) {
      return scrollController as ScrollContainerController;
    }
    return null;
  }

  /// 交叉轴上的布局对齐方式
  /// 如果设置了此时, 那child的大小测量就是wrap_content, 否则是match_parent
  CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.start;

  /// 自身的约束
  LayoutBoxConstraints? selfConstraints;

  /// child测量参考是否是撑满父布局
  bool get isChildMatchParent => crossAxisAlignment == null;

  /// 填充内容的距离
  EdgeInsets? padding;

  double get paddingHorizontal => (padding?.horizontal ?? 0);

  double get paddingVertical => (padding?.vertical ?? 0);

  double get paddingTop => (padding?.top ?? 0);

  double get paddingBottom => (padding?.bottom ?? 0);

  double get paddingLeft => (padding?.left ?? 0);

  double get paddingRight => (padding?.right ?? 0);

  /// 子节点之间的间隙
  double gap = 0;

  //---

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

  //region ---_RenderSingleChildViewport---

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
  ViewportOffset get viewport => _viewport;
  ViewportOffset _viewport;

  set viewport(ViewportOffset value) {
    //debugger();
    if (value == _viewport) {
      return;
    }
    if (attached) {
      _viewport.removeListener(_hasScrolled);
    }
    _viewport = value;
    if (attached) {
      _viewport.addListener(_hasScrolled);
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
      //l.d('offset:${offset.pixels}');
      return true;
    }());
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    super.setupParentData(child);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _viewport.addListener(_hasScrolled);
  }

  @override
  void detach() {
    _viewport.removeListener(_hasScrolled);
    super.detach();
  }

  @override
  bool get isRepaintBoundary => true;

  /// 视口可视化的最大宽高
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

  /// 视口外还有多少可滚动距离
  double get _maxScrollExtent {
    assert(hasSize);
    if (childCount <= 0) {
      return 0.0;
    }
    switch (axis) {
      case Axis.horizontal:
        return max(
          0.0,
          _scrollChildSize.width + paddingHorizontal - size.width,
        );
      case Axis.vertical:
        return max(
          0.0,
          _scrollChildSize.height + paddingVertical - size.height,
        );
    }
  }

  /// 可以滚动的所有子节点宽高, 不包含[padding]的高度
  Size get _scrollChildSize {
    switch (axis) {
      case Axis.horizontal:
        return Size(
          getAllLinearChildWidth(getScrollChildren(), gap: gap),
          size.height,
        );
      case Axis.vertical:
        return Size(
          size.width,
          getAllLinearChildHeight(getScrollChildren(), gap: gap),
        );
    }
  }

  //---

  /// 绘制的偏移, 视口已经滚动的距离
  Offset get paintOffsetMixin => paintOffsetForPosition(viewport.pixels);

  Offset paintOffsetForPosition(double position) {
    switch (axisDirection) {
      case AxisDirection.up:
        return Offset(
          0.0,
          position -
              getAllLinearChildHeight(getScrollChildren(), gap: gap) +
              size.height,
        );
      case AxisDirection.down:
        return Offset(0.0, -position);
      case AxisDirection.left:
        return Offset(
          position -
              getAllLinearChildWidth(getScrollChildren(), gap: gap) +
              size.width,
          0.0,
        );
      case AxisDirection.right:
        return Offset(-position, 0.0);
    }
  }

  bool shouldClipAtPaintOffset(Offset paintOffset) {
    switch (clipBehavior) {
      case Clip.none:
        return false;
      case Clip.hardEdge:
      case Clip.antiAlias:
      case Clip.antiAliasWithSaveLayer:
        return paintOffset.dx < 0 ||
            paintOffset.dy < 0 ||
            paintOffset.dx +
                    getAllLinearChildWidth(getScrollChildren(), gap: gap) >
                size.width ||
            paintOffset.dy +
                    getAllLinearChildHeight(getScrollChildren(), gap: gap) >
                size.height;
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  /// 水波纹绘制时, 会调用此方法
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = paintOffsetMixin;
    transform.translate(paintOffset.dx, paintOffset.dy);
    super.applyPaintTransform(child, transform);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject? child) {
    if (child != null && shouldClipAtPaintOffset(paintOffsetMixin)) {
      return Offset.zero & size;
    }
    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('offset', paintOffsetMixin));
  }

  @override
  Rect describeSemanticsClip(RenderObject child) {
    final double remainingOffset = _maxScrollExtent - viewport.pixels;
    switch (axisDirection) {
      case AxisDirection.up:
        return Rect.fromLTRB(
          semanticBounds.left,
          semanticBounds.top - remainingOffset,
          semanticBounds.right,
          semanticBounds.bottom + viewport.pixels,
        );
      case AxisDirection.right:
        return Rect.fromLTRB(
          semanticBounds.left - viewport.pixels,
          semanticBounds.top,
          semanticBounds.right + remainingOffset,
          semanticBounds.bottom,
        );
      case AxisDirection.down:
        return Rect.fromLTRB(
          semanticBounds.left,
          semanticBounds.top - viewport.pixels,
          semanticBounds.right,
          semanticBounds.bottom + remainingOffset,
        );
      case AxisDirection.left:
        return Rect.fromLTRB(
          semanticBounds.left - remainingOffset,
          semanticBounds.top,
          semanticBounds.right + viewport.pixels,
          semanticBounds.bottom,
        );
    }
  }

  //endregion ---_RenderSingleChildViewport---

  //region ---布局核心方法---

  /// 获取需要滚动的子节点
  List<RenderBox> getScrollChildren();

  /// 获取指定index的子节点
  RenderBox? getScrollChildAt(int index) =>
      getScrollChildren().getOrNull(index);

  /// 获取指定index的子节点大小
  Size? getScrollChildSize(int index) => getScrollChildAt(index)?.size;

  //---

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    double width = 0;
    double height = 0;
    final children = getScrollChildren();
    //debugger();
    var (childMaxWidth, childMaxHeight) = measureChildren(children);

    if (axis == Axis.horizontal) {
      childMaxWidth = getAllLinearChildWidth(children, gap: gap);
    } else {
      childMaxHeight = getAllLinearChildHeight(children, gap: gap);
    }

    double? childFixedWidth;
    if (selfConstraints?.widthType == null ||
        selfConstraints?.widthType == ConstraintsType.wrapContent) {
      childFixedWidth = childMaxWidth + paddingHorizontal;
    } else if (selfConstraints?.widthType == ConstraintsType.fixedSize) {
      childFixedWidth = selfConstraints?.maxWidth;
    }

    double? childFixedHeight;
    if (selfConstraints?.heightType == null ||
        selfConstraints?.heightType == ConstraintsType.wrapContent) {
      childFixedHeight = childMaxHeight + paddingVertical;
    } else if (selfConstraints?.heightType == ConstraintsType.fixedSize) {
      childFixedHeight = selfConstraints?.maxHeight;
    }

    if (constraints.hasTightWidth) {
      width = constraints.maxWidth;
    } else {
      width = childMaxWidth + paddingHorizontal;
    }
    if (constraints.hasTightHeight) {
      height = constraints.maxHeight;
    } else {
      height = childMaxHeight + paddingVertical;
    }

    //debugger();
    if (constraints.maxWidth != double.infinity) {
      width = max(width, constraints.maxWidth);
    }
    if (constraints.maxHeight != double.infinity) {
      height = max(height, constraints.maxHeight);
    }

    //--
    if (childFixedWidth != null) {
      width = min(width, childFixedWidth);
    }
    if (childFixedHeight != null) {
      height = min(height, childFixedHeight);
    }
    //debugger();
    size = constraints.constrain(Size(width, height));
    //size = Size(width * 3, height);

    //--
    layoutLinearChildren(
      children,
      axis,
      crossAxisAlignment: crossAxisAlignment,
      parentSize: size,
      parentPadding: padding,
      gap: gap,
    );

    //---
    final controller = scrollContainerController;
    if (controller != null) {
      controller.maxScrollExtent = _maxScrollExtent;
      controller.scrollContainerLayoutSize = size;
      controller.scrollContainerScrollDirection = axis;
      controller.scrollContainerChildrenBounds = children
          .map((e) => e.getBoundsInParentOrNull() ?? Rect.zero)
          .toList();
    }

    //scroll
    //debugger();
    if (viewport.hasPixels) {
      if (viewport.pixels > _maxScrollExtent) {
        viewport.correctBy(_maxScrollExtent - viewport.pixels);
      } else if (viewport.pixels < _minScrollExtent) {
        viewport.correctBy(_minScrollExtent - viewport.pixels);
      }
    }

    viewport.applyViewportDimension(_viewportExtent);
    viewport.applyContentDimensions(_minScrollExtent, _maxScrollExtent);
  }

  /// 测量子节点的大小
  /// 返回最大的尺寸
  (double childMaxWidth, double childMaxHeight) measureChildren(
    List<RenderBox> children,
  ) {
    final BoxConstraints constraints = this.constraints;
    //debugger();
    double? childWidth;
    double? childHeight;
    if ((isChildMatchParent || constraints.isFixedWidth) &&
        axis == Axis.vertical) {
      childWidth = constraints.maxWidth.ensureValid(
        constraints.minWidth + paddingHorizontal,
      );
    }
    if ((isChildMatchParent || constraints.isFixedHeight) &&
        axis == Axis.horizontal) {
      childHeight = constraints.maxHeight.ensureValid(
        constraints.minHeight + paddingVertical,
      );
    }
    return measureWrapChildren(
      children,
      childWidth: childWidth,
      childHeight: childHeight,
    );
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    final paintOffset = paintOffsetMixin;
    scrollContainerController?.paintOffset = paintOffset;

    if (shouldClipAtPaintOffset(paintOffset)) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        paintScrollContents,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      paintScrollContents(context, offset);
    }
  }

  /// 绘制滚动内容
  /// [paint]
  /// [shouldClipAtPaintOffset]
  /// [clipBehavior]
  /// [_clipRectLayer]
  void paintScrollContents(PaintingContext context, Offset offset) {
    final Offset paintOffset = paintOffsetMixin;
    paintLayoutChildren(
      getScrollChildren(),
      context,
      offset,
      paintOffset: paintOffset,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    return hitLayoutChildren(
      getScrollChildren(),
      result,
      position: position,
      paintOffset: paintOffsetMixin,
    );
  }

  //endregion ---布局核心方法---
}

/// 滚动控制器
/// 支持跳转到指定index位置
class ScrollContainerController extends ScrollController {
  //--滚动容器---

  /// 滚动容器的大小
  /// [ScrollContainerRenderBox.performLayout]中赋值
  @autoInjectMark
  Size scrollContainerLayoutSize = Size.zero;

  /// 滚动容器的滚动方向
  /// [ScrollContainerRenderBox.performLayout]中赋值
  @autoInjectMark
  Axis scrollContainerScrollDirection = Axis.horizontal;

  /// 滚动容器的滚动内容子布局大小和位置
  /// [ScrollContainerRenderBox.performLayout]中赋值
  @autoInjectMark
  List<Rect> scrollContainerChildrenBounds = [];

  /// 滚动容器的最大滚动范围
  /// [ScrollContainerRenderBox.performLayout]中赋值
  @autoInjectMark
  double maxScrollExtent = 0;

  /// 滚动容器当前绘制时的偏移量
  /// [ScrollContainerRenderBox.paint]中赋值
  @autoInjectMark
  Offset? paintOffset;

  ScrollContainerController({
    super.initialScrollOffset = 0.0,
    super.keepScrollOffset = true,
    super.debugLabel,
    super.onAttach,
    super.onDetach,
  });

  /// 滚动到指定的索引位置
  /// [center] 是否滚动到居中显示
  /// [animate] 是否使用动画
  /// [duration] 动画时长
  /// [curve] 动画曲线
  /// [scrollTo]
  @api
  void scrollToIndex(
    int index, {
    bool center = true,
    bool animate = true,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    //debugger();
    final count = scrollContainerChildrenBounds.length;
    if (index < 0 || index >= count) {
      assert(() {
        debugger(when: count > 0);
        l.w('index out of range [0~$count]:$index');
        return true;
      }());
      return;
    }
    if (scrollContainerScrollDirection == Axis.horizontal) {
      //水平滚动
      double offset = scrollContainerChildrenBounds[index].left;
      if (center) {
        offset = offset + scrollContainerChildrenBounds[index].width / 2;
      }
      scrollTo(offset, center: center, animate: animate, duration: duration);
    } else {
      //垂直滚动
      double offset = scrollContainerChildrenBounds[index].top;
      if (center) {
        offset = offset + scrollContainerChildrenBounds[index].height / 2;
      }
      scrollTo(offset, center: center, animate: animate, duration: duration);
    }
  }

  /// 滚动到指定的位置
  /// [center] 是否自动将指定的位置, 居中显示
  void scrollTo(
    double offset, {
    bool center = true,
    bool animate = true,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    //debugger();
    if (scrollContainerScrollDirection == Axis.horizontal) {
      //水平滚动
      if (center) {
        offset = offset - scrollContainerLayoutSize.width / 2;
      }
      offset = clamp(offset, 0.0, maxScrollExtent);
      if (offset == this.offset) {
        //Failed assertion: line 172 pos 12: '_positions.length == 1': ScrollController attached to multiple scroll views.
        return;
      }
      if (animate) {
        animateTo(
          offset,
          duration: duration ?? kTabScrollDuration,
          curve: curve,
        );
      } else {
        jumpTo(offset);
      }
    } else {
      //垂直滚动
      if (center) {
        offset = offset - scrollContainerLayoutSize.height / 2;
      }
      offset = clamp(offset, 0.0, maxScrollExtent);
      if (offset == this.offset) {
        return;
      }
      if (animate) {
        animateTo(
          offset,
          duration: duration ?? kTabScrollDuration,
          curve: curve,
        );
      } else {
        jumpTo(offset);
      }
    }
  }
}
