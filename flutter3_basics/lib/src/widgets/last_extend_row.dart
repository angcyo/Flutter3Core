part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/25
///
/// 系统的[Row]如果最后一个小部件是[Text]时, 如果不使用[Expanded]包裹, [Text]是无法换行的
/// 这个小部件支持, 支持最后一个[Widget]的宽度超过剩余空间时, 自动使用最大的剩余空间重新测量
///
class LastExtendRow extends Row {
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
      ..clipBehavior = clipBehavior;
  }
}

class LastExtendRenderFlex extends RenderFlex {
  LastExtendRenderFlex({
    super.children,
    super.direction = Axis.horizontal,
    super.mainAxisSize = MainAxisSize.max,
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.textDirection,
    super.verticalDirection = VerticalDirection.down,
    super.textBaseline,
    super.clipBehavior = Clip.none,
    super.spacing = 0,
  });

  /// 是否溢出了
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

    double useWidth = 0;
    double maxHeight = 0;

    //是否重新测量过child
    bool isReLayoutChild = false;

    for (final child in children) {
      maxHeight = math.max(maxHeight, child.size.height);
      //debugger();
      if (child == children.last) {
        final maxWidth = constraints.maxWidth - useWidth;
        //debugger();
        if (child.size.width > maxWidth) {
          _isOverflow = true;
          //最后一个child的宽度大于剩余宽度, 则重新测量
          final lastChildConstraints = BoxConstraints(
            maxWidth: maxWidth,
          );
          final childSize =
              ChildLayoutHelper.layoutChild(child, lastChildConstraints);
          maxHeight = math.max(maxHeight, childSize.height);
          if (maxHeight != size.height) {
            size = constraints.constrain(Size(size.width, maxHeight));
            //--
            for (final child in children) {
              if (child != children.last) {
                //重新计算[crossAxisAlignment]偏移量
                final childSize = child.size;
                final FlexParentData childParentData =
                    child.parentData! as FlexParentData;
                switch (crossAxisAlignment) {
                  case CrossAxisAlignment.start:
                    break;
                  case CrossAxisAlignment.end:
                    childParentData.offset = Offset(
                      childParentData.offset.dx,
                      size.height - childSize.height,
                    );
                    break;
                  case CrossAxisAlignment.center:
                    childParentData.offset = Offset(
                      childParentData.offset.dx,
                      (size.height - childSize.height) / 2,
                    );
                    break;
                  case CrossAxisAlignment.stretch:
                  case CrossAxisAlignment.baseline:
                    break;
                }
              }
            }
          } else if (isReLayoutChild) {
            final FlexParentData childParentData =
                child.parentData! as FlexParentData;
            childParentData.offset = Offset(
              useWidth,
              childParentData.offset.dy,
            );
          }
          //debugger();
        }
      } else {
        if (child.size.width > 0) {
          useWidth += child.size.width + spacing;
        } else {
          //如果child的宽度为0, 则有可能被最后一个元素挤掉了
          final childParentData = child.parentData;
          if (childParentData is FlexParentData) {
            if ((childParentData.flex ?? 0) != 0) {
              //重新测量被挤掉的元素
              final childSize =
                  ChildLayoutHelper.layoutChild(child, BoxConstraints());
              useWidth += childSize.width + spacing;
              isReLayoutChild = true;
            }
          }
        }
      }
    }
  }

  /// [paintOverflowIndicator]
  @override
  void paint(PaintingContext context, ui.Offset offset) {
    if (_isOverflow) {
      defaultPaint(context, offset);
      return;
    }
    //会绘制[paintOverflowIndicator]
    super.paint(context, offset);
  }
}
