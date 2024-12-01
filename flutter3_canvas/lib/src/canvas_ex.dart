part of '../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/16
///

/// 画布扩展方法
/// `on List<ElementPainter>`
extension CanvasElementPainterIterableEx on Iterable<ElementPainter> {
  /// [CanvasPaintManager.rasterizeElementList]
  Future<UiImage?> rasterizeElement({
    Rect? elementBounds,
    EdgeInsets? extend,
  }) =>
      CanvasPaintManager.rasterizeElementList(
        toList(),
        elementBounds: elementBounds,
        extend: extend,
      );

  /// 获取[ElementPainter]对应的[ElementPainter.parentGroupPainter]
  List<ElementGroupPainter>? get parentPainterList =>
      map((e) => e.parentGroupPainter).toList().filterNull();

  /// 过滤出所有可见的元素集合
  List<ElementPainter>? get filterVisibleList => filter((e) => e.isVisible);

  /// 所有可见元素是否都锁定了操作
  bool get isAllLockOperate => all((e) => e.isLockOperate);

  /// 所有可见元素是否没锁定操作
  bool get isAllUnlockOperate => all((e) => !e.isLockOperate);

  /// 所有元素是否都可见
  bool get isAllVisible => all((e) => e.isVisible);

  /// 所有元素是否都不可见
  bool get isAllInvisible => all((e) => !e.isVisible);

  //--

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
  /// [includeGroupPainter] 是否要包含[ElementGroupPainter]本身
  /// [ElementPainter.getSingleElementList]
  List<ElementPainter> getAllSingleElement({bool includeGroupPainter = false}) {
    final result = <ElementPainter>[];
    for (final e in this) {
      result.addAll(
          e.getSingleElementList(includeGroupPainter: includeGroupPainter));
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

/// 元素扩展
extension CanvasElementPainterEx on ElementPainter {
  /// [CanvasPaintManager.rasterizeElement]
  Future<UiImage?> rasterizeElement({
    Rect? elementBounds,
    EdgeInsets? extend,
    int? maxWidth,
    int? maxHeight,
  }) =>
      CanvasPaintManager.rasterizeElement(
        this,
        elementBounds: elementBounds,
        extend: extend,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

  /// 获取[ElementGroupPainter]的子元素列表
  List<ElementPainter>? get childList => this is ElementGroupPainter
      ? (this as ElementGroupPainter).children
      : null;
}

/// 订阅扩展
mixin HookPainterMixin on ElementPainter, HookMixin {
  @override
  void detachFromCanvasDelegate(CanvasDelegate canvasDelegate) {
    disposeHook();
    super.detachFromCanvasDelegate(canvasDelegate);
  }
}

/// 多画布扩展
extension CanvasStateDataIterableEx on Iterable<CanvasStateData> {
  /// 所有画布都没有元素
  bool get isElementsEmpty {
    return isEmpty || every((element) => element.isElementEmpty);
  }

  /// 所有画布对应的元素集合
  List<ElementPainter> get allElementList =>
      mapFlat((e) => e.elements).toList();
}
