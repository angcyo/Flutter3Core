part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/20
///
/// 控制限制器
class ControlLimit {
  final CanvasElementControlManager canvasElementControlManager;

  ///限制元素最小的宽度
  @dp
  double? elementMinWidth = 1;

  /// 限制元素最小的高度
  @dp
  double? elementMinHeight = 1;

  ControlLimit(this.canvasElementControlManager);

  /// 限制缩放, 输入需要进行的缩放比例, 输出最终的缩放比例
  /// [sx] x轴缩放比例
  /// [sy] y轴缩放比例
  /// [isLockRatio] 是否锁定比例
  /// [bounds] 元素现有的边界
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

    if (minWidth == null && minHeight == null) {
      return [sx, sy];
    }

    final minSx = minWidth == null ? sx : minWidth / bounds.width;
    final minSy = minHeight == null ? sy : minHeight / bounds.height;

    if (isLockRatio) {
      //锁定比例
      if (sx < minSx || sy < minSy) {
        final s = max(minSx, minSy);
        return [s, s];
      }
      return [sx, sy];
    } else {
      return [max(sx, minSx), max(sy, minSy)];
    }
  }
}
