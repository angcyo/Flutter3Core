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

  /// [FlowLayoutRender.equalWidthRange]
  final String? equalWidthRange;

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
    this.equalWidthRange,
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
        equalWidthRange: equalWidthRange,
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
      ..equalWidthRange = equalWidthRange
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
  /// `boxWidth * weight`
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
  /// 等宽的[children]数量范围[x~xx], 满足条件才开启等宽
  /// [VersionMatcher]
  String? equalWidthRange;

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

  /// 是否等宽
  bool get isEqualWidth => getChildCount().matchVersion(equalWidthRange);

  FlowLayoutRender({
    this.padding,
    this.childHorizontalGap,
    this.childVerticalGap,
    this.childGap = 0,
    this.selfConstraints,
    this.childConstraints,
    this.equalWidthRange,
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
    //debugger();
    measureChild();
    layoutChild();

    final paddingHorizontal = (padding?.horizontal ?? 0);
    final paddingVertical = (padding?.vertical ?? 0);

    final childSize = Size(_childUsedWidth, _childUsedHeight);
    size = selfConstraints?.constrainSize(constraints, childSize, padding) ??
        constraints.constrain(
            childSize + UiOffset(paddingHorizontal, paddingVertical));
  }

  /// 最大的参考宽度, weight属性的参考值
  double get refMaxWidth {
    double maxWidth;
    if (selfConstraints?.maxWidth != null &&
        selfConstraints?.maxWidth != double.infinity) {
      maxWidth = selfConstraints!.maxWidth;
    } else if (constraints.maxWidth != double.infinity) {
      maxWidth = constraints.maxWidth;
    } else {
      final size = selfConstraints?.constrainSize(
          constraints, const UiSize(double.infinity, double.infinity), padding);
      maxWidth = size?.width ?? double.infinity;
      if (maxWidth == double.infinity) {
        assert(() {
          l.v('无法确定的maxWidth,[weight]属性失效,只能左对齐,并且无法根据宽度换行');
          return true;
        }());
      }
    }
    return maxWidth;
  }

  /// 最大的参考高度, 用来垂直对齐参考
  double get refMaxHeight {
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
          l.v('无法确定的maxHeight, 只能顶部对齐');
          return true;
        }());
      }
    }
    return maxHeight;
  }

  /// 1: 测量所有的child大小
  /// 需要支持[equalWidthRange]属性
  void measureChild() {
    final children = getChildren();
    //一行最大应该布局多少个child
    final lineMaxChildCount =
        min(this.lineMaxChildCount ?? children.length, children.length);

    //最大宽度, weight属性的参考值
    final maxWidth = refMaxWidth;

    final paddingHorizontal = (padding?.horizontal ?? 0);
    final horizontalGap = childHorizontalGap ?? childGap;

    for (var child in children) {
      final FlowLayoutParentData childParentData =
          child.parentData! as FlowLayoutParentData;
      var childConstraints = childParentData.constraints ??
          this.childConstraints ??
          defChildConstraints;

      //权重
      double? weight = childParentData.weight ??
          (isEqualWidth ? 1.0 / lineMaxChildCount : null);

      if (maxWidth != double.infinity && weight != null) {
        //需要使用权重约束
        final gap = horizontalGap *
            (lineMaxChildCount - 1 - childParentData.excludeGapCount);
        final boxValidWidth = maxWidth - paddingHorizontal - gap;
        final width = boxValidWidth * weight;
        childConstraints = BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: childConstraints.minHeight,
          maxHeight: childConstraints.maxHeight,
        );
      } else {
        //默认约束
      }
      ChildLayoutHelper.layoutChild(child, childConstraints);
    }
  }

  double _childUsedWidth = 0;
  double _childUsedHeight = 0;

  /// 2: 布局所有的child位置, 包裹stack的child
  /// 先将child规则, 按照一行一行的规则, 分组 / stack的child不参与分组
  /// 然后按照分组的规则, 依次布局child的位置
  void layoutChild() {
    final children = getChildren();
    //堆叠的child
    final stackChildren = <RenderBox>[];
    //存储每一行的child list
    final childrenLineList = <List<RenderBox>>[];
    // 一行中的child
    var lineChildList = <RenderBox>[];

    //一行最大应该布局多少个child
    final lineMaxChildCount =
        min(this.lineMaxChildCount ?? children.length, children.length);

    // 一行中剩余的宽度空间
    double lineRemainWidth = 0;
    int lineChildIndex = 0;

    final maxWidth = refMaxWidth;
    final paddingHorizontal = (padding?.horizontal ?? 0);
    final horizontalGap = childHorizontalGap ?? childGap;
    final verticalGap = childVerticalGap ?? childGap;

    void newLine() {
      if (lineChildList.isNotEmpty) {
        childrenLineList.add(lineChildList);
        lineChildList = [];
      }
      if (maxWidth == double.infinity) {
        lineRemainWidth = double.infinity;
      } else {
        lineRemainWidth = maxWidth - paddingHorizontal;
      }
      lineChildIndex = 0;
    }

    newLine(); //init

    //归类/分行分组
    for (var child in children) {
      final FlowLayoutParentData childParentData =
          child.parentData! as FlowLayoutParentData;
      if (childParentData.stack) {
        // 堆叠child, 不占用原有的布局空间
        stackChildren.add(child);
      } else {
        //需要排除的间隙
        final excludeGap = lineChildIndex > 0 ? horizontalGap : 0;
        lineChildIndex++;

        final childSize = child.size;
        //debugger();
        if (lineRemainWidth != double.infinity) {
          if (childSize.width > lineRemainWidth) {
            //换行
            newLine();
          }
          lineRemainWidth -= childSize.width + excludeGap;
        }
        lineChildList.add(child);

        if (lineChildList.length >= lineMaxChildCount) {
          newLine();
        }
      }
    }

    newLine(); //最后一行

    //开始布局
    double maxHeight = refMaxHeight;
    _childUsedWidth = 0;
    _childUsedHeight = getAllLineHeight(childrenLineList);

    final paddingTop = padding?.top ?? 0;
    final paddingBottom = padding?.bottom ?? 0;
    final paddingLeft = padding?.left ?? 0;
    final paddingRight = padding?.right ?? 0;
    double top = paddingTop;
    if (maxHeight != double.infinity) {
      //获取child总行的高度

      if (mainAxisAlignment == MainAxisAlignment.center) {
        top = (maxHeight - _childUsedHeight) / 2 + paddingTop - paddingBottom;
      } else if (mainAxisAlignment == MainAxisAlignment.end) {
        top = maxHeight - _childUsedHeight - paddingBottom;
      }
    }
    double left = paddingLeft;
    childrenLineList.forEachIndexed((index, lineChildList) {
      //debugger();
      double lineMaxWidth = getLineUsedWidth(lineChildList);
      double lineMaxHeight = getLineUsedHeight(lineChildList);
      double lineUsedHeight = 0;
      double lineLeft = left;

      if (maxWidth != double.infinity) {
        if (crossAxisAlignment == CrossAxisAlignment.center) {
          lineLeft = (maxWidth - lineMaxWidth) / 2 + paddingLeft - paddingRight;
        } else if (crossAxisAlignment == CrossAxisAlignment.end) {
          lineLeft = maxWidth - lineMaxWidth - paddingRight;
        }
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
      _childUsedWidth = max(_childUsedWidth, lineMaxWidth);
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
    String? equalWidthRange,
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
      equalWidthRange: equalWidthRange,
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
