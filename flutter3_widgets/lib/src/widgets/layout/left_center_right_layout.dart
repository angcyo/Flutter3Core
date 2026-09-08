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

  /// 是否优先测量左边
  final bool priorityLeft;

  /// 是否优先测量右边
  final bool priorityRight;

  /// 左边最小宽度
  final double leftMaxWidth;

  /// 左边最小高度
  final double leftMaxHeight;

  /// 右边最小宽度
  final double rightMaxWidth;

  /// 右边最小高度
  final double rightMaxHeight;

  LeftCenterRightLayout({
    super.key,
    Widget? left,
    Widget? center,
    Widget? right,
    this.axis = Axis.horizontal,
    this.priorityLeft = false,
    this.priorityRight = false,
    this.leftMaxWidth = double.infinity,
    this.leftMaxHeight = double.infinity,
    this.rightMaxWidth = double.infinity,
    this.rightMaxHeight = double.infinity,
  }) : super(children: [left ?? empty, center ?? empty, right ?? empty]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeftCenterRightLayout(
      axis: axis,
      priorityLeft: priorityLeft,
      priorityRight: priorityRight,
      leftMaxWidth: leftMaxWidth,
      leftMaxHeight: leftMaxHeight,
      rightMaxWidth: rightMaxWidth,
      rightMaxHeight: rightMaxHeight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLeftCenterRightLayout renderObject,
  ) {
    renderObject
      ..axis = axis
      ..priorityLeft = priorityLeft
      ..priorityRight = priorityRight
      ..leftMaxHeight = leftMaxHeight
      ..leftMaxWidth = leftMaxWidth
      ..rightMaxHeight = rightMaxHeight
      ..rightMaxWidth = rightMaxWidth
      ..markNeedsLayout();
  }
}

class RenderLeftCenterRightLayout extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          RenderLeftCenterRightLayoutParentData
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          RenderLeftCenterRightLayoutParentData
        >,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  /// 方向
  Axis axis;

  /// 左边最小宽度
  double leftMaxWidth;

  /// 左边最小高度
  double leftMaxHeight;

  /// 右边最小宽度
  double rightMaxWidth;

  /// 右边最小高度
  double rightMaxHeight;

  /// 是否优先测量左边
  bool priorityLeft;

  /// 是否优先测量右边
  bool priorityRight;

  RenderLeftCenterRightLayout({
    this.axis = .horizontal,
    this.priorityLeft = false,
    this.priorityRight = false,
    this.leftMaxWidth = double.infinity,
    this.leftMaxHeight = double.infinity,
    this.rightMaxWidth = double.infinity,
    this.rightMaxHeight = double.infinity,
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
    Size leftSize = Size.zero;
    Size rightSize = Size.zero;
    if (priorityLeft && left != null) {
      ChildLayoutHelper.layoutChild(
        left,
        BoxConstraints(
          maxWidth: leftMaxWidth.isInfinite || leftMaxWidth > 0
              ? leftMaxWidth
              : constraints.maxWidth,
          maxHeight: leftMaxHeight.isInfinite || leftMaxHeight > 0
              ? leftMaxHeight
              : constraints.maxHeight,
        ),
      );
      leftSize = left.size;
    }
    if (priorityRight && right != null) {
      ChildLayoutHelper.layoutChild(
        right,
        BoxConstraints(
          maxWidth: rightMaxWidth.isInfinite || rightMaxWidth > 0
              ? rightMaxWidth
              : constraints.maxWidth,
          maxHeight: rightMaxHeight.isInfinite || rightMaxHeight > 0
              ? rightMaxHeight
              : constraints.maxHeight,
        ),
      );
      rightSize = right.size;
    }

    //
    Size centerSize = Size.zero;
    if (center != null) {
      final leftUseWidth = leftSize.width >= constraints.maxWidth
          ? leftMaxWidth
          : leftSize.width;
      final leftUseHeight = leftSize.height >= constraints.maxHeight
          ? leftMaxHeight
          : leftSize.height;
      final rightUseWidth = rightSize.width >= constraints.maxWidth
          ? rightMaxWidth
          : rightSize.width;
      final rightUseHeight = rightSize.height >= constraints.maxHeight
          ? rightMaxHeight
          : rightSize.height;
      final centerMaxWidth = constraints.maxWidth.isValid && axis == .horizontal
          ? constraints.maxWidth -
                maxOf(leftUseWidth, leftMaxWidth) -
                maxOf(rightUseWidth, rightMaxWidth)
          : double.infinity;
      final centerMaxHeight = constraints.maxHeight.isValid && axis == .vertical
          ? constraints.maxHeight -
                maxOf(leftUseHeight, leftMaxHeight) -
                maxOf(rightUseHeight, rightMaxHeight)
          : double.infinity;
      final centerConstraints = BoxConstraints(
        maxWidth: centerMaxWidth.isFinite
            ? maxOf(0, centerMaxWidth)
            : centerMaxWidth,
        maxHeight: centerMaxHeight.isFinite
            ? maxOf(0, centerMaxHeight)
            : centerMaxHeight,
      );
      centerSize = ChildLayoutHelper.layoutChild(center, centerConstraints);
      childMaxWidth = max(childMaxWidth, centerSize.width);
      childMaxHeight = max(childMaxHeight, centerSize.height);
      _offsetCenter(center, thisSize);
      debugger(when: constraints.maxWidth - centerSize.width < 0);
    }
    //
    final childConstraints = BoxConstraints(
      maxWidth: axis == .horizontal
          ? maxOf(0, (constraints.maxWidth - centerSize.width) / 2)
          : constraints.maxWidth,
      maxHeight: axis == .vertical
          ? maxOf(0, (constraints.maxHeight - centerSize.height) / 2)
          : constraints.maxHeight,
    );
    //
    if (left != null) {
      if (!priorityLeft) {
        ChildLayoutHelper.layoutChild(left, childConstraints);
        leftSize = left.size;
      }
      childMaxWidth = max(childMaxWidth, leftSize.width);
      childMaxHeight = max(childMaxHeight, leftSize.height);
      _offsetLeft(left, thisSize);
    }
    //
    if (right != null) {
      if (!priorityRight) {
        ChildLayoutHelper.layoutChild(right, childConstraints);
        rightSize = right.size;
      }
      childMaxWidth = max(childMaxWidth, rightSize.width);
      childMaxHeight = max(childMaxHeight, rightSize.height);
      _offsetRight(right, thisSize);
    }
    //debugger();
    bool reOffset = false; //是否需要重新偏移child
    if (thisSize.width == double.infinity) {
      reOffset = true;
      if (axis == Axis.horizontal) {
        thisSize = Size(
          constraints.constrainWidth(
            children.fold(0, (value, child) => value + child.size.width),
          ),
          thisSize.height.ensureValid(childMaxHeight),
        );
      } else {
        thisSize = Size(
          thisSize.width.ensureValid(childMaxWidth),
          constraints.constrainHeight(
            children.fold(0, (value, child) => value + child.size.height),
          ),
        );
      }
    }
    if (thisSize.height == double.infinity) {
      reOffset = true;
      if (axis == Axis.horizontal) {
        thisSize = Size(
          constraints.constrainWidth(thisSize.width.ensureValid(childMaxWidth)),
          childMaxHeight,
        );
      } else {
        thisSize = Size(
          childMaxWidth,
          constraints.constrainHeight(
            thisSize.height.ensureValid(childMaxHeight),
          ),
        );
      }
    }
    //重新偏移
    if (reOffset) {
      _offsetLeft(left, thisSize);
      _offsetCenter(center, thisSize);
      _offsetRight(right, thisSize);
    }
    //debugger();
    /*debugger(
        when: (left?.size.width ?? 0) +
                (center?.size.width ?? 0) +
                (right?.size.width ?? 0) >
            thisSize.width);*/
    size = thisSize;
    _printChildOffset();
  }

  void _offsetLeft(RenderBox? child, Size thisSize) {
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

  void _offsetCenter(RenderBox? child, Size thisSize) {
    if (child != null) {
      final childSize = child.size;
      final offset = Offset(
        thisSize.width / 2 - childSize.width / 2,
        thisSize.height / 2 - childSize.height / 2,
      );
      child.setBoxOffset(offset: offset);
    }
  }

  void _offsetRight(RenderBox? child, Size thisSize) {
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
    _printChildOffset();
    defaultPaint(context, offset);
  }

  /// 打印child的offset
  void _printChildOffset() {
    /*getChildren().forEachIndexed((index, child) {
      l.d('[$index] ${child.runtimeType} ${child.offset}');
    });*/
  }
}

class RenderLeftCenterRightLayoutParentData
    extends ContainerBoxParentData<RenderBox> {}
