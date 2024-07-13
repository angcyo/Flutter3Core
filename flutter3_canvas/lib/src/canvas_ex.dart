part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/16
///

/// 画布扩展方法
/// `on List<ElementPainter>`
extension CanvasElementIterableEx on Iterable<ElementPainter> {
  /// 获取所有元素的边界
  Rect? get allElementBounds {
    if (isNil(this)) {
      return Rect.zero;
    }
    final group = ElementGroupPainter.createGroupIfNeed(toList());
    return group?.elementsBounds;
  }

  /// 排序元素
  /// [topLeft] 按照从上到下, 从左到右的顺序, 排序元素. 默认
  /// [leftTop] 按照从左到右, 从上到下的顺序, 排序元素
  List<ElementPainter> sortElement({
    bool resetElementAngle = true,
    bool? topLeft,
    bool? leftTop,
  }) {
    return toList()
      ..sort((a, b) {
        final aBounds = a.paintProperty?.getBounds(resetElementAngle);
        final bBounds = b.paintProperty?.getBounds(resetElementAngle);

        final aTop = aBounds?.top ?? 0;
        final bTop = bBounds?.top ?? 0;

        final aLeft = aBounds?.left ?? 0;
        final bLeft = bBounds?.left ?? 0;

        if (leftTop == true) {
          // 从左到右, 从上到下
          if (aLeft == bLeft) {
            return aTop.compareTo(bTop);
          }
          return aLeft.compareTo(bLeft);
        } else {
          // 从上到下, 从左到右
          if (aTop == bTop) {
            return aLeft.compareTo(bLeft);
          }
          return aTop.compareTo(bTop);
        }
      });
  }

  /// 获取所有单的[ElementPainter]
  /// [ElementPainter.getSingleElementList]
  List<ElementPainter> getAllSingleElement() {
    final result = <ElementPainter>[];
    for (final e in this) {
      result.addAll(e.getSingleElementList());
    }
    return result;
  }

  /// [useElementBounds]当元素没有[Path]时, 是否使用元素的bounds代替
  List<Path> getAllElementOutputPathList({
    bool useElementBounds = false,
  }) {
    final elementList = getAllSingleElement();
    final result = <Path>[];
    for (final element in elementList) {
      final pathList = element.elementOutputPathList;
      if (pathList.isEmpty) {
        if (useElementBounds) {
          element.elementOutputBoundsPath?.let((it) => result.add(it));
        }
      } else {
        result.addAll(pathList);
      }
    }
    return result;
  }

  /// 所有元素是否都是矢量元素
  bool isAllPathElement() {
    final elementList = getAllSingleElement();
    return elementList.all((e) => e.isPathElement);
  }
}

/// 订阅扩展
mixin StreamSubscriptionPainterMixin on ElementPainter {
  final List<StreamSubscription> _streamPainterSubscriptions = [];

  /// 在[detachFromCanvasDelegate]时, 取消所有的[StreamSubscription]
  void hookPainterStreamSubscription(StreamSubscription subscription) {
    _streamPainterSubscriptions.add(subscription);
  }

  @override
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    try {
      for (final element in _streamPainterSubscriptions) {
        try {
          element.cancel();
        } catch (e) {
          printError(e);
        }
      }
    } finally {
      _streamPainterSubscriptions.clear();
    }
    super.detachFromCanvasDelegate(canvasDelegate);
  }
}
