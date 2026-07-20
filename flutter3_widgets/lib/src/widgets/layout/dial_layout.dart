part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/20
///
/// 表盘布局 / 圆环布局
/// 将多个矩形按照不同半径的圆形（同心圆）进行排列，在计算机图形学、UI 设计（如表盘布局）和数据可视化（如 Circos 图）中是一个非常经典的计算几何问题。
///
/// 要实现这个布局，核心在于极坐标系与笛卡尔坐标系的转换，以及通过弦长公式计算矩形在圆周上占据的角度。
class DialLayout extends MultiChildRenderObjectWidget {
  /// 最内侧圆的初始半径
  final double initialRadius;

  /// 两个同心圆轨道之间的间距 (高度方向)
  final double radialGap;

  /// 同一圆轨道上，两个矩形之间的弦长间距 (宽度方向)
  final double arcGap;

  const DialLayout({
    super.key,
    super.children,
    this.initialRadius = 60,
    this.radialGap = 30,
    this.arcGap = 30,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => DialLayoutRender(
    initialRadius: initialRadius,
    radialGap: radialGap,
    arcGap: arcGap,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant DialLayoutRender renderObject,
  ) {
    renderObject
      ..initialRadius = initialRadius
      ..radialGap = radialGap
      ..arcGap = arcGap
      ..markNeedsLayout();
  }
}

class DialLayoutRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DialLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DialLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  /// 最内侧圆的初始半径
  double initialRadius;

  /// 两个同心圆轨道之间的间距 (高度方向)
  double radialGap;

  /// 同一圆轨道上，两个矩形之间的弦长间距 (宽度方向)
  double arcGap;

  DialLayoutRender({
    this.initialRadius = 60,
    this.radialGap = 30,
    this.arcGap = 30,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    //debugger();
    if (child.parentData is! DialLayoutParentData) {
      child.parentData = DialLayoutParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required ui.Offset position}) {
    return hitLayoutChildren(
      getChildren(),
      result,
      position: position,
      transform: effectiveTransform,
    );
  }

  /// 计算出来的矩阵
  /// - [RenderTransform]
  Matrix4? _effectiveTransform;

  Matrix4? get effectiveTransform => _effectiveTransform;

  @override
  void performLayout() {
    final constraints = this.constraints;
    final children = getChildren();
    if (children.isEmpty) {
      size = constraints.biggest;
      return;
    }
    //debugger();
    measureWrapChildren(children, parentConstraints: constraints);

    final rectangles = children
        .mapIndex(
          (child, index) => LayoutRectangle(
            id: index,
            width: child.size.width,
            height: child.size.height,
          ),
        )
        .toList();
    final placed = DialLayoutHelper.arrangeNonIntersectingCircles(
      rectangles: rectangles,
      initialRadius: initialRadius,
      radialGap: radialGap,
      arcGap: arcGap,
      autoRotate: false,
    );

    double minLeft = double.infinity;
    double minTop = double.infinity;
    double maxRight = -double.infinity;
    double maxBottom = -double.infinity;
    for (final rectangle in placed) {
      final child = children[rectangle.id];
      final childParentData = child.parentData as DialLayoutParentData;
      final left = rectangle.centerX - child.size.width / 2;
      final top = rectangle.centerY - child.size.height / 2;
      final right = left + child.size.width;
      final bottom = top + child.size.height;
      minLeft = min(minLeft, left);
      minTop = min(minTop, top);
      maxRight = max(maxRight, right);
      maxBottom = max(maxBottom, bottom);
      childParentData.offset = Offset(left, top);
    }

    //debugger();
    //layoutLinearChildren(children, mainAxis);

    final width = constraints.maxWidth.ensureValid(maxRight - minLeft);
    final height = constraints.maxHeight.ensureValid(maxBottom - minTop);

    _effectiveTransform = createTranslateMatrix(tx: width / 2, ty: height / 2);
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    paintLayoutChildren(
      getChildren(),
      context,
      offset,
      transform: effectiveTransform,
    );
    debugPaintBoxBounds(context, offset);
  }

  /// - [RenderTransform]
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Matrix4? effectiveTransform = _effectiveTransform;
    if (effectiveTransform != null) {
      transform.multiply(effectiveTransform);
    }
  }
}

/// 布局数据
class DialLayoutParentData extends ContainerBoxParentData<RenderBox> {
  DialLayoutParentData();
}
