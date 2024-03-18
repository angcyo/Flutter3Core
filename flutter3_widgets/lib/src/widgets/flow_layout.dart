part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///
/// 流式布局
/// [Flex]
class FlowLayout extends MultiChildRenderObjectWidget {
  const FlowLayout({super.key, super.children});

  @override
  FlowLayoutRender createRenderObject(BuildContext context) =>
      FlowLayoutRender();

  @override
  void updateRenderObject(BuildContext context, FlowLayoutRender renderObject) {
    super.updateRenderObject(context, renderObject);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

/// 布局数据
/// [FlexParentData]
class FlowLayoutParentData extends ContainerBoxParentData<RenderBox> {}

/// 提供布局数据的小部件
/// [Flexible]
class FlowLayoutData extends ParentDataWidget<FlowLayoutParentData> {
  const FlowLayoutData({super.key, required super.child});

  /// [RenderObjectElement.attachRenderObject]
  /// [RenderObjectElement._updateParentData]
  @override
  void applyParentData(RenderObject renderObject) {
    //debugger();
    assert(renderObject.parentData is FlowLayoutParentData);
    final FlowLayoutParentData parentData =
        renderObject.parentData! as FlowLayoutParentData;

    bool needsLayout = false;

    if (needsLayout) {
      final RenderObject? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => FlowLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

/// flow布局实现
/// [RenderFlex]
class FlowLayoutRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlowLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlowLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  /// [RenderObjectElement.attachRenderObject]
  /// [MultiChildRenderObjectElement.insertRenderObjectChild]
  /// [RenderObject.adoptChild] 触发
  @override
  void setupParentData(covariant RenderObject child) {
    //debugger();
    if (child.parentData is! FlowLayoutParentData) {
      child.parentData = FlowLayoutParentData();
    }
  }

  @override
  ui.Size computeDryLayout(covariant BoxConstraints constraints) {
    return super.computeDryLayout(constraints);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    //getChildrenAsList()
    final BoxConstraints constraints = this.constraints;
    eachChildIndex((child, index) {
      //debugger();
      final FlowLayoutParentData childParentData =
          child.parentData! as FlowLayoutParentData;
      size = ChildLayoutHelper.layoutChild(child, constraints);
    });
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (size.isEmpty) {
      return;
    }
    defaultPaint(context, offset);
  }
}
