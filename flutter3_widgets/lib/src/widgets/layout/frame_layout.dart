part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// 将自身的约束, 同步作用到所有子元素
///
/// - [Stack]
/// - [FlowLayout]
class FrameLayout extends MultiChildRenderObjectWidget {
  const FrameLayout({super.key, super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return FrameLayoutRender();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    FrameLayoutRender renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
  }

  @override
  void didUnmountRenderObject(FrameLayoutRender renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

  ///
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    //l.d("");
  }
}

/// 布局数据
class FrameLayoutParentData extends ContainerBoxParentData<RenderBox> {
  FrameLayoutParentData();

  @override
  void detach() {
    super.detach();
  }

  @override
  String toString() {
    return super.toString();
  }
}

/// [FrameLayoutParentData] 的包裹类
class FrameLayoutDataWidget extends ParentDataWidget<FrameLayoutParentData> {
  const FrameLayoutDataWidget({super.key, required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is FrameLayoutParentData);
    final FrameLayoutParentData parentData =
        renderObject.parentData! as FrameLayoutParentData;
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FrameLayout;
}

/// [FlowLayout] 的渲染对象
class FrameLayoutRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FrameLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FrameLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  FrameLayoutRender();

  @override
  void setupParentData(covariant RenderObject child) {
    //debugger();
    if (child.parentData is! FrameLayoutParentData) {
      child.parentData = FrameLayoutParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;

    double childMaxWidth = 0;
    double childMaxHeight = 0;
    final children = getChildren();
    for (final child in children) {
      final childConstraints = constraints;
      ChildLayoutHelper.layoutChild(child, childConstraints);
      final childSize = child.size;
      childMaxWidth = max(childMaxWidth, childSize.width);
      childMaxHeight = max(childMaxHeight, childSize.height);
    }
    size = constraints.constrain(Size(childMaxWidth, childMaxHeight));
    //debugger();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    defaultPaint(context, offset);
  }
}

extension FrameLayoutEx on Widget {
  /// 将[before].[this]和[after] 使用[FrameLayout]包裹
  Widget frameOf(Widget? after, {Widget? before, Key? key}) =>
      after == null && before == null
      ? this
      : [before, this, after].frame(key: key)!;
}

extension FrameLayoutListEx on WidgetNullList {
  /// [FrameLayout]
  Widget? frame({Key? key}) {
    WidgetList list = filterNull();
    if (isNullOrEmpty(list)) {
      return null;
    }
    return FrameLayout(key: key, children: list);
  }
}
