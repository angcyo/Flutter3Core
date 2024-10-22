part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/06
///
/// 线性布局, 支持横向/纵向排列
class LinearLayout extends MultiChildRenderObjectWidget {
  /// 主轴方向, 默认横向排列
  final Axis mainAxis;

  const LinearLayout({
    super.key,
    this.mainAxis = Axis.horizontal,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => LinearLayoutRender(
        mainAxis: mainAxis,
      );

  @override
  void updateRenderObject(
      BuildContext context, LinearLayoutRender renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..mainAxis = mainAxis
      ..markNeedsLayout();
  }
}

class LinearLayoutRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LinearLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LinearLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  /// 主轴方向, 默认横向排列
  Axis mainAxis;

  LinearLayoutRender({this.mainAxis = Axis.horizontal});

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! LinearLayoutParentData) {
      child.parentData = LinearLayoutParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final children = getChildren();
    //debugger();
    final (childMaxWidth, childMaxHeight) = measureWrapChildren(
      children,
      parentConstraints: constraints,
    );
    //debugger();
    layoutLinearChildren(children, mainAxis);

    final width = mainAxis == Axis.horizontal
        ? getAllLinearChildWidth(children)
        : childMaxWidth;
    final height = mainAxis == Axis.horizontal
        ? childMaxHeight
        : getAllLinearChildHeight(children);

    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    paintLayoutChildren(getChildren(), context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    //debugger();
    return hitLayoutChildren(
      getChildren(),
      result,
      position: position,
    );
  }
}

class LinearLayoutParentData extends ContainerBoxParentData<RenderBox> {
  LinearLayoutParentData();
}

extension LinearLayoutEx on Widget {
  /// 线性布局
  Widget? linearLayout({
    Axis mainAxis = Axis.horizontal,
  }) =>
      [this].linearLayout(mainAxis: mainAxis);
}

extension LinearLayoutListEx on WidgetNullList {
  /// 线性布局
  Widget? linearLayout({
    Axis mainAxis = Axis.horizontal,
  }) {
    WidgetList list = filterNull();
    if (isNil(list)) {
      return null;
    }
    return LinearLayout(
      mainAxis: mainAxis,
      children: list,
    );
  }
}
