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

  //region ---element---

  /// 添加元素
  @supportUndo
  @api
  void addElement(ElementPainter element,
      {UndoType undoType = UndoType.normal}) {
    addElementList(element.ofList(), undoType: undoType);
  }

  /// 添加一组元素
  @supportUndo
  @api
  void addElementList(List<ElementPainter>? list,
      {UndoType undoType = UndoType.normal}) {
    if (list == null || isNullOrEmpty(list)) {
      return;
    }

    final old = elements.clone();
    elements.addAll(list);
    for (var element in list) {
      element.attachToCanvasDelegate(canvasDelegate);
    }
    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, list, undoType);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoItem(
        () {
          //debugger();
          elements.reset(old);
          canvasElementControlManager.onCanvasElementDeleted(list);
          for (var element in list) {
            element.detachFromCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, list, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          for (var element in list) {
            element.attachToCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, list, UndoType.redo);
        },
      ));
    }
  }

  /// 删除元素
  @supportUndo
  @api
  void removeElement(ElementPainter element,
      {UndoType undoType = UndoType.normal}) {
    removeElementList(element.ofList(), undoType: undoType);
  }

  /// 删除一组元素
  @supportUndo
  @api
  void removeElementList(List<ElementPainter>? list,
      {UndoType undoType = UndoType.normal}) {
    if (list == null || isNullOrEmpty(list)) {
      return;
    }
    final old = elements.clone();
    final op = elements.removeAll(list);
    //删除选中的元素
    canvasElementControlManager.onCanvasElementDeleted(op);
    for (var element in op) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, op, undoType);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoItem(
        () {
          //debugger();
          elements.reset(old);
          for (var element in op) {
            element.attachToCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasElementControlManager.onCanvasElementDeleted(op);
          for (var element in op) {
            element.detachFromCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, op, UndoType.redo);
        },
      ));
    }
  }

  /// 清空元素
  @supportUndo
  @api
  void clearElements([UndoType undoType = UndoType.normal]) {
    removeElementList(elements, undoType: undoType);
  }

  /// 查找元素, 按照元素的先添加先返回的顺序
  @api
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

  //endregion ---element---

  //region ---select---

  /// 添加一个选中的元素
  @api
  void addSelectElement(ElementPainter element) {
    final list =
        canvasElementControlManager.elementSelectComponent.children ?? [];
    list.add(element);
    canvasElementControlManager.elementSelectComponent.resetSelectElement(list);
  }

  /// 添加一组选中的元素
  @api
  void addSelectElementList(List<ElementPainter> elements) {
    final list =
        canvasElementControlManager.elementSelectComponent.children ?? [];
    list.addAll(elements);
    canvasElementControlManager.elementSelectComponent.resetSelectElement(list);
  }

  /// 移除一个选中的元素
  @api
  void removeSelectElement(ElementPainter element) {
    final list =
        canvasElementControlManager.elementSelectComponent.children ?? [];
    if (list.remove(element)) {
      canvasElementControlManager.elementSelectComponent
          .resetSelectElement(list);
    }
  }

  /// 移除一组选中的元素
  @api
  void removeSelectElementList(List<ElementPainter> elements) {
    final list =
        canvasElementControlManager.elementSelectComponent.children ?? [];
    list.removeAll(elements);
    canvasElementControlManager.elementSelectComponent.resetSelectElement(list);
  }

  /// 重置选中的元素
  @api
  void resetSelectElement(List<ElementPainter>? elements) {
    canvasElementControlManager.elementSelectComponent
        .resetSelectElement(elements);
  }

  /// 清空选中的元素
  @api
  void clearSelectedElement() {
    resetSelectElement(null);
  }

  /// 获取所有选中的元素
  /// [onlySingleElement] 是否只返回单元素列表, 拆开了[ElementGroupPainter]
  @api
  List<ElementPainter>? getAllSelectedElement({
    bool onlySingleElement = false,
  }) {
    if (onlySingleElement) {
      return canvasElementControlManager.elementSelectComponent
          .getSingleElementList();
    }
    return canvasElementControlManager.elementSelectComponent.children;
  }

  /// 是否选中了元素
  @api
  bool isElementSelected(ElementPainter? element) {
    return canvasElementControlManager.elementSelectComponent
        .containsElement(element);
  }

  //endregion ---select---

  //region ---operate---

  //endregion ---operate---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('elements', elements));
  }
}
