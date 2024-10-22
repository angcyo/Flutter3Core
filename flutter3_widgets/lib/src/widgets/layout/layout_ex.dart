part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///

enum ConstraintsType {
  /// 包裹内容
  wrapContent,

  /// 撑满父布局
  matchParent,

  /// 固定大小 此时[minWidth].[maxWidth]相等
  /// 取[maxWidth]
  fixedSize,
}

mixin LayoutParentData on ParentData {
  /// 外边距
  EdgeInsets? layoutMargin;
}

/// [LayoutParentData]
extension LayoutParentDataEx on ParentData {
  double get layoutMarginHorizontal => (this is LayoutParentData)
      ? (this as LayoutParentData).layoutMargin?.horizontal ?? 0
      : 0;

  double get layoutMarginVertical => (this is LayoutParentData)
      ? (this as LayoutParentData).layoutMargin?.vertical ?? 0
      : 0;

  double get layoutMarginLeft => (this is LayoutParentData)
      ? (this as LayoutParentData).layoutMargin?.left ?? 0
      : 0;

  double get layoutMarginTop => (this is LayoutParentData)
      ? (this as LayoutParentData).layoutMargin?.top ?? 0
      : 0;

  double get layoutMarginRight => (this is LayoutParentData)
      ? (this as LayoutParentData).layoutMargin?.right ?? 0
      : 0;

  double get layoutMarginBottom => (this is LayoutParentData)
      ? (this as LayoutParentData).layoutMargin?.bottom ?? 0
      : 0;

  /// 使用[layoutMargin]对布局进行偏移
  void layoutMarginOffset(AlignmentGeometry? alignment) {
    if (alignment == null) {
      return;
    }
    if (this is BoxParentData) {
      final parentData = this as BoxParentData;
      var dx = 0.0;
      var dy = 0.0;
      //x
      switch (alignment) {
        case AlignmentDirectional.topCenter:
        case AlignmentDirectional.center:
        case AlignmentDirectional.bottomCenter:
          dx = layoutMarginLeft - layoutMarginRight;
          break;
        case AlignmentDirectional.topStart:
        case AlignmentDirectional.centerStart:
        case AlignmentDirectional.bottomStart:
        case Alignment.topLeft:
        case Alignment.centerLeft:
        case Alignment.bottomLeft:
          dx = layoutMarginLeft;
          break;
        case AlignmentDirectional.topEnd:
        case AlignmentDirectional.centerEnd:
        case AlignmentDirectional.bottomEnd:
        case Alignment.topRight:
        case Alignment.centerRight:
        case Alignment.bottomRight:
          dx = -layoutMarginRight;
          break;
      }
      //y
      switch (alignment) {
        case AlignmentDirectional.centerStart:
        case AlignmentDirectional.center:
        case AlignmentDirectional.centerEnd:
          dy = layoutMarginTop - layoutMarginBottom;
          break;
        case AlignmentDirectional.topStart:
        case AlignmentDirectional.topCenter:
        case AlignmentDirectional.topEnd:
        case Alignment.topLeft:
        case Alignment.topCenter:
        case Alignment.topRight:
          dy = layoutMarginTop;
          break;
        case AlignmentDirectional.bottomStart:
        case AlignmentDirectional.bottomCenter:
        case AlignmentDirectional.bottomEnd:
        case Alignment.bottomLeft:
        case Alignment.bottomCenter:
        case Alignment.bottomRight:
          dy = -layoutMarginBottom;
          break;
      }
      parentData.offset += Offset(dx, dy);
    }
  }
}

/// 布局约束
/// [BoxConstraintsEx]
/// [alignChildOffset]
class LayoutBoxConstraints extends BoxConstraints {
  final ConstraintsType? widthType;
  final ConstraintsType? heightType;

  const LayoutBoxConstraints({
    this.widthType,
    this.heightType,
    //---
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
  });

  /// 固定大小约束
  const LayoutBoxConstraints.fixedSize({
    this.widthType = ConstraintsType.fixedSize,
    this.heightType = ConstraintsType.fixedSize,
    super.maxWidth,
    super.maxHeight,
  });

  @override
  BoxConstraints copyWith({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    ConstraintsType? widthType,
    ConstraintsType? heightType,
  }) {
    return LayoutBoxConstraints(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      widthType: widthType ?? this.widthType,
      heightType: heightType ?? this.heightType,
    );
  }

  /// 约束计算自身的大小
  /// [parentConstraints] parent给自身的约束
  /// [childSize] 子节点的大小
  /// [padding] 内边距, 在[wrapContentWidth].[wrapContentHeight]时有效
  ///
  /// [BoxConstraints.isSatisfiedBy] 是否是满意的约束, 满足约束
  ///
  Size constrainSize(
    BoxConstraints parentConstraints,
    Size childSize,
    EdgeInsets? padding,
  ) {
    //debugger();
    final paddingHorizontal = padding?.horizontal ?? 0;
    final paddingVertical = padding?.vertical ?? 0;

    final childWidth = childSize.width + paddingHorizontal;
    final childHeight = childSize.height + paddingVertical;

    double width = parentConstraints.constrainWidth(constrainWidth(childWidth));
    double height =
        parentConstraints.constrainHeight(constrainHeight(childHeight));

    if (widthType == ConstraintsType.wrapContent) {
      width = constrainWidth(childWidth);
    } else if (widthType == ConstraintsType.matchParent) {
      if (parentConstraints.maxWidth != double.infinity) {
        width = parentConstraints.maxWidth;
      } else if (maxWidth != double.infinity) {
        width = maxWidth;
      } else {
        assert(() {
          debugPrint(
              'matchParentWidth is true, but parentConstraints.maxWidth is double.infinity');
          return true;
        }());
      }
    }

    if (heightType == ConstraintsType.wrapContent) {
      height = constrainHeight(childHeight);
    } else if (heightType == ConstraintsType.matchParent) {
      if (parentConstraints.maxHeight != double.infinity) {
        height = parentConstraints.maxHeight;
      } else if (maxHeight != double.infinity) {
        height = maxHeight;
      } else {
        assert(() {
          debugPrint(
              'matchParentHeight is true, but parentConstraints.maxHeight is double.infinity');
          return true;
        }());
      }
    }

    if (parentConstraints.hasTightWidth) {
      //有一种满意的宽度约束尺寸
      width = parentConstraints.maxWidth;
    }
    if (parentConstraints.hasTightHeight) {
      //有一种满意的高度约束尺寸
      height = parentConstraints.maxHeight;
    }

    return Size(width, height);
  }
}

mixin LayoutMixin<ChildType extends RenderObject,
        ParentDataType extends ContainerParentDataMixin<ChildType>>
    on ContainerRenderObjectMixin<ChildType, ParentDataType> {
  //---

  /// 获取所有子节点的数量
  @protected
  int getChildCount() {
    int count = 0;
    ChildType? child = firstChild;
    while (child != null) {
      count += 1;
      final ParentDataType childParentData =
          child.parentData! as ParentDataType;
      child = childParentData.nextSibling;
    }
    return count;
  }

  /// 获取所有的子节点
  /// [RenderBoxContainerDefaultsMixin.getChildrenAsList]
  @protected
  List<ChildType> getChildren() {
    final List<ChildType> result = <ChildType>[];
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType childParentData =
          child.parentData! as ParentDataType;
      result.add(child);
      child = childParentData.nextSibling;
    }
    return result;
  }

  /// 枚举所有的子节点
  @protected
  void eachChild(void Function(ChildType child) action) {
    ChildType? child = firstChild;
    while (child != null) {
      final ParentDataType parentData = child.parentData as ParentDataType;
      action(child);
      child = parentData.nextSibling;
    }
  }

  /// 枚举所有的子节点, 并且返回索引
  /// [eachChild]
  @protected
  void eachChildIndex(void Function(ChildType child, int index) action) {
    ChildType? child = firstChild;
    int index = 0;
    while (child != null) {
      final ParentDataType parentData = child.parentData as ParentDataType;
      action(child, index);
      child = parentData.nextSibling;
      index++;
    }
  }

  //---
  /// 获取所有子节点的横向/纵向的间隙
  /// [LayoutParentData]
  double getAllChildMargin(List<ChildType> children, Axis axis) {
    double result = 0;
    for (final child in children) {
      if (axis == Axis.horizontal) {
        result += child.parentData?.layoutMarginHorizontal ?? 0;
      } else {
        result += child.parentData?.layoutMarginVertical ?? 0;
      }
    }
    return result;
  }

  /// 获取所有子节点的宽度, 包含间隙
  double getAllLinearChildWidth(
    List<ChildType> children, {
    double gap = 0,
  }) {
    double width = 0;
    for (final child in children) {
      if (child is RenderBox) {
        width += child.size.width;
      }
    }
    width += gap * (children.length - 1);
    return width;
  }

  /// 获取所有子节点的高度, 包含间隙
  double getAllLinearChildHeight(
    List<ChildType> children, {
    double gap = 0,
  }) {
    double height = 0;
    for (final child in children) {
      if (child is RenderBox) {
        height += child.size.height;
      }
    }
    height += gap * (children.length - 1);
    return height;
  }

  /// 使用wrap的方式, 测量子节点
  /// [childWidth] 指定子节点的宽度
  /// [childHeight] 指定子节点的高度
  (double childMaxWidth, double childMaxHeight) measureWrapChildren(
    List<ChildType> children, {
    double? childWidth,
    double? childHeight,
    BoxConstraints? parentConstraints,
  }) {
    double childMaxWidth = 0;
    double childMaxHeight = 0;
    for (final child in children) {
      child.layout(
        BoxConstraints(
          minWidth: childWidth ?? 0.0,
          maxWidth: childWidth ?? double.infinity,
          minHeight: childHeight ?? 0,
          maxHeight: childHeight ?? double.infinity,
        ),
        parentUsesSize: true,
      );
      //debugger();
      if (child is RenderBox) {
        Size childSize = child.size;

        if (childSize.width == double.infinity ||
            childSize.height == double.infinity) {
          //重新测量
          double maxWidth =
              childWidth ?? parentConstraints?.maxWidth ?? double.infinity;
          if (childSize.width == double.infinity) {
            maxWidth = screenWidth;
          }
          double maxHeight =
              childHeight ?? parentConstraints?.maxHeight ?? double.infinity;
          if (childSize.height == double.infinity) {
            maxHeight = screenHeight;
          }
          child.layout(
            BoxConstraints(
              minWidth: childWidth ?? 0.0,
              maxWidth: maxWidth,
              minHeight: childHeight ?? 0,
              maxHeight: maxHeight,
            ),
            parentUsesSize: true,
          );
          childSize = child.size;
          //debugger();
        }

        childMaxWidth = max(childMaxWidth, childSize.width);
        childMaxHeight = max(childMaxHeight, childSize.height);
      }
    }
    return (childMaxWidth, childMaxHeight);
  }

  /// 使用wrap的方式, 布局子节点
  /// [axis] 布局方向
  /// [offset] 起点偏移量, 不根据[axis]计算
  /// [axisOffset] 起点偏移量, 会根据[axis]自动取值
  /// [crossAxisAlignment] 交叉轴对齐方式, 在指定了[parentSize]后有效
  ///
  /// [parentSize] 父布局的大小, 此大小应该是包含了[parentPadding]的
  /// [parentPadding] 父布局的内边距
  /// [gap] 子节点之间的间隙
  ///
  /// [layoutStackChildren]
  void layoutLinearChildren(
    List<ChildType> children,
    Axis axis, {
    Offset offset = Offset.zero,
    Offset axisOffset = Offset.zero,
    CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.start,
    Size? parentSize,
    EdgeInsets? parentPadding,
    double gap = 0,
  }) {
    double parentPaddingLeft = parentPadding?.left ?? 0;
    double parentPaddingTop = parentPadding?.top ?? 0;
    double parentPaddingRight = parentPadding?.right ?? 0;
    double parentPaddingBottom = parentPadding?.bottom ?? 0;
    //有效的父布局大小
    double parentValidWidth =
        (parentSize?.width ?? 0) - parentPaddingLeft - parentPaddingRight;
    double parentValidHeight =
        (parentSize?.height ?? 0) - parentPaddingTop - parentPaddingBottom;

    double offsetX = offset.dx;
    double offsetY = offset.dy;
    if (axis == Axis.horizontal) {
      offsetX += axisOffset.dx + parentPaddingLeft;
    } else {
      offsetY += axisOffset.dy + parentPaddingTop;
    }

    //debugger();
    for (final child in children) {
      final parentData = child.parentData;
      double alignOffsetX = 0;
      double alignOffsetY = 0;
      if (parentData is BoxParentData) {
        if (parentSize != null && child is RenderBox) {
          if (axis == Axis.horizontal) {
            //水平布局, 上下的对齐方式
            if (crossAxisAlignment == CrossAxisAlignment.center) {
              alignOffsetY = parentPaddingTop +
                  (parentValidHeight - child.size.height) / 2;
            } else if (crossAxisAlignment == CrossAxisAlignment.end) {
              alignOffsetY =
                  parentValidHeight - child.size.height - parentPaddingBottom;
            }
          } else {
            //垂直布局, 左右的对齐方式
            if (crossAxisAlignment == CrossAxisAlignment.center) {
              alignOffsetX =
                  parentPaddingLeft + (parentValidWidth - child.size.width) / 2;
            } else if (crossAxisAlignment == CrossAxisAlignment.end) {
              alignOffsetX =
                  parentValidWidth - child.size.width - parentPaddingRight;
            }
          }
        }
        //offset
        final offset = Offset(
          offsetX + alignOffsetX + parentData.layoutMarginLeft,
          offsetY + alignOffsetY + parentData.layoutMarginTop,
        );
        parentData.offset = offset;
        //end
        if (child is RenderBox) {
          if (axis == Axis.horizontal) {
            offsetX = offset.dx +
                child.size.width +
                gap +
                parentData.layoutMarginRight;
          } else {
            offsetY = offset.dy +
                child.size.height +
                gap +
                parentData.layoutMarginBottom;
          }
        }
      }
    }
  }

  /// 绘制子节点
  void paintLayoutChildren(
    List<ChildType> children,
    PaintingContext context,
    ui.Offset offset, {
    Offset paintOffset = Offset.zero,
  }) {
    for (final child in children) {
      final parentData = child.parentData;
      if (parentData is BoxParentData) {
        context.paintChild(child, parentData.offset + offset + paintOffset);
      }
    }
  }

  /// [defaultHitTestChildren]
  bool hitLayoutChildren(
    List<ChildType> children,
    BoxHitTestResult result, {
    required Offset position,
    Offset paintOffset = Offset.zero,
  }) {
    //debugger();
    for (final child in children) {
      final parentData = child.parentData;
      if (child is RenderBox && parentData is BoxParentData) {
        final offset = parentData.offset + paintOffset;
        final bool isHit = result.addWithPaintOffset(
          offset: offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            //debugger();
            assert(transformed == position - offset);
            return (child as RenderBox).hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          //debugger();
          return true;
        }
      }
    }
    return false;
  }

  //---

  /// 使用stack的方式, 布局子节点
  /// [layoutLinearChildren]
  void layoutStackChildren(
    List<ChildType> children, {
    ChildType? anchorChild,
    Offset? anchorOffset,
  }) {
    if (anchorOffset == null) {
      if (anchorChild != null) {
        if (anchorChild is RenderBox) {
          final anchorParentData = anchorChild.parentData;
          if (anchorParentData is BoxParentData) {
            anchorOffset = anchorParentData.offset;
          }
        }
      }
    }
    //--
    if (anchorOffset != null) {
      for (final child in children) {
        final parentData = child.parentData;
        if (parentData is BoxParentData) {
          parentData.offset = anchorOffset;
        }
      }
    }
  }
}

/// 兼容[LayoutBoxConstraints].[ConstraintsType]
/// [alignChildOffset]
extension BoxConstraintsEx on BoxConstraints {
  /// 是否是包裹内容的约束
  bool get isWrapContentWidth => this is LayoutBoxConstraints
      ? (this as LayoutBoxConstraints).widthType == ConstraintsType.wrapContent
      : minWidth == 0 && maxWidth == double.infinity;

  bool get isWrapContentHeight => this is LayoutBoxConstraints
      ? (this as LayoutBoxConstraints).heightType == ConstraintsType.wrapContent
      : minHeight == 0 && maxHeight == double.infinity;

  /// 是否是撑满容器的约束
  bool get isMatchParentWidth => this is LayoutBoxConstraints
      ? (this as LayoutBoxConstraints).widthType == ConstraintsType.matchParent
      : minWidth.isNaN && maxWidth == double.infinity;

  bool get isMatchParentHeight => this is LayoutBoxConstraints
      ? (this as LayoutBoxConstraints).heightType == ConstraintsType.matchParent
      : minHeight.isNaN && maxHeight == double.infinity;

  /// 是否是固定大小的约束
  /// [hasTightWidth]
  bool get isFixedWidth => this is LayoutBoxConstraints
      ? (this as LayoutBoxConstraints).widthType == ConstraintsType.fixedSize
      : minWidth >= maxWidth;

  /// [hasTightHeight]
  bool get isFixedHeight => this is LayoutBoxConstraints
      ? (this as LayoutBoxConstraints).heightType == ConstraintsType.fixedSize
      : minHeight >= maxHeight;

  /// 是否无拘无束
  bool get isUnconstrained =>
      minWidth == 0 &&
      maxWidth == double.infinity &&
      minHeight == 0 &&
      maxHeight == double.infinity;

  /// 获取当前的约束
  /// [parentSize] 容器大小
  /// [padding] 自身需要填充的内边距
  /// [margin] 自身需要距离容器的外边距
  BoxConstraints constraintsWithParent(
    Size parentSize, {
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final marginHorizontal = margin?.horizontal ?? 0;
    final marginVertical = margin?.vertical ?? 0;

    final itemConstraints = this;
    double minWidth = parentSize.width - marginHorizontal;
    double maxWidth = minWidth;
    double minHeight = parentSize.height - marginVertical;
    double maxHeight = minHeight;

    final paddingHorizontal = padding?.horizontal ?? 0;
    final paddingVertical = padding?.vertical ?? 0;

    if (itemConstraints.isFixedWidth) {
      //指定了宽度
      minWidth = itemConstraints.maxWidth + paddingHorizontal;
      maxWidth = minWidth;
    } else if (itemConstraints.isWrapContentWidth) {
      //自适应宽度
      minWidth = itemConstraints.minWidth + paddingHorizontal;
    }

    if (itemConstraints.isFixedHeight) {
      //指定了高度
      minHeight = itemConstraints.maxHeight + paddingVertical;
      maxHeight = minHeight;
    } else if (itemConstraints.isWrapContentHeight) {
      //自适应高度
      minHeight = itemConstraints.minHeight + paddingVertical;
    }
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }
}

/// [BoxConstraintsEx.isWrapContentWidth]
/// [BoxConstraintsEx.isWrapContentHeight]
BoxConstraints wrapBoxConstraints({
  double minWidth = 0,
  double maxWidth = double.infinity,
  double minHeight = 0,
  double maxHeight = double.infinity,
}) {
  return BoxConstraints(
    minWidth: minWidth,
    maxWidth: maxWidth,
    minHeight: minHeight,
    maxHeight: maxHeight,
  );
}

/// [BoxConstraintsEx.isMatchParentWidth]
/// [BoxConstraintsEx.isMatchParentHeight]
BoxConstraints matchBoxConstraints({
  double minWidth = double.nan,
  double maxWidth = double.infinity,
  double minHeight = double.nan,
  double maxHeight = double.infinity,
}) {
  return BoxConstraints(
    minWidth: minWidth,
    maxWidth: maxWidth,
    minHeight: minHeight,
    maxHeight: maxHeight,
  );
}

/// [BoxConstraintsEx.isFixedWidth]
/// [BoxConstraintsEx.isFixedHeight]
BoxConstraints sizeBoxConstraints(double width, double height) {
  return BoxConstraints(
    minWidth: width,
    maxWidth: width,
    minHeight: height,
    maxHeight: height,
  );
}
