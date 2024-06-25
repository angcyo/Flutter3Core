part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 绘制管理
class GraffitiElementManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  final GraffitiDelegate graffitiDelegate;

  /// 绘制在[elements]之前的元素列表, 不参与控制操作
  final List<GraffitiPainter> beforeElements = [];

  /// 元素列表, 正常操作区域的元素, 参与控制操作
  final List<GraffitiPainter> elements = [];

  /// 绘制在[elements]之后的元素列表, 不参与控制操作
  final List<GraffitiPainter> afterElements = [];

  GraffitiElementManager(this.graffitiDelegate);

  /// 绘制元素入口
  /// [GraffitiPaintManager.paint]
  @entryPoint
  void paintElements(Canvas canvas, PaintMeta paintMeta) {
    for (final element in beforeElements) {
      paintElement(canvas, paintMeta, element);
    }
    for (final element in elements) {
      paintElement(canvas, paintMeta, element);
    }
    for (final element in afterElements) {
      paintElement(canvas, paintMeta, element);
    }
  }

  /// 绘制元素
  /// [paintElements]
  @property
  void paintElement(
    Canvas canvas,
    PaintMeta paintMeta,
    GraffitiPainter element,
  ) {
    element.painting(canvas, paintMeta);
  }

  //--

  //region ---element操作---

  /// [afterElements]
  /// [beforeElements]
  bool addBeforeElement(GraffitiPainter? element) =>
      _addElementIn(beforeElements, element);

  /// [afterElements]
  /// [beforeElements]
  bool addAfterElement(GraffitiPainter? element) =>
      _addElementIn(afterElements, element);

  /// [afterElements]
  /// [beforeElements]
  bool removeBeforeElement(GraffitiPainter? element) =>
      _removeElementFrom(beforeElements, element);

  /// [afterElements]
  /// [beforeElements]
  bool removeAfterElement(GraffitiPainter? element) =>
      _removeElementFrom(afterElements, element);

  /// 在指定容器中添加元素
  /// 返回值表示操作是否成功
  bool _addElementIn(List<GraffitiPainter> list, GraffitiPainter? element) {
    if (element == null) {
      assert(() {
        l.w('无效的操作');
        return true;
      }());
      return false;
    }
    if (!list.contains(element)) {
      list.add(element);
      if (element.graffitiDelegate != graffitiDelegate) {
        element.attachToGraffitiDelegate(graffitiDelegate);
      }
      graffitiDelegate.refresh();
      return true;
    }
    return false;
  }

  /// 从指定容器中移除元素
  /// 返回值表示操作是否成功
  bool _removeElementFrom(
      List<GraffitiPainter> list, GraffitiPainter? element) {
    //debugger();
    if (element == null) {
      assert(() {
        l.w('无效的操作');
        return true;
      }());
      return false;
    }
    if (list.contains(element)) {
      list.remove(element);
      if (element.graffitiDelegate == graffitiDelegate) {
        element.detachFromGraffitiDelegate(graffitiDelegate);
      }
      graffitiDelegate.refresh();
      return true;
    }
    return false;
  }

  /// 添加元素
  /// [element] 要添加的元素
  @supportUndo
  @api
  void addElement(
    GraffitiPainter? element, {
    UndoType undoType = UndoType.normal,
  }) {
    if (element == null) {
      assert(() {
        l.w('无效的操作');
        return true;
      }());
      return;
    }
    addElementList(
      element.ofList(),
      undoType: undoType,
    );
  }

  /// 添加一组元素
  /// [list] 要添加的一组元素
  @supportUndo
  @api
  void addElementList(
    List<GraffitiPainter>? list, {
    UndoType undoType = UndoType.normal,
  }) {
    if (list == null || isNullOrEmpty(list)) {
      assert(() {
        l.w('无效的操作');
        return true;
      }());
      return;
    }

    final old = elements.clone();
    elements.addAll(list);
    for (final element in list) {
      element.attachToGraffitiDelegate(graffitiDelegate);
    }
    graffitiDelegate.dispatchGraffitiElementListChanged(
        old, elements, list, undoType);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      graffitiDelegate.graffitiUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          for (final element in list) {
            element.detachFromGraffitiDelegate(graffitiDelegate);
          }
          graffitiDelegate.dispatchGraffitiElementListChanged(
              newList, old, list, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          for (final element in list) {
            element.attachToGraffitiDelegate(graffitiDelegate);
          }
          graffitiDelegate.dispatchGraffitiElementListChanged(
              old, newList, list, UndoType.redo);
        },
      ));
    }
  }

  /// 删除元素
  @supportUndo
  @api
  void removeElement(GraffitiPainter element,
      {UndoType undoType = UndoType.normal}) {
    removeElementList(element.ofList(), undoType: undoType);
  }

  /// 删除一组元素
  @supportUndo
  @api
  void removeElementList(List<GraffitiPainter>? list,
      {UndoType undoType = UndoType.normal}) {
    if (list == null || isNullOrEmpty(list)) {
      return;
    }
    final old = elements.clone();
    final op = elements.removeAll(list);

    for (final element in op) {
      element.detachFromGraffitiDelegate(graffitiDelegate);
    }
    graffitiDelegate.dispatchGraffitiElementListChanged(
        old, elements, op, undoType);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      graffitiDelegate.graffitiUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          for (final element in op) {
            element.attachToGraffitiDelegate(graffitiDelegate);
          }
          graffitiDelegate.dispatchGraffitiElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          for (final element in op) {
            element.detachFromGraffitiDelegate(graffitiDelegate);
          }
          graffitiDelegate.dispatchGraffitiElementListChanged(
              old, newList, op, UndoType.redo);
        },
      ));
    }
  }

  /// 重置元素列表
  @api
  @supportUndo
  void resetElementList(
    List<GraffitiPainter>? list, {
    bool selected = false,
    bool showRect = false,
    UndoType undoType = UndoType.normal,
  }) {
    list ??= [];
    final old = elements.clone();
    final op = list.clone();
    _resetElementList(old, op);
    graffitiDelegate.dispatchGraffitiElementListChanged(old, op, op, undoType);

    if (undoType == UndoType.normal) {
      final newList = op;
      graffitiDelegate.graffitiUndoManager.add(UndoActionItem(
        () {
          //debugger();
          _resetElementList(newList, old);
          graffitiDelegate.dispatchGraffitiElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          _resetElementList(old, newList);
          graffitiDelegate.dispatchGraffitiElementListChanged(
              old, newList, op, UndoType.redo);
        },
      ));
    }
  }

  void _resetElementList(List<GraffitiPainter> from, List<GraffitiPainter> to) {
    for (var element in from) {
      element.detachFromGraffitiDelegate(graffitiDelegate);
    }
    elements.reset(to);
    for (var element in to) {
      element.attachToGraffitiDelegate(graffitiDelegate);
    }
  }

  /// 清空元素
  @supportUndo
  @api
  void clearElements([UndoType undoType = UndoType.normal]) {
    removeElementList(elements.clone(), undoType: undoType);
  }

  /// 释放资源
  @entryPoint
  void release() {}
}
