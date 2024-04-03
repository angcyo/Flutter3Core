part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///
/// 流式布局
/// [Flex]
class FlowLayout extends MultiChildRenderObjectWidget {
  /// [FlowLayoutRender.padding]
  final EdgeInsets? padding;

  /// [FlowLayoutRender.childGap]
  final double childGap;

  /// [FlowLayoutRender.childHorizontalGap]
  final double? childHorizontalGap;

  /// [FlowLayoutRender.childVerticalGap]
  final double? childVerticalGap;

  /// [FlowLayoutRender.selfConstraints]
  final LayoutBoxConstraints? selfConstraints;

  /// [FlowLayoutRender.childConstraints]
  final BoxConstraints? childConstraints;

  /// [FlowLayoutRender.enableEqualWidth]
  final bool enableEqualWidth;

  /// [FlowLayoutRender.lineMaxChildCount]
  final int? lineMaxChildCount;

  /// [FlowLayoutRender.mainAxisAlignment]
  final MainAxisAlignment mainAxisAlignment;

  /// [FlowLayoutRender.lineMainAxisAlignment]
  final MainAxisAlignment lineMainAxisAlignment;

  /// [FlowLayoutRender.crossAxisAlignment]
  final CrossAxisAlignment crossAxisAlignment;

  const FlowLayout({
    super.key,
    super.children,
    this.padding,
    this.childGap = 0,
    this.childHorizontalGap,
    this.childVerticalGap,
    this.selfConstraints,
    this.childConstraints,
    this.enableEqualWidth = false,
    this.lineMaxChildCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.lineMainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  FlowLayoutRender createRenderObject(BuildContext context) => FlowLayoutRender(
        padding: padding,
        childGap: childGap,
        childHorizontalGap: childHorizontalGap,
        childVerticalGap: childVerticalGap,
        selfConstraints: selfConstraints,
        childConstraints: childConstraints,
        enableEqualWidth: enableEqualWidth,
        lineMaxChildCount: lineMaxChildCount,
        mainAxisAlignment: mainAxisAlignment,
        lineMainAxisAlignment: lineMainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
      );

  @override
  void updateRenderObject(BuildContext context, FlowLayoutRender renderObject) {
    renderObject
      ..padding = padding
      ..childGap = childGap
      ..childHorizontalGap = childHorizontalGap
      ..childVerticalGap = childVerticalGap
      ..selfConstraints = selfConstraints
      ..childConstraints = childConstraints
      ..enableEqualWidth = enableEqualWidth
      ..lineMaxChildCount = lineMaxChildCount
      ..mainAxisAlignment = mainAxisAlignment
      ..lineMainAxisAlignment = lineMainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..markNeedsLayout();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsets>('padding', padding))
      ..add(DoubleProperty('childGap', childGap))
      ..add(DoubleProperty('childHorizontalGap', childHorizontalGap))
      ..add(DoubleProperty('childVerticalGap', childVerticalGap))
      ..add(DiagnosticsProperty<LayoutBoxConstraints>(
          'selfConstraints', selfConstraints))
      ..add(DiagnosticsProperty<BoxConstraints>(
          'childConstraints', childConstraints));
  }
}

/// 布局数据
/// [FlexParentData]
class FlowLayoutParentData extends ContainerBoxParentData<RenderBox> {
  /// 单独设置子元素的约束条件, 设置此属性后, [weight]属性将失效
  BoxConstraints? constraints;

  /// 宽度占用权重
  double? weight;

  /// 当前这一行在计算[weight]时, 需要排除多个[child]的gap
  int excludeGapCount;

  //---

  /// 是否堆叠在一起, 如果开启堆叠, 那么当前的child, 不会占据原有的布局空间
  /// 堆叠元素的起始坐标, 默认就是在当前位置
  bool stack;

  FlowLayoutParentData({
    this.constraints,
    this.weight,
    this.excludeGapCount = 0,
    this.stack = false,
  });

  @override
  String toString() {
    return 'offset=$offset constraints:$constraints';
  }
}

/// 提供布局数据的小部件
/// [Flexible]
/// [FlowLayoutParentData]
class FlowLayoutData extends ParentDataWidget<FlowLayoutParentData> {
  /// [FlowLayoutParentData.constraints]
  final BoxConstraints? constraints;

  /// [FlowLayoutParentData.weight]
  final double? weight;

  /// [FlowLayoutParentData.excludeGapCount]
  final int excludeGapCount;

  /// [FlowLayoutParentData.stack]
  final bool stack;

  const FlowLayoutData({
    super.key,
    required super.child,
    this.weight,
    this.constraints,
    this.stack = false,
    this.excludeGapCount = 0,
  });

  /// [RenderObjectElement.attachRenderObject]
  /// [RenderObjectElement._updateParentData]
  @override
  void applyParentData(RenderObject renderObject) {
    //debugger();
    assert(renderObject.parentData is FlowLayoutParentData);
    final FlowLayoutParentData parentData =
        renderObject.parentData! as FlowLayoutParentData;

    bool needsLayout = false;

    if (parentData.constraints != constraints) {
      parentData.constraints = constraints;
      needsLayout = true;
    }

    if (parentData.weight != weight) {
      parentData.weight = weight;
      needsLayout = true;
    }

    if (parentData.excludeGapCount != excludeGapCount) {
      parentData.excludeGapCount = excludeGapCount;
      needsLayout = true;
    }

    if (parentData.stack != stack) {
      parentData.stack = stack;
      needsLayout = true;
    }

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
  /// 自身的内间隙
  EdgeInsets? padding;

  /// 子元素之间的间隙, 如果[childHorizontalGap]和[childVerticalGap]都不指定, 则使用[childGap]
  /// [childHorizontalGap]
  /// [childVerticalGap]
  double childGap;

  /// 子元素之间的水平间隙
  double? childHorizontalGap;

  /// 子元素之间的垂直间隙
  double? childVerticalGap;

  /// 自身的约束条件, 不指定则使用父约束条件
  LayoutBoxConstraints? selfConstraints;

  /// 所有子元素的约束条件, 不指定则使用默认的[BoxConstraints]约束
  /// 可以通过[FlowLayoutParentData]单独指定子元素自身的约束条件
  BoxConstraints? childConstraints;

  /// 默认的子元素约束条件
  final BoxConstraints defChildConstraints = const BoxConstraints();

  /// 是否激活元素等宽, 间接设置[FlowLayoutParentData.weight]
  bool enableEqualWidth;

  /// 每行最多的子元素数量, 用来配合[enableEqualWidth]计算[FlowLayoutParentData.weight]
  int? lineMaxChildCount;

  /// 主轴对齐方式, 也就是上/下对齐方式
  /// [MainAxisAlignment.start] 对齐容器的顶部
  /// [MainAxisAlignment.end] 对齐容器的底部
  /// [MainAxisAlignment.center] 对齐容器的中心
  MainAxisAlignment mainAxisAlignment;

  /// 在一行中, child的主轴对齐方式
  MainAxisAlignment lineMainAxisAlignment;

  /// 交叉轴对齐方式, 也就是左/右对齐方式
  /// [CrossAxisAlignment.start] 对齐容器的左边
  /// [CrossAxisAlignment.end] 对齐容器的右边
  /// [CrossAxisAlignment.center] 对齐容器的中心
  CrossAxisAlignment crossAxisAlignment;

  FlowLayoutRender({
    this.padding,
    this.childHorizontalGap,
    this.childVerticalGap,
    this.childGap = 0,
    this.selfConstraints,
    this.childConstraints,
    this.enableEqualWidth = false,
    this.lineMaxChildCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.lineMainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

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
    final BoxConstraints constraints = this.constraints;
    final paddingHorizontal = (padding?.horizontal ?? 0);
    final paddingVertical = (padding?.vertical ?? 0);
    final paddingTop = padding?.top ?? 0;
    final paddingBottom = padding?.bottom ?? 0;
    final paddingLeft = padding?.left ?? 0;
    final paddingRight = padding?.right ?? 0;

    final horizontalGap = childHorizontalGap ?? childGap;
    final verticalGap = childVerticalGap ?? childGap;

    //debugger();

    double maxWidth;
    if (selfConstraints?.maxWidth != null &&
        selfConstraints?.maxWidth != double.infinity) {
      maxWidth = selfConstraints!.maxWidth;
    } else if (constraints.maxWidth != double.infinity) {
      maxWidth = constraints.maxWidth;
    } else {
      final size = selfConstraints?.constrainSize(constraints,
          const ui.Size(double.infinity, double.infinity), padding);
      maxWidth = size?.width ?? double.infinity;
      if (maxWidth == double.infinity) {
        assert(() {
          l.d('无法确定的maxWidth');
          return true;
        }());
      }
    }

    //debugger();
    double maxHeight;
    if (selfConstraints?.maxHeight != null &&
        selfConstraints?.maxHeight != double.infinity) {
      maxHeight = selfConstraints!.maxHeight;
    } else if (constraints.maxHeight != double.infinity) {
      maxHeight = constraints.maxHeight;
    } else {
      final size = selfConstraints?.constrainSize(constraints,
          const ui.Size(double.infinity, double.infinity), padding);
      maxHeight = size?.height ?? double.infinity;
      if (maxHeight == double.infinity) {
        assert(() {
          l.d('无法确定的maxHeight');
          return true;
        }());
      }
    }

    //所有子元素
    final allChildren = getChildren();
    //堆叠的资源
    final stackChildren = <RenderBox>[];
    //存储每一行的child list
    final childrenLineList = <List<RenderBox>>[];

    // 一行中的child
    var lineChildList = <RenderBox>[];

    //一行最大应该布局多少个child
    final lineMaxChildCount_ =
        min(lineMaxChildCount ?? allChildren.length, allChildren.length);

    // 一行中剩余的宽度空间
    double lineRemainWidth = 0;
    int lineChildIndex = 0;

    void newLine() {
      if (lineChildList.isNotEmpty) {
        childrenLineList.add(lineChildList);
        lineChildList = [];
      }
      lineRemainWidth = maxWidth - paddingHorizontal;
      lineChildIndex = 0;
    }

    newLine(); //init

    //开始测量child大小
    allChildren.forEachIndexed((index, child) {
      //debugger();
      final FlowLayoutParentData childParentData =
          child.parentData! as FlowLayoutParentData;

      double? weight = childParentData.weight;
      if (enableEqualWidth && childParentData.constraints == null) {
        weight ??= 1.0 / lineMaxChildCount_;
      }

      BoxConstraints childConstraints = childParentData.constraints ??
          this.childConstraints ??
          defChildConstraints;

      /*if (childParentData.stack) {
        debugger();
      }*/

      if (weight != null) {
        //需要使用权重约束
        //debugger();
        final gap = (childHorizontalGap ?? childGap) *
            (lineMaxChildCount_ - 1 - childParentData.excludeGapCount);
        final boxValidWidth = maxWidth - paddingHorizontal - gap;
        final width = boxValidWidth * weight;
        childConstraints = BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: childConstraints.minHeight,
          maxHeight: childConstraints.maxHeight,
        );
      }

      //debugger();

      //child 大小
      final childSize = ChildLayoutHelper.layoutChild(child, childConstraints);

      if (childParentData.stack) {
        // 堆叠child, 不占用原有的布局空间
        stackChildren.add(child);
      } else {
        //需要排除的间隙
        final excludeGap = lineChildIndex > 0 ? horizontalGap : 0;
        lineChildIndex++;

        //debugger();
        if (childSize.width > lineRemainWidth) {
          //换行
          newLine();
        }
        lineChildList.add(child);
        lineRemainWidth -= childSize.width + excludeGap;

        if (lineChildList.length >= lineMaxChildCount_) {
          newLine();
        }
      }
    });
    newLine();
    //debugger();

    //开始布局
    double childUsedWidth = 0;
    double childUsedHeight = getAllLineHeight(childrenLineList);

    //debugger();
    Size childSize = Size(childUsedWidth, childUsedHeight);
    size = selfConstraints?.constrainSize(constraints, childSize, padding) ??
        constraints.constrain(childSize);

    //this
    maxWidth = size.width;
    maxHeight = size.height;

    //debugger();
    double top = paddingTop;
    if (mainAxisAlignment == MainAxisAlignment.center) {
      top = (maxHeight - childUsedHeight) / 2 + paddingTop - paddingBottom;
    } else if (mainAxisAlignment == MainAxisAlignment.end) {
      top = maxHeight - childUsedHeight - paddingBottom;
    }
    double left = paddingLeft;

    childrenLineList.forEachIndexed((index, lineChildList) {
      //debugger();
      double lineMaxWidth = getLineUsedWidth(lineChildList);
      double lineMaxHeight = getLineUsedHeight(lineChildList);
      double lineUsedHeight = 0;
      double lineLeft = left;
      if (crossAxisAlignment == CrossAxisAlignment.center) {
        lineLeft = (maxWidth - lineMaxWidth) / 2 + paddingLeft - paddingRight;
      } else if (crossAxisAlignment == CrossAxisAlignment.end) {
        lineLeft = maxWidth - lineMaxWidth - paddingRight;
      }

      lineChildList.forEachIndexed((index, child) {
        final FlowLayoutParentData childParentData =
            child.parentData! as FlowLayoutParentData;

        double lineTop = top;
        if (lineMainAxisAlignment == MainAxisAlignment.center) {
          lineTop = top + (lineMaxHeight - child.size.height) / 2;
        } else if (lineMainAxisAlignment == MainAxisAlignment.end) {
          lineTop = top + lineMaxHeight - child.size.height;
        }

        //child 位置
        childParentData.offset = Offset(lineLeft, lineTop);

        final childSize = child.size;
        lineLeft += childSize.width + horizontalGap;
        lineUsedHeight = max(lineUsedHeight, childSize.height);
      });

      top += lineUsedHeight + verticalGap;
      childUsedWidth = max(childUsedWidth, lineMaxWidth);
    });

    // 堆叠的child在此布局
    for (var stackChild in stackChildren) {
      //child 位置
      final stackChildParentData =
          stackChild.parentData! as FlowLayoutParentData;

      final anchor = childAfter(stackChild) ?? childBefore(stackChild);
      if (anchor != null) {
        final anchorParentData = anchor.parentData! as FlowLayoutParentData;
        stackChildParentData.offset = anchorParentData.offset;
      } else {
        //没有锚点, 则使用默认的位置
        final lineTop = top;
        final lineLeft = left;
        stackChildParentData.offset = Offset(lineLeft, lineTop);
      }
    }

    //debugger();
  }

  /// 计算所有行的高度, 不包含[padding], 但是包含[childVerticalGap]
  double getAllLineHeight(List<List<RenderBox>> childrenLineList) {
    double allLineHeight = 0;
    childrenLineList.forEachIndexed((index, lineChildList) {
      if (index > 0) {
        allLineHeight += childVerticalGap ?? childGap;
      }
      allLineHeight += getLineUsedHeight(lineChildList);
    });
    return allLineHeight;
  }

  /// 计算一行中的总宽度, 不包含[padding], 但是包含[childHorizontalGap]
  double getLineUsedWidth(List<RenderBox> lineChildList) {
    double lineUsedWidth = 0;
    lineChildList.forEachIndexed((index, child) {
      if (index > 0) {
        lineUsedWidth += childHorizontalGap ?? childGap;
      }
      final childSize = child.size;
      lineUsedWidth += childSize.width;
    });
    return lineUsedWidth;
  }

  double getLineUsedHeight(List<RenderBox> lineChildList) {
    double lineUsedHeight = 0;
    lineChildList.forEachIndexed((index, child) {
      final childSize = child.size;
      lineUsedHeight = max(lineUsedHeight, childSize.height);
    });
    return lineUsedHeight;
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (size.isEmpty) {
      return;
    }
    /*assert(() {
      context.canvas.drawRect(
          ui.Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
          Paint()..color = Colors.white30);
      return true;
    }());*/
    defaultPaint(context, offset);
  }
}

extension FlowLayoutListEx on WidgetNullList {
  /// [selfConstraints] 自身的约束条件, 不指定则使用父约束条件
  /// [FlowLayout]
  /// [FlowLayoutEx.flowLayoutData]
  Widget? flowLayout({
    LayoutBoxConstraints? selfConstraints,
    EdgeInsets? padding,
    double childGap = 0,
    double? childHorizontalGap,
    double? childVerticalGap,
    BoxConstraints? childConstraints,
    bool enableEqualWidth = false,
    int? lineMaxChildCount,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    MainAxisAlignment lineMainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    WidgetList list = filterNull();
    if (isNil(list)) {
      return null;
    }
    return FlowLayout(
      padding: padding,
      childGap: childGap,
      childHorizontalGap: childHorizontalGap,
      childVerticalGap: childVerticalGap,
      selfConstraints: selfConstraints,
      childConstraints: childConstraints,
      enableEqualWidth: enableEqualWidth,
      lineMaxChildCount: lineMaxChildCount,
      mainAxisAlignment: mainAxisAlignment,
      lineMainAxisAlignment: lineMainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: list,
    );
  }
}

extension FlowLayoutEx on Widget {
  /// [FlowLayoutData]
  Widget flowLayoutData({
    BoxConstraints? constraints,
    double? weight,
    int excludeGapCount = 0,
    bool stack = false,
  }) =>
      FlowLayoutData(
        constraints: constraints,
        weight: weight,
        excludeGapCount: excludeGapCount,
        stack: stack,
        child: this,
      );
}
