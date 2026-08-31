part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/25
///
/// 系统的[Row]如果最后一个小部件是[Text]时, 如果不使用[Expanded]包裹, [Text]是无法换行的
/// 这个小部件支持, 支持最后一个[Widget]的宽度超过剩余空间时, 自动使用最大的剩余空间重新测量
///
class LastExtendRow extends Row {
  /// 第一个元素超过总宽度时, 是否撑满宽度重新计算
  final bool? firstExtend;

  /// 需要排除的宽度
  final double? firstExcludeWidth;

  /// 最后一个元素超过总宽度时, 是否撑满宽度重新计算
  final bool? lastExtend;

  /// 调试标签
  final String? debugLabel;

  const LastExtendRow({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline, // NO DEFAULT: we don't know what the text's baseline should be
    super.spacing,
    super.children,
    this.lastExtend,
    this.firstExtend,
    this.firstExcludeWidth,
    this.debugLabel,
  });

  @override
  LastExtendRenderFlex createRenderObject(BuildContext context) {
    return LastExtendRenderFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      spacing: spacing,
      lastExtend: lastExtend,
      firstExtend: firstExtend,
      firstExcludeWidth: firstExcludeWidth,
      debugLabel: debugLabel,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant LastExtendRenderFlex renderObject,
  ) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = getEffectiveTextDirection(context)
      ..verticalDirection = verticalDirection
      ..textBaseline = textBaseline
      ..spacing = spacing
      ..clipBehavior = clipBehavior
      ..lastExtend = lastExtend
      ..firstExtend = firstExtend
      ..firstExcludeWidth = firstExcludeWidth
      ..debugLabel = debugLabel;
  }
}

class LastExtendRenderFlex extends RenderFlex {
  /// 第一个元素超过总宽度时, 是否撑满宽度重新计算
  bool? firstExtend;

  /// 最后一个元素超过总宽度时, 是否撑满宽度重新计算
  bool? lastExtend;

  /// 需要排除的宽度
  double? firstExcludeWidth;

  /// 调试标签
  String? debugLabel;

  LastExtendRenderFlex({
    super.children,
    super.direction = .horizontal,
    super.mainAxisSize = .max,
    super.mainAxisAlignment = .start,
    super.crossAxisAlignment = .center,
    super.textDirection,
    super.verticalDirection = .down,
    super.textBaseline,
    super.clipBehavior = .none,
    super.spacing = 0,
    this.lastExtend,
    this.firstExtend,
    this.firstExcludeWidth,
    this.debugLabel,
  });

  /// 是否溢出了
  @tempFlag
  bool _isOverflow = false;

  /// [ChildLayoutHelper.dryLayoutChild]
  /// [ChildLayoutHelper.getDryBaseline]
  ///
  /// [ChildLayoutHelper.layoutChild]
  /// [ChildLayoutHelper.getBaseline]
  @override
  void performLayout() {
    super.performLayout();

    _isOverflow = false;

    final constraints = this.constraints;
    final children = childrenList;

    double childUseWidth = 0;
    double childMaxHeight = 0;

    //是否重新测量过child
    bool isReLayoutChild = false;

    debugger(when: debugLabel != null);
    for (final child in children) {
      final childWidth = child.size.width;
      final childHeight = child.size.height;
      childMaxHeight = math.max(childMaxHeight, childHeight);
      //debugger();
      final isFirst = firstExtend == true && child == children.first;
      final isLast = lastExtend == true && child == children.last;
      if (isFirst || isLast) {
        //第一个或最后一个child
        final maxWidth = constraints.maxWidth - childUseWidth;
        //debugger();
        if (childWidth > maxWidth) {
          _isOverflow = true;
          //第一个或最后一个child的宽度大于剩余宽度, 则重新测量
          final overflowChildConstraints = isFirst
              ? BoxConstraints(
                  maxWidth:
                      maxWidth -
                      (children.fold(
                            0.0,
                            (width, e) =>
                                width +
                                (e == child ? 0 : e.size.width) +
                                spacing,
                          ) -
                          spacing),
                )
              : BoxConstraints(maxWidth: maxWidth);
          final newChildSize = ChildLayoutHelper.layoutChild(
            child,
            overflowChildConstraints,
          );
          childMaxHeight = math.max(childMaxHeight, newChildSize.height);
          if (childMaxHeight != size.height) {
            size = constraints.constrain(Size(size.width, childMaxHeight));
          } else if (isReLayoutChild) {
            debugger();
            final FlexParentData childParentData =
                child.parentData! as FlexParentData;
            childParentData.offset = Offset(
              childUseWidth,
              childParentData.offset.dy,
            );
          }
          if (isFirst) {
            //重新对齐主轴
            _mainAxisAlignmentChildren(children, child);
          }
          //重新对齐交叉轴
          for (final child in children) {
            _crossAxisAlignmentChild(child);
          }
          //debugger();
        }
      } else {
        if (childWidth > 0) {
          childUseWidth += childWidth + spacing;
        } else {
          //如果child的宽度为0, 则有可能被最后一个元素挤掉了
          final childParentData = child.parentData;
          if (childParentData is FlexParentData) {
            if ((childParentData.flex ?? 0) != 0) {
              //重新测量被挤掉的元素
              final childSize = ChildLayoutHelper.layoutChild(
                child,
                BoxConstraints(),
              );
              childUseWidth += childSize.width + spacing;
              isReLayoutChild = true;
            }
          }
        }
      }
    }
  }

  /// 重新对齐主轴
  void _mainAxisAlignmentChildren(
    List<RenderBox> children,
    RenderBox excludeChild,
  ) {
    double left = 0;
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        break;
      case MainAxisAlignment.end:
        left =
            size.width -
            (children.fold(0.0, (width, e) => width + e.size.width + spacing) -
                spacing);
        break;
      case MainAxisAlignment.center:
        left =
            size.width -
            (children.fold(0.0, (width, e) => width + e.size.width + spacing) -
                    spacing) /
                2;
        break;
      case MainAxisAlignment.spaceBetween:
        //left = (constraints.maxWidth - childSize.width) / 2;
        break;
      case MainAxisAlignment.spaceAround:
        break;
      case MainAxisAlignment.spaceEvenly:
        break;
    }
    for (final child in children) {
      final childSize = child.size;
      final childParentData = child.parentData! as FlexParentData;
      if (child == excludeChild) {
        left += childSize.width + spacing;
        continue;
      }
      switch (mainAxisAlignment) {
        case MainAxisAlignment.start:
        case MainAxisAlignment.center:
        case MainAxisAlignment.end:
          childParentData.offset = Offset(left, childParentData.offset.dy);
          left += childSize.width + spacing;
          break;
        case MainAxisAlignment.spaceBetween:
          //left = (constraints.maxWidth - childSize.width) / 2;
          break;
        case MainAxisAlignment.spaceAround:
          break;
        case MainAxisAlignment.spaceEvenly:
          break;
      }
    }
  }

  /// 交叉轴对齐child
  void _crossAxisAlignmentChild(RenderBox child) {
    //重新计算[crossAxisAlignment]偏移量
    final childSize = child.size;
    final childParentData = child.parentData! as FlexParentData;
    switch (crossAxisAlignment) {
      case .start:
        break;
      case .end:
        childParentData.offset = Offset(
          childParentData.offset.dx,
          size.height - childSize.height,
        );
        break;
      case .center:
        /*debugger();*/
        childParentData.offset = Offset(
          childParentData.offset.dx,
          (size.height - childSize.height) / 2,
        );
        break;
      case .stretch:
      case .baseline:
        break;
    }
  }

  /// [paintOverflowIndicator]
  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (_isOverflow) {
      defaultPaint(context, offset);
      return;
    }
    //溢出之后使用系统的绘制会绘制溢出提示
    //会绘制[paintOverflowIndicator]
    super.paint(context, offset);
  }
}
