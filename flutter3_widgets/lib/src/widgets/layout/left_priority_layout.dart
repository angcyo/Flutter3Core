part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/16
///
/// [left].[right]
/// 优先保证右边的布局宽度, 剩余空间给左边的布局
/// 左边布局的宽度永远不会超过[parent-right]的宽度
class LeftPriorityLayout extends MultiChildRenderObjectWidget {
  /// 对齐方式, 一行中顶部对齐/底部对齐/居中对齐
  final MainAxisAlignment alignment;

  LeftPriorityLayout({
    super.key,
    Widget? left,
    Widget? right,
    this.alignment = MainAxisAlignment.center,
  }) : super(children: [
          left ?? empty,
          right ?? empty,
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeftPriorityLayout(alignment: alignment);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLeftPriorityLayout renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..markNeedsLayout();
  }
}

class RenderLeftPriorityLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            RenderLeftPriorityLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            RenderLeftPriorityLayoutParentData>,
        DebugOverflowIndicatorMixin,
        LayoutMixin {
  MainAxisAlignment alignment;

  RenderLeftPriorityLayout({
    this.alignment = MainAxisAlignment.center,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RenderLeftPriorityLayoutParentData) {
      child.parentData = RenderLeftPriorityLayoutParentData();
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
    final right = children.getOrNull(1);

    //1: 测量

    //先保证right布局
    if (right != null) {
      //debugger();
      ChildLayoutHelper.layoutChild(right, const BoxConstraints());
      childMaxWidth = max(childMaxWidth, right.size.width);
      childMaxHeight = max(childMaxHeight, right.size.height);
    }
    if (left != null) {
      final rightSize = right?.size;
      if (rightSize == null) {
        ChildLayoutHelper.layoutChild(left, constraints);
      } else {
        //debugger();
        final leftConstraints = BoxConstraints(
          minWidth: 0,
          minHeight: constraints.minHeight,
          maxWidth: constraints.maxWidth - rightSize.width,
          maxHeight: constraints.maxHeight,
        );
        ChildLayoutHelper.layoutChild(left, leftConstraints);
      }
      childMaxWidth = max(childMaxWidth, left.size.width);
      childMaxHeight = max(childMaxHeight, left.size.height);
    }

    //2: 布局
    final childSize = Size(
        (left?.size.width ?? 0) + (right?.size.width ?? 0), childMaxHeight);
    thisSize = constraints.constrain(childSize);

    if (alignment == MainAxisAlignment.center) {
      left?.setBoxOffset(dx: 0, dy: (thisSize.height - left.size.height) / 2);
      right?.setBoxOffset(
          dx: left?.size.width ?? 0,
          dy: (thisSize.height - right.size.height) / 2);
    } else if (alignment == MainAxisAlignment.end) {
      left?.setBoxOffset(dx: 0, dy: thisSize.height - left.size.height);
      right?.setBoxOffset(
          dx: left?.size.width ?? 0, dy: thisSize.height - right.size.height);
    } else {
      left?.setBoxOffset(dx: 0, dy: 0);
      right?.setBoxOffset(dx: left?.size.width ?? 0, dy: 0);
    }
    //debugger();
    size = thisSize;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class RenderLeftPriorityLayoutParentData
    extends ContainerBoxParentData<RenderBox> {}
