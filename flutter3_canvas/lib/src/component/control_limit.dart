part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/20
///
/// 控制限制器
class ControlLimit {
  /// 元素控制器
  final CanvasElementControlManager canvasElementControlManager;

  //---

  @dp
  double? minLeft = -999999;

  @dp
  double? maxLeft = 999999;

  @dp
  double? minTop = -999999;

  @dp
  double? maxTop = 999999;

  ///限制元素最小的宽度
  @dp
  double? elementMinWidth = 1;

  /// 限制元素最小的高度
  @dp
  double? elementMinHeight = 1;

  /// 限制元素最大的宽度
  @dp
  double? elementMaxWidth = 999999;

  /// 限制元素最大的高度
  @dp
  double? elementMaxHeight = 999999;

  //---

  ControlLimit(this.canvasElementControlManager);

  /// 限制[bounds]的边界, 和最小的宽高
  Rect limitBounds(Rect bounds) {
    final minWidth = elementMinWidth;
    final minHeight = elementMinHeight;

    final maxWidth = elementMaxWidth;
    final maxHeight = elementMaxHeight;

    final newWidth = clamp(bounds.width, minWidth, maxWidth);
    final newHeight = clamp(bounds.height, minHeight, maxHeight);

    final newLeft = bounds.left;
    final newTop = bounds.top;

    return Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
  }

  /// 限制元素的平移范围
  /// [CanvasElementControlManager.translateElement]
  List<double> limitTranslate(
    double dx,
    double dy,
    @dp Rect? bounds,
  ) {
    if (bounds == null) {
      dx = clamp(dx, minLeft, maxLeft);
      dy = clamp(dy, minTop, maxTop);
      return [dx, dy];
    }
    double newLeft = bounds.left + dx;
    double newTop = bounds.top + dy;
    newLeft = clamp(newLeft, minLeft, maxLeft);
    newTop = clamp(newTop, minTop, maxTop);
    return [newLeft - bounds.left, newTop - bounds.top];
  }

  /// 限制缩放, 输入需要进行的缩放比例, 输出最终的缩放比例
  /// [sx] x轴缩放比例
  /// [sy] y轴缩放比例
  /// [isLockRatio] 是否锁定比例
  /// [bounds] 元素现有的边界
  /// [CanvasElementControlManager.scaleElement]
  List<double> limitScale(
    double sx,
    double sy,
    bool isLockRatio,
    @dp Rect? bounds,
  ) {
    if (bounds == null) {
      return [sx, sy];
    }
    final minWidth = elementMinWidth;
    final minHeight = elementMinHeight;

    final maxWidth = elementMaxWidth;
    final maxHeight = elementMaxHeight;

    if (minWidth == null &&
        minHeight == null &&
        maxWidth == null &&
        maxHeight == null) {
      //没有限制
      return [sx, sy];
    }

    //计算最小缩放比例
    final minSx =
        (minWidth == null || bounds.width == 0) ? sx : minWidth / bounds.width;
    final minSy = (minHeight == null || bounds.height == 0)
        ? sy
        : minHeight / bounds.height;

    //计算最大缩放比例
    final maxSx =
        (maxWidth == null || bounds.width == 0) ? sx : maxWidth / bounds.width;
    final maxSy = (maxHeight == null || bounds.height == 0)
        ? sy
        : maxHeight / bounds.height;

    if (isLockRatio) {
      //锁定比例
      if (sx < minSx || sy < minSy) {
        //最小缩放比例
        final s = max(minSx, minSy);
        return [s, s];
      }
      if (sx > maxSx || sy > maxSy) {
        //最大缩放比例
        final s = min(maxSx, maxSy);
        return [s, s];
      }
      return [sx, sy];
    } else {
      return [clampDouble(sx, minSx, maxSx), clampDouble(sy, minSy, maxSy)];
    }
  }
}
