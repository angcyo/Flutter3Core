part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/08
///
/// [left] [center] [right]
/// [left].[right]平分去除[center]之后的剩余空间
class LeftCenterRightLayout extends MultiChildRenderObjectWidget {
  LeftCenterRightLayout({
    super.key,
    Widget? left,
    Widget? center,
    Widget? right,
  }) : super(children: [
          left ?? empty,
          center ?? empty,
          right ?? empty,
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeftCenterRightLayout();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLeftCenterRightLayout renderObject,
  ) {
    renderObject.markNeedsLayout();
  }
}

class RenderLeftCenterRightLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            RenderLeftCenterRightLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            RenderLeftCenterRightLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  RenderLeftCenterRightLayout();

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderLeftCenterRightLayoutParentData) {
      child.parentData = RenderLeftCenterRightLayoutParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    //debugger();
    final BoxConstraints constraints = this.constraints;
    final thisSize = constraints.biggest;

    final children = getChildren();
    final left = children.getOrNull(0);
    final center = children.getOrNull(1);
    final right = children.getOrNull(2);

    //
    Size centerSize = Size.zero;
    Offset centerOffset = thisSize.center(Offset.zero);
    if (center != null) {
      centerSize =
          ChildLayoutHelper.layoutChild(center, const BoxConstraints());
      centerOffset = Offset(
        thisSize.width / 2 - centerSize.width / 2,
        thisSize.height / 2 - centerSize.height / 2,
      );
      (center.parentData as BoxParentData).offset = centerOffset;
    }
    //
    final childConstraints = BoxConstraints(
      maxWidth: (constraints.maxWidth - centerSize.width) / 2,
      maxHeight: constraints.maxHeight,
    );
    //
    if (left != null) {
      ChildLayoutHelper.layoutChild(left, childConstraints);
      (left.parentData as BoxParentData).offset = Offset(
        0,
        thisSize.height / 2 - left.size.height / 2,
      );
    }
    //
    if (right != null) {
      ChildLayoutHelper.layoutChild(right, childConstraints);
      (right.parentData as BoxParentData).offset = Offset(
        thisSize.width - right.size.width,
        thisSize.height / 2 - right.size.height / 2,
      );
    }
    size = thisSize;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class RenderLeftCenterRightLayoutParentData
    extends ContainerBoxParentData<RenderBox> {}
