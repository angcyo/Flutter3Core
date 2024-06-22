part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/22
///
/// [FlowLayout]
class FrameLayout extends MultiChildRenderObjectWidget {
  const FrameLayout({
    super.key,
    super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    throw UnimplementedError();
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
  }

  @override
  void didUnmountRenderObject(covariant RenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }

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
class FrameLayoutData extends ParentDataWidget<FrameLayoutParentData> {
  const FrameLayoutData({
    super.key,
    required super.child,
  });

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
        ContainerRenderObjectMixin<RenderBox, FlowLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlowLayoutParentData>,
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
    final children = getChildren();
    for (final child in children) {
      final childConstraints = constraints;
      ChildLayoutHelper.layoutChild(child, childConstraints);
    }
    size = constraints.constrain(constraints.biggest);
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    defaultPaint(context, offset);
  }
}
