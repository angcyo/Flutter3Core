part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/28
///

/// 对齐子元素, 通过修改[child!.parentData]这样的方式手势碰撞就会自动计算
///
/// [childSize].[child]二选一
///
/// [AlignmentDirectional]
/// [Alignment]
/// [AlignmentEx.offset]
/// 返回对应的偏移量
Offset alignChildOffset(
  AlignmentGeometry alignment,
  Size containsSize, {
  Size? childSize, //二选一
  RenderBox? child, //可以不传
}) {
  var dx = 0.0;
  var dy = 0.0;
  childSize ??= child?.size ?? Size.zero;
  //x
  switch (alignment) {
    case AlignmentDirectional.topStart:
    case AlignmentDirectional.centerStart:
    case AlignmentDirectional.bottomStart:
    case Alignment.topLeft:
    case Alignment.centerLeft:
    case Alignment.bottomLeft:
      dx = 0;
      break;
    case AlignmentDirectional.topCenter:
    case AlignmentDirectional.center:
    case AlignmentDirectional.bottomCenter:
    case Alignment.topCenter:
    case Alignment.center:
    case Alignment.bottomCenter:
      dx = (containsSize.width - childSize.width) / 2;
      break;
    case AlignmentDirectional.topEnd:
    case AlignmentDirectional.centerEnd:
    case AlignmentDirectional.bottomEnd:
    case Alignment.topRight:
    case Alignment.centerRight:
    case Alignment.bottomRight:
      dx = containsSize.width - childSize.width;
      break;
  }
  //y
  switch (alignment) {
    case AlignmentDirectional.topStart:
    case AlignmentDirectional.topCenter:
    case AlignmentDirectional.topEnd:
    case Alignment.topLeft:
    case Alignment.topCenter:
    case Alignment.topRight:
      dy = 0;
      break;
    case AlignmentDirectional.centerStart:
    case AlignmentDirectional.center:
    case AlignmentDirectional.centerEnd:
    case Alignment.centerLeft:
    case Alignment.center:
    case Alignment.centerRight:
      dy = (containsSize.height - childSize.height) / 2;
      break;
    case AlignmentDirectional.bottomStart:
    case AlignmentDirectional.bottomCenter:
    case AlignmentDirectional.bottomEnd:
    case Alignment.bottomLeft:
    case Alignment.bottomCenter:
    case Alignment.bottomRight:
      dy = containsSize.height - childSize.height;
      break;
  }
  final offset = Offset(dx, dy);
  //debugger();
  final childParentData = child?.parentData;
  if (childParentData is BoxParentData) {
    childParentData.offset = offset;
  } else if (childParentData is StackParentData) {
    childParentData.left = offset.dx;
    childParentData.top = offset.dy;
    childParentData.width = childSize.width;
    childParentData.height = childSize.height;
  }
  return offset;
}

/// 将一个大小, 在一个矩形内对齐,
/// [alignment] 对齐方式
/// [containsBounds] 容器
/// [childSize] 子元素大小
/// 返回对应的left/top偏移量
Offset alignRectOffset(
  AlignmentGeometry alignment,
  Rect containsBounds,
  Size childSize,
) {
  final offset =
      alignChildOffset(alignment, containsBounds.size, childSize: childSize);
  return containsBounds.topLeft + offset;
}

/// 将一个很大目标的[childSize], 放到一个小一点的容器内[parentSize].
/// 输出一个适合的[Size], 适合于[parentSize].
Size applySizeFit(
  Size parentSize,
  Size childSize, {
  BoxFit fit = BoxFit.scaleDown,
}) {
  final fitSize = applyBoxFit(fit, childSize, parentSize);
  return fitSize.destination;
}

/// 将一个大小,按照[fit].[alignment]规则, 返回计算后的位置和大小
/// [parentRect] 容器大小
/// [childRect] 目标child大小
Rect applyAlignRect(
  Size parentSize,
  Size childSize, {
  BoxFit? fit,
  Alignment? alignment = Alignment.center,
  String? debugLabel,
}) {
  final targetSize = childSize;
  final Size fitTargetSize;

  //fit
  if (fit != null) {
    //获取fit作用后的大小
    final fitSize = applyBoxFit(fit, targetSize, parentSize);
    fitTargetSize = fitSize.destination;
    //debugger();
  } else {
    fitTargetSize = targetSize;
  }

  //alignment
  if (alignment != null) {
    //获取对齐后的矩形位置
    final destinationRect = alignment.inscribe(
      fitTargetSize,
      Offset.zero & parentSize,
    );
    return destinationRect;
  } else {
    final result = Rect.fromLTWH(
      0,
      0,
      fitTargetSize.width,
      fitTargetSize.height,
    );
    return result;
  }
}

/// 与[applyAlignRect]类似, 只不过返回值是[Matrix4]
/// [anchorOffset]. [alignment]对齐后缩放的锚点偏移量, 可以不指定
///
/// [parentSize] 最终容器大小
/// [childSize] 当前child大小
///
Matrix4 applyAlignMatrix(
  Size parentSize,
  Size childSize, {
  BoxFit? fit = BoxFit.contain /*默认:BoxFit.contain 尽可能显示最大尺寸*/,
  Alignment? alignment = Alignment.center /*默认: Alignment.center*/,
  //--
  Offset? anchorOffset,
  String? debugLabel,
}) {
  //debugger(when: debugLabel != null);
  final rect = applyAlignRect(
    parentSize,
    childSize,
    fit: fit,
    alignment: alignment,
  );
  //debugger(when: debugLabel != null);
  return Matrix4.identity()
    ..scaleBy(
      sx: rect.width / childSize.width,
      sy: rect.height / childSize.height,
      anchor: Offset(
        rect.left + (anchorOffset?.dx ?? 0),
        rect.top + (anchorOffset?.dy ?? 0),
      ),
    )
    ..translate(rect.left, rect.top);
}

/// [RenderBoxContainerDefaultsMixin.defaultPaint]
void defaultPaintChild(
  PaintingContext context,
  Offset offset,
  RenderObject? child,
) {
  if (child != null) {
    final childParentData = child.parentData;
    if (childParentData is AnyParentData && childParentData.visible != true) {
      return;
    }
    if (childParentData is BoxParentData) {
      context.paintChild(child, childParentData.offset + offset);
    } else {
      context.paintChild(child, offset);
    }
  }
}

/// [RenderBoxContainerDefaultsMixin.defaultHitTestChildren]
bool defaultHitTestChild(
  BoxHitTestResult result,
  RenderObject? child,
  Offset position,
) {
  if (child is RenderBox) {
    // The x, y parameters have the top left of the node's box as the origin.
    final childParentData = child.parentData;
    if (childParentData is AnyParentData && childParentData.visible != true) {
      return false;
    }
    if (childParentData is BoxParentData) {
      return result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
    } else {
      return child.hitTest(result, position: position);
    }
  }
  return false;
}
