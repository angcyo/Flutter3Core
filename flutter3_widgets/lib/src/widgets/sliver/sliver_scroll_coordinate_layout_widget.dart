part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/23
///
class SliverScrollCoordinateLayoutWidget extends MultiChildRenderObjectWidget {
  /// 最小范围
  final double minExtent;

  /// 最大范围
  final double? maxExtent;

  const SliverScrollCoordinateLayoutWidget({
    super.key,
    super.children /*RenderBox*/,
    this.minExtent = 0,
    this.maxExtent,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderSliverScrollCoordinateLayout()
        ..minExtent = minExtent
        ..maxExtent = maxExtent;

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverScrollCoordinateLayout renderObject,
  ) {
    renderObject
      ..minExtent = minExtent
      ..maxExtent = maxExtent
      ..markNeedsLayout();
  }
}

class RenderSliverScrollCoordinateLayout extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerParentDataMixin<RenderBox>>,
        RenderSliverHelpers {
  /// 最小范围
  double minExtent = 0;

  /// 最大范围
  double? maxExtent;

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

  @override
  void performLayout() {
    final constraints = this.constraints;

    double maxChildWidth = 0, maxChildHeight = 0;
    for (final child in childrenIterable) {
      child.layout(_getChildBoxConstraints(child), parentUsesSize: true);
      final childSize = child.size;
      maxChildWidth = maxChildWidth.maxOf(childSize.width);
      maxChildHeight = maxChildHeight.maxOf(childSize.height);
      //debugger();
    }
    maxExtent ??=
        constraints.axis == Axis.vertical ? maxChildHeight : maxChildWidth;

    //滚动进度
    final scrollProgress = constraints.scrollOffset / (maxExtent! - minExtent);
    for (final child in childrenIterable) {
      final parentData =
          child.parentData as SliverScrollCoordinateLayoutParentData;
      if (parentData.onCoordinateLayoutAction
              ?.call(constraints, parentData, scrollProgress) ==
          true) {
        child.layout(_getChildBoxConstraints(child), parentUsesSize: true);
      }
    }

    //--
    final double childExtent = maxExtent! - minExtent;

    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: maxExtent!);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: maxExtent!);

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize.maxOf(minExtent),
      cacheExtent: cacheExtent,
      maxPaintExtent: cacheExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
  }

  /// [BoxConstraints]
  BoxConstraints _getChildBoxConstraints(RenderBox child) {
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
    final childBoxConstraints = constraints.axis == Axis.vertical
        ? BoxConstraints(
            minWidth: parentData.width ?? 0,
            maxWidth: parentData.width ?? constraints.crossAxisExtent,
            minHeight: parentData.height ?? 0,
            maxHeight: parentData.height ?? maxExtent ?? double.infinity,
          )
        : BoxConstraints(
            minWidth: parentData.width ?? 0,
            maxWidth: parentData.width ?? maxExtent ?? double.infinity,
            minHeight: parentData.height ?? 0,
            maxHeight: parentData.height ?? constraints.crossAxisExtent,
          );
    return childBoxConstraints;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final bounds = paintBounds + offset;

    /*canvas.drawRect(
      bounds,
      Paint()
        ..color = Colors.blueAccent,
    );*/

    //canvas.save();
    canvas.clipRect(bounds);
    for (final child in childrenIterable) {
      final childParentData =
          child.parentData as SliverScrollCoordinateLayoutParentData;
      context.paintChild(child,
          offset + childParentData.getPaintOffset(paintBounds, child.size));
    }

    /*canvas.drawText(
        "[$childCount] ${(constraints.scrollOffset / (maxExtent! - minExtent))
            .toDigits()}\noffset:$offset scrollOffset:${constraints.scrollOffset
            .toDigits()}",
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

  /// [hitTestBoxChild]
  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
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
  /// 当前元素的位置
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  /// 当前元素的大小
  final double? width;
  final double? height;

  /// 协调布局的回调
  /// @return 返回是否改变了, 如果返回true, 则会重新布局
  final CoordinateLayoutAction? onCoordinateLayoutAction;

  const SliverScrollCoordinateLayoutParentDataWidget({
    super.key,
    required super.child,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.width,
    this.height,
    this.onCoordinateLayoutAction,
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
        ..onCoordinateLayoutAction = onCoordinateLayoutAction;
      if (renderObject.parent is RenderSliverScrollCoordinateLayout) {
        renderObject.parent?.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass =>
      SliverScrollCoordinateLayoutWidget;
}

typedef CoordinateLayoutAction = bool Function(
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

  /// 协调布局的回调
  /// @return 返回是否改变了, 如果返回true, 则会重新布局
  CoordinateLayoutAction? onCoordinateLayoutAction;

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
    CoordinateLayoutAction? onCoordinateLayoutAction,
  }) =>
      SliverScrollCoordinateLayoutParentDataWidget(
        key: key,
        top: top,
        right: right,
        bottom: bottom,
        left: left,
        width: width,
        height: height,
        onCoordinateLayoutAction: onCoordinateLayoutAction,
        child: this,
      );
}
