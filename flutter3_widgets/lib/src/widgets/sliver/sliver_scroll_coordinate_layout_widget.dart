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
      child.layout(_getChildBoxConstraints(child, this.maxExtent),
          parentUsesSize: true);
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

    //处理滚动进度,重新布局
    final scrollProgress = constraints.scrollOffset / (maxExtent - minExtent);
    for (final child in childrenIterable) {
      //debugger();
      final parentData =
          child.parentData as SliverScrollCoordinateLayoutParentData;
      if (parentData.onCoordinateChildAction
              ?.call(constraints, parentData, scrollProgress) ==
          true) {
        child.layout(_getChildBoxConstraints(child, maxExtent),
            parentUsesSize: true);
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
    final double childExtent = maxExtent - minExtent;

    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: maxExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: maxExtent);

    final paintExtent = paintedChildSize.maxOf(minExtent);
    final hasVisualOverflow = childExtent > constraints.remainingPaintExtent ||
        constraints.scrollOffset > 0.0;

    // l.i("scrollProgress:$scrollProgress paintedChildSize:$paintedChildSize paintExtent:$paintExtent"
    //     " scrollOffset:${constraints.scrollOffset} overlap:${constraints.overlap} hasVisualOverflow:$hasVisualOverflow ");

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintExtent,
      maxPaintExtent: cacheExtent.maxOf(paintExtent),
      cacheExtent: cacheExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: hasVisualOverflow,
      paintOrigin: constraints.overlap > 0 ? constraints.overlap : 0,
    );
  }

  /// [BoxConstraints]
  BoxConstraints _getChildBoxConstraints(RenderBox child, double? maxExtent) {
    final parentData =
        child.parentData as SliverScrollCoordinateLayoutParentData;
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
      r = constraints.crossAxisExtent - r;
    }

    if (b != null) {
      //与底部的距离
      if (maxExtent != null) {
        b = maxExtent - b;
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
            minWidth: w ?? parentData.width ?? 0,
            maxWidth: w ?? parentData.width ?? constraints.crossAxisExtent,
            minHeight: h ?? parentData.height ?? 0,
            maxHeight: h ?? parentData.height ?? maxExtent ?? double.infinity,
          )
        : BoxConstraints(
            minWidth: w ?? parentData.width ?? 0,
            maxWidth: w ?? parentData.width ?? maxExtent ?? double.infinity,
            minHeight: h ?? parentData.height ?? 0,
            maxHeight: h ?? parentData.height ?? constraints.crossAxisExtent,
          );
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

  /// [SliverScrollCoordinateLayoutParentData.width]
  final double? width;
  final double? height;

  /// [SliverScrollCoordinateLayoutParentData.onCoordinateChildAction]
  final CoordinateLayoutChildAction? onCoordinateChildAction;

  const SliverScrollCoordinateLayoutParentDataWidget({
    super.key,
    required super.child,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.width,
    this.height,
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
        ..width = width
        ..height = height
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
  double? width;
  double? height;

  /// 协调布局的回调, child可以根据布局的进度进行布局的调整
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
      if (width != null) 'width=${debugFormatDouble(width)}',
      if (height != null) 'height=${debugFormatDouble(height)}',
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
    CoordinateLayoutChildAction? onCoordinateLayoutAction,
  }) =>
      SliverScrollCoordinateLayoutParentDataWidget(
        key: key,
        top: top,
        right: right,
        bottom: bottom,
        left: left,
        width: width,
        height: height,
        onCoordinateChildAction: onCoordinateLayoutAction,
        child: this,
      );
}
