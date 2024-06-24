part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/24
///
/// 限制操作
class Limit {
  Limit._();

  /// 指定的矩形是否可以在指定的容器内缩放, 而不超出容器边界
  /// [anchor] 需要保持不动的锚点, 在(0,0)原始矩形中的坐标
  /// [containerRect] 容器矩形
  static bool canRectScaleIn(
    Rect rect,
    double sx,
    double sy,
    Offset keepAnchor,
    Rect containerRect,
  ) {
    final scale = Matrix4.identity()..scale(sx, sy);
    final applyRect = rect.applyMatrix(scale, anchor: keepAnchor);
    if (applyRect.left < containerRect.left ||
        applyRect.top < containerRect.top ||
        applyRect.right > containerRect.right ||
        applyRect.bottom > containerRect.bottom) {
      return false;
    }
    return true;
  }

  /// 限制一个矩形的缩放操作, 使其只能在指定的矩形范围内
  /// [rect] 当前的矩形
  /// [equalRatio] 是否等比操作
  /// [minRect] 限制最小的宽高
  /// [maxRect] 限制最大的宽高
  /// @return 返回新的缩放sx, sy, Record类型
  /// https://api.flutter.dev/flutter/dart-core/Record-class.html
  static ({double sx, double sy}) limitRectScale(
    Rect rect,
    double sx,
    double sy, {
    bool equalRatio = true,
    Rect? minRect,
    Rect? maxRect,
  }) {
    if (minRect == null && maxRect == null) {
      //不限制
      return (sx: sx, sy: sy);
    }

    //需要缩放到的目标大小
    double targetWidth = rect.width * sx;
    double targetHeight = rect.height * sy;

    if (minRect != null) {
      if (targetWidth < minRect.width || targetHeight < minRect.height) {
        //需要限制最小宽高
        final minSx = minRect.width / rect.width;
        final minSy = minRect.height / rect.height;
        if (equalRatio) {
          sx = sy = math.max(minSx, minSy);
        } else {
          if (targetWidth < minRect.width) {
            sx = minSx;
          }
          if (targetHeight < minRect.height) {
            sy = minSy;
          }
        }
      }
    }

    targetWidth = rect.width * sx;
    targetHeight = rect.height * sy;

    if (maxRect != null) {
      if (targetWidth > maxRect.width || targetHeight > maxRect.height) {
        //需要限制最大宽高
        final maxSx = maxRect.width / rect.width;
        final maxSy = maxRect.height / rect.height;
        if (equalRatio) {
          sx = sy = math.min(maxSx, maxSy);
        } else {
          if (targetWidth > maxRect.width) {
            sx = maxSx;
          }
          if (targetHeight > maxRect.height) {
            sy = maxSy;
          }
        }
      }
    }

    targetWidth = rect.width * sx;
    targetHeight = rect.height * sy;

    return (sx: targetWidth / rect.width, sy: targetHeight / rect.height);
  }

  /// 限制一个矩形的平移操作, 使其只能在指定的矩形范围内
  /// [containerRect] 在此容器内移动
  static Rect limitRectTranslate(
    Rect rect,
    double tx,
    double ty,
    Rect containerRect,
  ) {
    double newLeft = rect.left + tx;
    double newTop = rect.top + ty;
    double newRight = rect.right + tx;
    double newBottom = rect.bottom + ty;

    if (newLeft < containerRect.left) {
      newLeft = containerRect.left;
      newRight = newLeft + rect.width;
    } else if (newRight > containerRect.right) {
      newRight = containerRect.right;
      newLeft = newRight - rect.width;
    }
    //
    if (newTop < containerRect.top) {
      newTop = containerRect.top;
      newBottom = newTop + rect.height;
    } else if (newBottom > containerRect.bottom) {
      newBottom = containerRect.bottom;
      newTop = newBottom - rect.height;
    }
    return Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }
}
