part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 元素管理, 包含元素的绘制, 选择, 添加/删除等相关操作

class CanvasElementManager with Diagnosticable {
  final CanvasDelegate canvasDelegate;

  /// 元素控制管理
  late CanvasElementControlManager canvasElementControlManager =
      CanvasElementControlManager(this);

  //---

  bool get isSelectedElement => canvasElementControlManager.isSelectedElement;

  CanvasElementManager(this.canvasDelegate);

  /// 元素列表
  final List<ElementPainter> elements = [];

  //region ---entryPoint----

  /// 绘制元素入口
  /// [CanvasPaintManager.paint]
  @entryPoint
  void paintElements(Canvas canvas, PaintMeta paintMeta) {
    canvas.withClipRect(canvasDelegate.canvasViewBox.canvasBounds, () {
      //---元素绘制
      for (var element in elements) {
        element.painting(canvas, paintMeta);
      }
      canvasElementControlManager.paint(canvas, paintMeta);
    });
  }

  /// 事件处理入口
  /// [CanvasEventManager.handleEvent]
  @entryPoint
  void handleElementEvent(PointerEvent event, BoxHitTestEntry entry) {
    canvasElementControlManager.handleEvent(event, entry);
  }

  //endregion ---entryPoint----

  /// 添加元素
  void addElement(ElementPainter element) {
    final old = elements.clone();
    elements.add(element);
    element.attachToCanvasDelegate(canvasDelegate);
    canvasDelegate.dispatchCanvasElementListChanged(old, elements);
  }

  /// 删除元素
  void removeElement(ElementPainter element) {
    final old = elements.clone();
    elements.remove(element);
    element.detachFromCanvasDelegate(canvasDelegate);
    canvasDelegate.dispatchCanvasElementListChanged(old, elements);
  }

  /// 清空元素
  void clearElements() {
    final old = elements.clone();
    elements.clear();
    for (var element in old) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    canvasDelegate.dispatchCanvasElementListChanged(old, elements);
  }

  /// 查找元素, 按照元素的先添加先返回的顺序
  List<ElementPainter> findElement(
      {@sceneCoordinate Offset? point,
      @sceneCoordinate Rect? rect,
      @sceneCoordinate Path? path}) {
    final result = <ElementPainter>[];
    for (var element in elements) {
      if (element.hitTest(point: point, rect: rect, path: path)) {
        result.add(element);
      }
    }
    return result;
  }

  /// 添加一个选中的元素
  void addSelectElement(ElementPainter element) {
    final list =
        canvasElementControlManager.elementSelectComponent.children ?? [];
    list.add(element);
    canvasElementControlManager.elementSelectComponent.resetSelectElement(list);
  }

  /// 移除一个选中的元素
  void removeSelectElement(ElementPainter element) {
    final list =
        canvasElementControlManager.elementSelectComponent.children ?? [];
    if (list.remove(element)) {
      canvasElementControlManager.elementSelectComponent
          .resetSelectElement(list);
    }
  }

  /// 重置选中的元素
  void resetSelectElement(List<ElementPainter>? elements) {
    canvasElementControlManager.elementSelectComponent
        .resetSelectElement(elements);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('elements', elements));
  }
}
