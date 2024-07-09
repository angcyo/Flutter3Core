part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/08
///
/// [left] [center] [right]
/// [left].[right]平分去除[center]之后的剩余空间
class LeftCenterRightLayout extends MultiChildRenderObjectWidget {
  /// 方向
  final Axis axis;

  LeftCenterRightLayout({
    super.key,
    Widget? left,
    Widget? center,
    Widget? right,
    this.axis = Axis.horizontal,
  }) : super(children: [
          left ?? empty,
          center ?? empty,
          right ?? empty,
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeftCenterRightLayout(axis: axis);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLeftCenterRightLayout renderObject,
  ) {
    renderObject
      ..axis = axis
      ..markNeedsLayout();
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
  /// 方向
  Axis axis;

  RenderLeftCenterRightLayout({
    this.axis = Axis.horizontal,
  });

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
    Size thisSize = constraints.biggest;
    double childMaxWidth = 0;
    double childMaxHeight = 0;

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
      childMaxWidth = max(childMaxWidth, centerSize.width);
      childMaxHeight = max(childMaxHeight, centerSize.height);
      if (!centerSize.isEmpty) {
        centerOffset = Offset(
          thisSize.width / 2 - centerSize.width / 2,
          thisSize.height / 2 - centerSize.height / 2,
        );
        (center.parentData as BoxParentData).offset = centerOffset;
      }
    }
    //
    final childConstraints = BoxConstraints(
      maxWidth: (constraints.maxWidth - centerSize.width) / 2,
      maxHeight: constraints.maxHeight,
    );
    //
    if (left != null) {
      ChildLayoutHelper.layoutChild(left, childConstraints);
      childMaxWidth = max(childMaxWidth, left.size.width);
      childMaxHeight = max(childMaxHeight, left.size.height);
      if (!left.size.isEmpty) {
        if (axis == Axis.horizontal) {
          (left.parentData as BoxParentData).offset = Offset(
            0,
            thisSize.height.ensureValid(left.size.height) / 2 -
                left.size.height / 2,
          );
        } else {
          (left.parentData as BoxParentData).offset = Offset(
            thisSize.width.ensureValid(left.size.width) / 2 -
                left.size.width / 2,
            0,
          );
        }
      }
    }
    //
    if (right != null) {
      ChildLayoutHelper.layoutChild(right, childConstraints);
      childMaxWidth = max(childMaxWidth, right.size.width);
      childMaxHeight = max(childMaxHeight, right.size.height);
      if (!right.size.isEmpty) {
        if (axis == Axis.horizontal) {
          (right.parentData as BoxParentData).offset = Offset(
            thisSize.width - right.size.width,
            thisSize.height.ensureValid(right.size.height) / 2 -
                right.size.height / 2,
          );
        } else {
          (right.parentData as BoxParentData).offset = Offset(
            thisSize.width.ensureValid(right.size.width) / 2 -
                right.size.width / 2,
            thisSize.height - right.size.height,
          );
        }
      }
    }
    //debugger();
    if (thisSize.width == double.infinity) {
      if (axis == Axis.horizontal) {
        thisSize = Size(
          children.fold(0, (value, child) => value + child.size.width),
          thisSize.height,
        );
      } else {
        thisSize = Size(
          thisSize.width,
          children.fold(0, (value, child) => value + child.size.height),
        );
      }
    }
    if (thisSize.height == double.infinity) {
      if (axis == Axis.horizontal) {
        thisSize = Size(thisSize.width, childMaxHeight);
      } else {
        thisSize = Size(childMaxWidth, thisSize.height);
      }
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
