part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/08
///
/// [left]..[center]..[right]
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

    //debugger();

    //
    Size centerSize = Size.zero;
    if (center != null) {
      centerSize =
          ChildLayoutHelper.layoutChild(center, const BoxConstraints());
      childMaxWidth = max(childMaxWidth, centerSize.width);
      childMaxHeight = max(childMaxHeight, centerSize.height);
      _offsetCenter(thisSize);
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
      _offsetLeft(thisSize);
    }
    //
    if (right != null) {
      ChildLayoutHelper.layoutChild(right, childConstraints);
      childMaxWidth = max(childMaxWidth, right.size.width);
      childMaxHeight = max(childMaxHeight, right.size.height);
      _offsetRight(thisSize);
    }
    //debugger();
    bool reOffset = false; //是否需要重新偏移child
    if (thisSize.width == double.infinity) {
      reOffset = true;
      if (axis == Axis.horizontal) {
        thisSize = Size(
          constraints.constrainWidth(
              children.fold(0, (value, child) => value + child.size.width)),
          thisSize.height.ensureValid(childMaxHeight),
        );
      } else {
        thisSize = Size(
          thisSize.width.ensureValid(childMaxWidth),
          constraints.constrainHeight(
              children.fold(0, (value, child) => value + child.size.height)),
        );
      }
    }
    if (thisSize.height == double.infinity) {
      reOffset = true;
      if (axis == Axis.horizontal) {
        thisSize = Size(
            constraints
                .constrainWidth(thisSize.width.ensureValid(childMaxWidth)),
            childMaxHeight);
      } else {
        thisSize = Size(
            childMaxWidth,
            constraints
                .constrainHeight(thisSize.height.ensureValid(childMaxHeight)));
      }
    }
    //重新偏移
    if (reOffset) {
      _offsetLeft(thisSize);
      _offsetCenter(thisSize);
      _offsetRight(thisSize);
    }
    //debugger();
    /*debugger(
        when: (left?.size.width ?? 0) +
                (center?.size.width ?? 0) +
                (right?.size.width ?? 0) >
            thisSize.width);*/
    size = thisSize;
  }

  void _offsetLeft(Size thisSize) {
    final child = getChildren().getOrNull(0);
    if (child != null && !child.size.isEmpty) {
      if (axis == Axis.horizontal) {
        child.setBoxOffset(
          offset: Offset(
            0,
            thisSize.height.ensureValid(child.size.height) / 2 -
                child.size.height / 2,
          ),
        );
      } else {
        child.setBoxOffset(
          offset: Offset(
            thisSize.width.ensureValid(child.size.width) / 2 -
                child.size.width / 2,
            0,
          ),
        );
      }
    }
  }

  void _offsetCenter(Size thisSize) {
    final child = getChildren().getOrNull(1);
    if (child != null) {
      final childSize = child.size;
      final offset = Offset(
        thisSize.width / 2 - childSize.width / 2,
        thisSize.height / 2 - childSize.height / 2,
      );
      child.setBoxOffset(offset: offset);
    }
  }

  void _offsetRight(Size thisSize) {
    final child = getChildren().getOrNull(2);
    if (child != null && !child.size.isEmpty) {
      if (axis == Axis.horizontal) {
        child.setBoxOffset(
          offset: Offset(
            thisSize.width - child.size.width,
            thisSize.height.ensureValid(child.size.height) / 2 -
                child.size.height / 2,
          ),
        );
      } else {
        child.setBoxOffset(
          offset: Offset(
            thisSize.width.ensureValid(child.size.width) / 2 -
                child.size.width / 2,
            thisSize.height - child.size.height,
          ),
        );
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //debugger();
    defaultPaint(context, offset);
  }
}

class RenderLeftCenterRightLayoutParentData
    extends ContainerBoxParentData<RenderBox> {}
