part of '../../../flutter3_widgets.dart';

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

  /// [FlowLayoutRender.lineChildCount]
  final int? lineChildCount;

  /// [FlowLayoutRender.mainAxisAlignment]
  final MainAxisAlignment mainAxisAlignment;

  /// [FlowLayoutRender.lineMainAxisAlignment]
  final MainAxisAlignment lineMainAxisAlignment;

  /// [FlowLayoutRender.crossAxisAlignment]
  final CrossAxisAlignment crossAxisAlignment;

  /// [FlowLayoutRender.matchLineHeight]
  final bool? matchLineHeight;

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
    this.lineChildCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.lineMainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.matchLineHeight,
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
        lineChildCount: lineChildCount,
        mainAxisAlignment: mainAxisAlignment,
        lineMainAxisAlignment: lineMainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        matchLineHeight: matchLineHeight,
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
      ..lineChildCount = lineChildCount
      ..mainAxisAlignment = mainAxisAlignment
      ..lineMainAxisAlignment = lineMainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..matchLineHeight = matchLineHeight
      ..markNeedsLayout();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsets>('padding', padding))
      ..add(StringProperty('equalWidthRange', equalWidthRange))
      ..add(IntProperty('lineMaxChildCount', lineMaxChildCount))
      ..add(IntProperty('lineChildCount', lineChildCount))
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

  /// 是否撑满当前的行高
  bool? matchLineHeight;

  //---

  /// 是否堆叠在一起, 如果开启堆叠, 那么当前的child, 不会占据原有的布局空间
  /// 堆叠元素的起始坐标, 默认就是在当前位置
  bool stack;

  /// 在计算等宽时, 是否排除[weight]计算, 并且自身也不使用[weight]进行约束
  bool excludeWeight;

  FlowLayoutParentData({
    this.constraints,
    this.weight,
    this.excludeGapCount = 0,
    this.stack = false,
    this.excludeWeight = false,
    this.matchLineHeight,
  });

  @override
  String toString() {
    return 'weight:$weight excludeGapCount:$excludeGapCount stack:$stack matchLineHeight:$matchLineHeight '
        'offset=$offset constraints:$constraints excludeWeight:$excludeWeight';
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

  /// [FlowLayoutParentData.excludeWeight]
  final bool excludeWeight;

  /// [FlowLayoutParentData.matchLineHeight]
  final bool? matchLineHeight;

  const FlowLayoutData({
    super.key,
    required super.child,
    this.weight,
    this.constraints,
    this.stack = false,
    this.excludeWeight = false,
    this.matchLineHeight,
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

    if (parentData.excludeWeight != excludeWeight) {
      parentData.excludeWeight = excludeWeight;
      needsLayout = true;
    }

    if (parentData.matchLineHeight != matchLineHeight) {
      parentData.matchLineHeight = matchLineHeight;
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

  double get paddingHorizontal => (padding?.horizontal ?? 0);

  double get paddingVertical => (padding?.vertical ?? 0);

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

  /// 当等宽时, 一行指定有多少个子元素, 不指定则使用真实的child数量
  int? lineChildCount;

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

  /// 所有行, 是否都要撑满行高?
  /// 单独控制请使用
  /// [FlowLayoutParentData.matchLineHeight]
  bool? matchLineHeight;

  FlowLayoutRender({
    this.padding,
    this.childHorizontalGap,
    this.childVerticalGap,
    this.childGap = 0,
    this.selfConstraints,
    this.childConstraints,
    this.equalWidthRange,
    this.lineMaxChildCount,
    this.lineChildCount,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.lineMainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.matchLineHeight,
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

    final childSize = Size(_childUsedWidth, _childUsedHeight);
    size = selfConstraints?.constrainSize(constraints, childSize, padding) ??
        constraints.constrain(
            childSize + UiOffset(paddingHorizontal, paddingVertical));
  }

  /// 最大的参考宽度, weight属性的参考值
  double get refMaxWidth {
    //debugger();
    double maxWidth;
    final constraints = this.constraints;
    if (constraints.hasTightWidth) {
      maxWidth = constraints.maxWidth;
    } else if (selfConstraints?.maxWidth != null &&
        selfConstraints?.maxWidth != double.infinity) {
      maxWidth = selfConstraints!.maxWidth;
    } else if (constraints.maxWidth != double.infinity) {
      if (selfConstraints == null ||
          selfConstraints?.widthType != null ||
          _childUsedWidth <= 0) {
        maxWidth = constraints.maxWidth;
      } else {
        maxWidth = _childUsedWidth + paddingHorizontal;
      }
    } else if (_childUsedWidth > 0) {
      maxWidth = _childUsedWidth + paddingHorizontal;
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
    //debugger();
    double maxHeight;
    final constraints = this.constraints;
    if (constraints.hasTightWidth) {
      maxHeight = constraints.maxHeight;
    } else if (selfConstraints?.maxHeight != null &&
        selfConstraints?.maxHeight != double.infinity) {
      maxHeight = selfConstraints!.maxHeight;
    } else if (constraints.maxHeight != double.infinity) {
      if (selfConstraints == null ||
          selfConstraints?.heightType != null ||
          _childUsedHeight <= 0) {
        maxHeight = constraints.maxHeight;
      } else {
        maxHeight = _childUsedHeight + paddingVertical;
      }
    } else if (_childUsedHeight > 0) {
      maxHeight = _childUsedHeight + paddingVertical;
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
    //参与weight的child
    final weightChildren = <RenderBox>[];
    //不参与weight的child
    final noWeightChildren = <RenderBox>[];

    for (final child in children) {
      final childParentData = child.parentData! as FlowLayoutParentData;
      if (childParentData.excludeWeight) {
        noWeightChildren.add(child);
      } else {
        weightChildren.add(child);
      }
    }

    final paddingHorizontal = (padding?.horizontal ?? 0);
    final horizontalGap = childHorizontalGap ?? childGap;

    //先测量[noWeightChildren]
    double noWeightWidth = horizontalGap *
        (noWeightChildren.size() - (weightChildren.isEmpty ? 1 : 0)).maxOf(0);
    for (final child in noWeightChildren) {
      final childParentData = child.parentData! as FlowLayoutParentData;
      final childConstraints = childParentData.constraints ??
          this.childConstraints ??
          defChildConstraints;
      ChildLayoutHelper.layoutChild(child, childConstraints);
      noWeightWidth += child.size.width;
    }

    //再测量[weightChildren]
    final childCount = (lineChildCount ?? weightChildren.length);

    //一行最大应该布局多少个child
    final weightChildCount = min(lineMaxChildCount ?? childCount, childCount);

    //最大宽度, weight属性的参考值
    final maxWidth = refMaxWidth;

    for (final child in weightChildren) {
      final childParentData = child.parentData! as FlowLayoutParentData;
      var childConstraints = childParentData.constraints ??
          this.childConstraints ??
          defChildConstraints;

      //权重
      double? weight = childParentData.weight ??
          (isEqualWidth ? 1.0 / weightChildCount : null);

      if (maxWidth != double.infinity && weight != null) {
        //需要使用权重约束
        final gap = horizontalGap *
            (weightChildCount - 1 - childParentData.excludeGapCount);
        final boxValidWidth =
            maxWidth - paddingHorizontal - gap - 0.5 - noWeightWidth; //防止浮点误差
        final width = boxValidWidth * weight;
        assert(() {
          if (width < 0) {
            debugger();
          }
          return true;
        }());
        childConstraints = BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: childConstraints.minHeight,
          maxHeight: childConstraints.maxHeight,
        );
      } else {
        //默认约束
      }
      //debugger();
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
    for (final child in children) {
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
          if ((childSize.width + excludeGap) > lineRemainWidth) {
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

    //matchLineHeight 功能适配
    childrenLineList.forEachIndexed((index, lineChildList) {
      final lineHeight = getLineUsedHeight(lineChildList);
      for (final child in lineChildList) {
        final childParentData = child.parentData! as FlowLayoutParentData;
        final childMatchLineHeight =
            childParentData.matchLineHeight ?? matchLineHeight;
        if (childMatchLineHeight == true) {
          final childSize = child.size;
          final childHeight = childSize.height;
          if (childHeight != lineHeight) {
            //高度不一致, 重新测量
            final childConstraints = BoxConstraints(
              minWidth: childSize.width,
              maxWidth: childSize.width,
              minHeight: lineHeight,
              maxHeight: lineHeight,
            );
            ChildLayoutHelper.layoutChild(child, childConstraints);
          }
        }
      }
    });

    //开始布局
    var childUsedWidth = 0.0;
    final childUsedHeight = getAllLineHeight(childrenLineList);
    _childUsedHeight = childUsedHeight;

    double maxHeight = refMaxHeight;

    final paddingTop = padding?.top ?? 0;
    final paddingBottom = padding?.bottom ?? 0;
    final paddingLeft = padding?.left ?? 0;
    final paddingRight = padding?.right ?? 0;
    double top = paddingTop;

    if (maxHeight != double.infinity) {
      //获取child总行的高度
      if (mainAxisAlignment == MainAxisAlignment.center) {
        top = (maxHeight - childUsedHeight) / 2 + paddingTop - paddingBottom;
      } else if (mainAxisAlignment == MainAxisAlignment.end) {
        top = maxHeight - childUsedHeight - paddingBottom;
      }
    }
    double left = paddingLeft;
    //遍历一行一行
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

      //遍历一行中的所有child
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
    _childUsedWidth = childUsedWidth;

    // 堆叠的child在此布局
    for (final stackChild in stackChildren) {
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
          Paint()..color = Colors.purpleAccent);
      return true;
    }());*/
    //debugDrawBoxBounds(context, offset);
    defaultPaint(context, offset);
  }
}

extension FlowLayoutListEx on WidgetNullList {
  /// [selfConstraints] 自身的约束条件, 不指定则使用父约束条件
  /// [childGap] 子元素之间的间隙, 如果[childHorizontalGap]和[childVerticalGap]都不指定, 则使用[childGap]
  /// [FlowLayout]
  /// [FlowLayoutEx.flowLayoutData]
  Widget? flowLayout({
    LayoutBoxConstraints? selfConstraints,
    ConstraintsType? selfWidthType,
    ConstraintsType? selfHeightType,
    EdgeInsets? padding,
    double childGap = 0,
    double? childHorizontalGap,
    double? childVerticalGap,
    BoxConstraints? childConstraints,
    String? equalWidthRange,
    int? lineMaxChildCount,
    int? lineChildCount,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    MainAxisAlignment lineMainAxisAlignment = MainAxisAlignment.center,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool? matchLineHeight,
  }) {
    WidgetList list = filterNull();
    if (isNil(list)) {
      return null;
    }
    if (selfConstraints == null) {
      if (selfWidthType != null || selfHeightType != null) {
        selfConstraints = LayoutBoxConstraints(
          widthType: selfWidthType,
          heightType: selfHeightType,
        );
      }
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
      lineChildCount: lineChildCount,
      mainAxisAlignment: mainAxisAlignment,
      lineMainAxisAlignment: lineMainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      matchLineHeight: matchLineHeight,
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
    bool excludeWeight = false,
    bool stack = false,
    bool? matchLineHeight,
  }) =>
      FlowLayoutData(
        constraints: constraints,
        weight: weight,
        excludeGapCount: excludeGapCount,
        stack: stack,
        excludeWeight: excludeWeight,
        matchLineHeight: matchLineHeight,
        child: this,
      );
}
