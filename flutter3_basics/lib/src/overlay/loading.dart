part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/27
///

/// 显示加载提示
/// [showLoading]
OverlayEntry? showStrokeLoading({
  BuildContext? context,
}) {
  final size = kDefaultLoadingSize;
  return showLoading(
    context: context,
    builder: (context) {
      return const StrokeLoadingWidget(color: Colors.white)
          .container(
            color: Colors.black26,
            padding: const EdgeInsets.all(kM),
            radius: kDefaultBorderRadiusH,
            width: size.width,
            height: size.height,
          )
          .align(Alignment.center);
    },
  );
}

/// 对齐子元素, 通过修改[child!.parentData]这样的方式手势碰撞就会自动计算
/// [AlignmentDirectional]
/// [Alignment]
Offset alignChildOffset(
  AlignmentGeometry alignment,
  Size containsSize,
  Size childSize, {
  RenderBox? child,
}) {
  var dx = 0.0;
  var dy = 0.0;
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
  if (child != null && child.parentData is BoxParentData) {
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    childParentData.offset = offset;
  }
  return offset;
}
