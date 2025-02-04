part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/23
///
class SliverScrollCoordinateLayoutWidget extends MultiChildRenderObjectWidget {
  /// [RenderSliverScrollCoordinateLayout.minExtent]
  final double minExtent;

  /// [RenderSliverScrollCoordinateLayout.maxExtent]
  final double? maxExtent;

  /// [RenderSliverScrollCoordinateLayout.onCoordinateLayoutAction]
  final CoordinateLayoutAction? onCoordinateLayoutAction;

  const SliverScrollCoordinateLayoutWidget({
    super.key,
    super.children /*RenderBox*/,
    this.minExtent = 0,
    this.maxExtent,
    this.onCoordinateLayoutAction,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverScrollCoordinateLayout()
        ..minExtent = minExtent
        ..maxExtent = maxExtent
        ..onCoordinateLayoutAction = onCoordinateLayoutAction;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverScrollCoordinateLayout renderObject,
  ) {
    renderObject
      ..minExtent = minExtent
      ..maxExtent = maxExtent
      ..onCoordinateLayoutAction = onCoordinateLayoutAction
      ..markNeedsLayout();
  }
}

class RenderSliverScrollCoordinateLayout extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerParentDataMixin<RenderBox>>,
        RenderSliverHelpers {
  /// 需要保持显示的最小范围
  double minExtent = 0;

  /// 需要保持显示的最大范围
  double? maxExtent;

  /// Sliver滚动协调布局进度回调
  /// 这个回调会把进度回调出去
  CoordinateLayoutAction? onCoordinateLayoutAction;

  /// [SliverConstraints.overlap]
  Offset get constraintsOverlapOffset => constraints.axis == Axis.vertical
      ? Offset(0, constraints.overlap)
      : Offset(constraints.overlap, 0);

  /// 子元素顶部重叠的偏移量
  double _childOverlapTop = 0;

  Offset get _childOverlapTopOffset => constraints.axis == Axis.vertical
      ? Offset(0, _childOverlapTop)
      : Offset(_childOverlapTop, 0);

  //region --布局--

  /// [RenderObject.isRepaintBoundary]
  @override
  bool get isRepaintBoundary => super.isRepaintBoundary /*true*/;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SliverScrollCoordinateLayoutParentData) {
      child.parentData = SliverScrollCoordinateLayoutParentData();
    }
  }

  /// [RenderSliverPersistentHeader]
  /// [RenderSliverPinnedPersistentHeader]
  /// [SliverPaintRender.performLayout]
  ///
  /// ```
  /// SliverGeometry is not valid: The "scrollExtent" is negative.
  /// ```
  ///
  /// [SliverPaintRender]
  ///
  @override
  void performLayout() {
    final constraints = this.constraints;
    //debugger();
    //l.v("constraints->$constraints");
    _childOverlapTop = 0;

    double maxChildWidth = 0, maxChildHeight = 0;
    for (final child in childrenIterable) {
      final parentData =
          child.parentData as SliverScrollCoordinateLayoutParentData;
      child.layout(
        _getChildBoxConstraints(child, this.maxExtent),
        parentUsesSize: true,
      );
      //--
      final childSize = child.size;
      maxChildWidth = maxChildWidth.maxOf(childSize.width);
      maxChildHeight = maxChildHeight.maxOf(childSize.height);
      _childOverlapTop =
          (parentData.top ?? _childOverlapTop).minOf(_childOverlapTop);
      //debugger();
    }

    double maxExtent = this.maxExtent ??
        (constraints.axis == Axis.vertical ? maxChildHeight : maxChildWidth);

    //处理条子内的滚动进度,重新布局
    final scrollProgress = constraints.scrollOffset / (maxExtent - minExtent);
    for (final child in childrenIterable) {
      //debugger();
      final parentData =
          child.parentData as SliverScrollCoordinateLayoutParentData;
      if (parentData.onCoordinateChildAction?.call(
            constraints,
            parentData,
            scrollProgress,
          ) ==
          true) {
        child.layout(
          _getChildBoxConstraints(child, maxExtent),
          parentUsesSize: true,
        );
        //--
        final childSize = child.size;
        maxChildWidth = maxChildWidth.maxOf(childSize.width);
        maxChildHeight = maxChildHeight.maxOf(childSize.height);
        _childOverlapTop =
            (parentData.top ?? _childOverlapTop).minOf(_childOverlapTop);
      }
    }
    if (this.maxExtent == null) {
      maxExtent =
          constraints.axis == Axis.vertical ? maxChildHeight : maxChildWidth;
    }

    //布局进度回调
    onCoordinateLayoutAction?.call(constraints, maxExtent, scrollProgress);

    //后处理
    //child 高度
    final double childExtent = maxExtent - minExtent;

    //
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: maxExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: maxExtent);

    //计算需要绘制的高度
    final paintExtent = paintedChildSize.maxOf(minExtent);
    final hasVisualOverflow = childExtent > constraints.remainingPaintExtent ||
        constraints.scrollOffset > 0.0;

    //计算布局占用的高度
    final double effectiveRemainingPaintExtent =
        max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = clampDouble(
        maxExtent - constraints.scrollOffset,
        0.0,
        effectiveRemainingPaintExtent);

    // l.i("scrollProgress:$scrollProgress paintedChildSize:$paintedChildSize paintExtent:$paintExtent"
    //     " scrollOffset:${constraints.scrollOffset} overlap:${constraints.overlap} hasVisualOverflow:$hasVisualOverflow ");

    //scrollOffset:0.0 minExtent: 120.0 maxExtent: 370.0 layoutExtent:370.0 cacheExtent:370.0 paintExtent:370.0 paintedChildSize:370.0 hasVisualOverflow:false
    //scrollOffset:634.4210526315788 minExtent: 120.0 maxExtent: 370.0 layoutExtent:0.0 cacheExtent:0.0 paintExtent:120.0 paintedChildSize:0.0 hasVisualOverflow:true
    //l.i("scrollOffset:${constraints.scrollOffset} minExtent: $minExtent maxExtent: $maxExtent layoutExtent:$layoutExtent cacheExtent:$cacheExtent paintExtent:$paintExtent paintedChildSize:$paintedChildSize hasVisualOverflow:$hasVisualOverflow");

    geometry = SliverGeometry(
      scrollExtent: this.maxExtent ?? childExtent.maxOf(minExtent),
      paintOrigin: constraints.overlap > 0 ? constraints.overlap : 0,
      paintExtent: paintExtent,
      maxPaintExtent: cacheExtent.maxOf(paintExtent),
      layoutExtent: layoutExtent,
      cacheExtent: cacheExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: hasVisualOverflow,
    );
  }

  /// [BoxConstraints]
  /// [refMaxExtent] 主轴参考的最大值
  BoxConstraints _getChildBoxConstraints(
    RenderBox child,
    double? refMaxExtent,
  ) {
    final parentData =
        child.parentData as SliverScrollCoordinateLayoutParentData;
    //交叉轴的最大值
    final crossAxisExtent = constraints.crossAxisExtent;
    /*final childBoxConstraints = constraints.axis == Axis.vertical
        ? BoxConstraints(
            minWidth: 0,
            maxWidth: constraints.crossAxisExtent,
            minHeight: 0,
            maxHeight: maxExtent ?? double.infinity,
          )
        : BoxConstraints(
            minWidth: 0,
            maxWidth: maxExtent ?? double.infinity,
            minHeight: 0,
            maxHeight: constraints.crossAxisExtent,
          );*/

    double? l = parentData.left;
    double? r = parentData.right;
    double? t = parentData.top;
    double? b = parentData.bottom;

    if (r != null) {
      if (constraints.axis == Axis.horizontal) {
        final maxWidth = parentData.maxWidth?.infinityOrNull(refMaxExtent) ??
            parentData.minWidth?.infinityOrNull(refMaxExtent) ??
            minExtent;
        if (maxWidth != double.infinity) {
          r = maxWidth - r;
          //debugger();
        }
      } else {
        r = crossAxisExtent - r;
      }
    }

    if (b != null) {
      //与底部的距离
      if (constraints.axis == Axis.vertical) {
        final maxHeight = parentData.maxHeight?.infinityOrNull(refMaxExtent) ??
            parentData.minHeight?.infinityOrNull(refMaxExtent) ??
            minExtent;
        if (maxHeight != double.infinity) {
          b = maxHeight - b;
          //debugger();
        }
      } else {
        b = crossAxisExtent - b;
      }
    }

    //计算出宽高测量值
    double? w, h;
    if (l != null && r != null) {
      w = r - l;
    }
    if (t != null && b != null) {
      h = b - t;
    }

    //debugger();
    final childBoxConstraints = constraints.axis == Axis.vertical
        ? BoxConstraints(
            //交叉轴
            minWidth:
                w ?? parentData.minWidth?.infinityOr(crossAxisExtent) ?? 0,
            maxWidth: w ??
                parentData.maxWidth?.infinityOr(crossAxisExtent) ??
                crossAxisExtent,
            //主轴
            minHeight: h ??
                parentData.minHeight?.infinityOrNull(refMaxExtent) ??
                minExtent,
            maxHeight: h ??
                parentData.maxHeight?.infinityOrNull(refMaxExtent) ??
                maxExtent ??
                double.infinity,
          )
        : BoxConstraints(
            //主轴
            minWidth: w ??
                parentData.minWidth?.infinityOrNull(refMaxExtent) ??
                minExtent,
            maxWidth: w ??
                parentData.maxWidth?.infinityOrNull(refMaxExtent) ??
                maxExtent ??
                double.infinity,
            //交叉轴
            minHeight:
                h ?? parentData.minHeight?.infinityOr(crossAxisExtent) ?? 0,
            maxHeight: h ??
                parentData.maxHeight?.infinityOr(crossAxisExtent) ??
                crossAxisExtent,
          );
    //debugger();
    return childBoxConstraints;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final bounds = paintBounds + offset;
    //l.d("paint->$offset bounds:$bounds overlap:${constraints.overlap} $_childOverlapTopOffset");

    /*canvas.drawRect(
      paintBounds.inflateValue(-constraints.overlap),
      Paint()
        ..shader = linearGradientShader([Colors.blueAccent, Colors.redAccent],
            rect: paintBounds) */ /*..color = Colors.blueAccent*/ /*,
    );*/

    final clipRect = Rect.fromLTRB(
      paintBounds.left + _childOverlapTopOffset.dx,
      paintBounds.top + _childOverlapTopOffset.dy,
      bounds.right - constraintsOverlapOffset.dx,
      bounds.bottom - constraintsOverlapOffset.dy,
    );
    //l.d("paint->clipRect:$clipRect $_childOverlapTopOffset $constraintsOverlapOffset");
    //canvas.save();
    //canvas.clipRect(clipRect);

    pushClipRectLayer(context, offset, clipRect, (context, offset) {
      for (final child in childrenIterable) {
        final childParentData =
            child.parentData as SliverScrollCoordinateLayoutParentData;
        //debugger();
        context.paintChild(child,
            offset + childParentData.getPaintOffset(paintBounds, child.size)
            /*+ Offset(0, -constraints.overlap)*/
            );
      }
    });

    // for (final child in childrenIterable) {
    //   final childParentData =
    //       child.parentData as SliverScrollCoordinateLayoutParentData;
    //   //debugger();
    //   context.paintChild(child,
    //       offset + childParentData.getPaintOffset(paintBounds, child.size)
    //       /*+ Offset(0, -constraints.overlap)*/
    //       );
    // }
    //canvas.restore();

    /*canvas.drawText(
        "[$childCount] ${(constraints.scrollOffset / (maxExtent! - minExtent)).toDigits()}\noffset:$offset scrollOffset:${constraints.scrollOffset.toDigits()}",
        textAlign: TextAlign.center,
        bounds: bounds,
        alignment: Alignment.center);*/
  }

  //endregion --布局--

  //region --事件--

  /// [BaseTapGestureRecognizer.handleTapDown]
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    //debugger();
    final childParentData =
        child.parentData as SliverScrollCoordinateLayoutParentData;
    final paintOffset = childParentData.getPaintOffset(paintBounds, child.size);
    transform.translate(paintOffset.dx, paintOffset.dy);
    applyPaintTransformForBoxChild(child, transform);
  }

  /// [hitTestChildren]驱动
  @override
  double childMainAxisPosition(RenderBox child) {
    //debugger();
    final childParentData =
        child.parentData as SliverScrollCoordinateLayoutParentData;
    final paintOffset = childParentData.getPaintOffset(paintBounds, child.size);
    return paintOffset.dy;
  }

  /// [hitTestChildren]驱动
  @override
  double childCrossAxisPosition(RenderBox child) {
    //debugger();
    final childParentData =
        child.parentData as SliverScrollCoordinateLayoutParentData;
    final paintOffset = childParentData.getPaintOffset(paintBounds, child.size);
    return paintOffset.dx;
  }

  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    //debugger();
    return super.hitTest(result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
  }

  /// [hitTestBoxChild]
  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    //debugger();
    final boxResult = BoxHitTestResult.wrap(result);
    for (final child in childrenInPaintOrderIterable) {
      final hit = hitTestBoxChild(boxResult, child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition);
      //debugger();
      if (hit) return true;
    }
    return false;
  }

//endregion --事件--
}

class SliverScrollCoordinateLayoutParentDataWidget
    extends ParentDataWidget<SliverScrollCoordinateLayoutParentData> {
  /// [SliverScrollCoordinateLayoutParentData.top]
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  /// [SliverScrollCoordinateLayoutParentData.minWidth]
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;

  /// [SliverScrollCoordinateLayoutParentData.onCoordinateChildAction]
  final CoordinateLayoutChildAction? onCoordinateChildAction;

  const SliverScrollCoordinateLayoutParentDataWidget({
    super.key,
    required super.child,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.onCoordinateChildAction,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! SliverScrollCoordinateLayoutParentData) {
      renderObject.parentData = SliverScrollCoordinateLayoutParentData();
    }
    final parentData = renderObject.parentData;
    if (parentData is SliverScrollCoordinateLayoutParentData) {
      //debugger();
      parentData
        ..left = left
        ..top = top
        ..right = right
        ..bottom = bottom
        ..minWidth = minWidth
        ..minHeight = minHeight
        ..maxWidth = maxWidth
        ..maxHeight = maxHeight
        ..onCoordinateChildAction = onCoordinateChildAction;
      if (renderObject.parent is RenderSliverScrollCoordinateLayout) {
        renderObject.parent?.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass =>
      SliverScrollCoordinateLayoutWidget;
}

/// 整体布局进度的回调
typedef CoordinateLayoutAction = bool Function(
  SliverConstraints constraints /*父容器的约束条件*/,
  double maxExtent /*父容器的最大高度*/,
  double scrollProgress /*当前滚动进度*/,
);

/// child 重新布局的回调拦截
typedef CoordinateLayoutChildAction = bool Function(
  SliverConstraints constraints /*父容器的约束条件*/,
  SliverScrollCoordinateLayoutParentData parentData /*布局数据*/,
  double scrollProgress /*当前滚动进度*/,
);

/// [SliverScrollCoordinateLayoutWidget]
/// [SliverScrollCoordinateLayoutParentDataWidget]
class SliverScrollCoordinateLayoutParentData
    extends ContainerBoxParentData<RenderBox> {
  /// 当前元素的位置
  double? top;
  double? right;
  double? bottom;
  double? left;

  /// 当前元素的大小
  double? minWidth;
  double? minHeight;
  double? maxWidth;
  double? maxHeight;

  /// 指定宽度
  set width(double? value) {
    minWidth = value;
    maxWidth = value;
  }

  /// 指定高度
  set height(double? value) {
    minHeight = value;
    maxHeight = value;
  }

  /// 协调布局的回调, child可以根据布局的进度进行布局的调整.
  /// 可以在此会调用动态设置[SliverScrollCoordinateLayoutParentData]的属性值, 达到动态布局的目的
  /// @return 返回是否改变了, 如果返回true, 则会重新布局
  CoordinateLayoutChildAction? onCoordinateChildAction;

  /// 绘制的偏移坐标
  Offset getPaintOffset(Rect parentBounds, Size childSize) {
    if (bottom != null) {
      final b = parentBounds.height - bottom! - childSize.height;
      if (right != null) {
        return Offset(parentBounds.width - right! - childSize.width, b);
      }
      return Offset(left ?? 0, b);
    }
    if (right != null) {
      return Offset(parentBounds.width - right! - childSize.width, top ?? 0);
    }
    return Offset(left ?? 0, top ?? 0);
  }

  @override
  String toString() {
    final List<String> values = <String>[
      if (top != null) 'top=${debugFormatDouble(top)}',
      if (right != null) 'right=${debugFormatDouble(right)}',
      if (bottom != null) 'bottom=${debugFormatDouble(bottom)}',
      if (left != null) 'left=${debugFormatDouble(left)}',
      if (minWidth != null) 'minWidth=${debugFormatDouble(minWidth)}',
      if (minHeight != null) 'minHeight=${debugFormatDouble(minHeight)}',
      if (maxWidth != null) 'maxWidth=${debugFormatDouble(maxWidth)}',
      if (maxHeight != null) 'maxHeight=${debugFormatDouble(maxHeight)}',
    ];
    if (values.isEmpty) values.add('not positioned');
    values.add(super.toString());
    return values.join('; ');
  }
}

extension SliverScrollCoordinateLayoutEx on Widget {
  /// [SliverScrollCoordinateLayoutParentData]
  Widget sliverCoordinateLayoutParentData({
    Key? key,
    // 当前元素的位置
    double? top,
    double? right,
    double? bottom,
    double? left,
    // 当前元素的大小
    double? width,
    double? height,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
    //--
    CoordinateLayoutChildAction? onCoordinateChildAction,
  }) =>
      SliverScrollCoordinateLayoutParentDataWidget(
        key: key,
        top: top,
        right: right,
        bottom: bottom,
        left: left,
        minWidth: width ?? minWidth,
        minHeight: height ?? minHeight,
        maxWidth: width ?? maxWidth,
        maxHeight: height ?? maxHeight,
        onCoordinateChildAction: onCoordinateChildAction,
        child: this,
      );
}
