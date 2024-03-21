part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 元素管理, 包含元素的绘制, 选择, 添加/删除等相关操作
class CanvasElementManager with Diagnosticable {
  //region ---属性----

  final CanvasDelegate canvasDelegate;

  /// 元素控制管理
  late CanvasElementControlManager canvasElementControlManager =
      CanvasElementControlManager(this);

  //---

  /// 选择元素的组件
  ElementSelectComponent? get elementSelectComponent => isSelectedElement
      ? canvasElementControlManager.elementSelectComponent
      : null;

  /// 选中的元素, 如果是单元素, 则返回选中的元素, 否则返回[ElementSelectComponent]
  ElementPainter? get selectedElement {
    final elementSelectComponent = canvasDelegate.canvasElementManager
        .canvasElementControlManager.elementSelectComponent;
    if (elementSelectComponent.children?.length == 1) {
      return elementSelectComponent.children?.first;
    }
    return elementSelectComponent;
  }

  /// [canvasElementControlManager.isSelectedElement]
  bool get isSelectedElement => canvasElementControlManager.isSelectedElement;

  /// [canvasElementControlManager.selectedElementCount]
  int get selectedElementCount =>
      canvasElementControlManager.selectedElementCount;

  /// [canvasElementControlManager.isSelectedGroupElement]
  bool get isSelectedGroupElement =>
      canvasElementControlManager.isSelectedGroupElement;

  /// [canvasElementControlManager.isSelectedGroupPainter]
  bool get isSelectedGroupPainter =>
      canvasElementControlManager.isSelectedGroupPainter;

  /// 绘制在[elements]之前的元素列表
  final List<ElementPainter> beforeElements = [];

  /// 元素列表, 正常操作区域的元素
  final List<ElementPainter> elements = [];

  /// 绘制在[elements]之后的元素列表
  final List<ElementPainter> afterElements = [];

  //endregion ---属性----

  CanvasElementManager(this.canvasDelegate);

  //region ---entryPoint----

  /// 绘制元素入口
  /// [CanvasPaintManager.paint]
  @entryPoint
  void paintElements(Canvas canvas, PaintMeta paintMeta) {
    final canvasViewBox = canvasDelegate.canvasViewBox;
    canvas.withClipRect(canvasViewBox.canvasBounds, () {
      //---元素绘制
      for (var element in beforeElements) {
        paintElement(canvas, paintMeta, element);
      }
      for (var element in elements) {
        paintElement(canvas, paintMeta, element);
      }
      for (var element in afterElements) {
        paintElement(canvas, paintMeta, element);
      }
      //---控制绘制
      canvasElementControlManager.paint(canvas, paintMeta);
    });
  }

  /// 绘制元素
  /// [paintElements]
  void paintElement(
      Canvas canvas, PaintMeta paintMeta, ElementPainter element) {
    final canvasViewBox = canvasDelegate.canvasViewBox;
    if (element.isVisibleInCanvasBox(canvasViewBox)) {
      element.painting(canvas, paintMeta);
    } else {
      assert(() {
        l.d('元素不可见,跳过绘制:$element');
        return true;
      }());
    }
  }

  /// 事件处理入口
  /// [CanvasEventManager.handleEvent]
  @entryPoint
  void handleElementEvent(PointerEvent event, BoxHitTestEntry entry) {
    canvasElementControlManager.handleEvent(event, entry);
  }

  //endregion ---entryPoint----

  //region ---element操作---

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

  /// 重置元素列表
  @api
  @supportUndo
  void resetElementList(List<ElementPainter>? list,
      {UndoType undoType = UndoType.normal}) {
    list ??= [];
    final old = elements.clone();
    final op = list.clone();
    _resetElementList(old, op);
    canvasDelegate.dispatchCanvasElementListChanged(old, op, op, undoType);

    if (undoType == UndoType.normal) {
      final newList = op;
      canvasDelegate.canvasUndoManager.add(UndoItem(
        () {
          //debugger();
          _resetElementList(newList, old);
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          _resetElementList(old, newList);
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, op, UndoType.redo);
        },
      ));
    }
  }

  void _resetElementList(List<ElementPainter> from, List<ElementPainter> to) {
    for (var element in from) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    elements.reset(to);
    for (var element in to) {
      element.attachToCanvasDelegate(canvasDelegate);
    }
  }

  /// 清空元素
  @supportUndo
  @api
  void clearElements([UndoType undoType = UndoType.normal]) {
    removeElementList(elements.clone(), undoType: undoType);
  }

  /// 查找元素, 按照元素的先添加先返回的顺序
  /// [checkLockOperate] 是否检查锁定操作
  @api
  List<ElementPainter> findElement({
    @sceneCoordinate Offset? point,
    @sceneCoordinate Rect? rect,
    @sceneCoordinate Path? path,
    bool checkLockOperate = true,
  }) {
    final result = <ElementPainter>[];
    for (var element in elements) {
      if ((!checkLockOperate || !element.isLockOperate) &&
          element.hitTest(point: point, rect: rect, path: path)) {
        result.add(element);
      }
    }
    return result;
  }

  //endregion ---element操作---

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

  /// 组合元素
  @api
  void groupElement(List<ElementPainter>? elements) {
    if (elements == null || elements.length < 2) {
      assert(() {
        l.d('不满足组合条件');
        return true;
      }());
      return;
    }

    //删除原来的元素
    final newList = this.elements.clone(true);
    newList.removeAll(elements);

    //创建新的组合元素
    final group = ElementGroupPainter();
    group.resetChildren(
        elements, canvasElementControlManager.enableResetElementAngle);
    newList.add(group);

    //重置元素列表
    resetElementList(newList);

    //选中组合元素
    resetSelectElement([group]);
  }

  /// 解组元素
  @api
  void ungroupElement(ElementPainter? group,
      {UndoType undoType = UndoType.normal}) {
    if (group == null || group is! ElementGroupPainter) {
      assert(() {
        l.d('不是[ElementGroupPainter]元素,不能解组');
        return true;
      }());
      return;
    }

    var children = group.children;
    if (children == null || children.isEmpty) {
      assert(() {
        l.d('不满足解组条件');
        return true;
      }());
      return;
    }

    final newList = elements.clone(true);
    newList.remove(group);
    newList.addAll(children);

    //重置元素列表
    resetElementList(newList, undoType: undoType);

    //选中组合元素
    resetSelectElement(children);
  }

  /// 对齐组内元素
  @api
  void alignElement(ElementGroupPainter? group, CanvasAlignType align,
      {UndoType undoType = UndoType.normal}) {
    final children = group?.children;
    if (group == null || children == null || children.length < 2) {
      assert(() {
        l.d('不满足对齐条件');
        return true;
      }());
      return;
    }
    final bounds = group.paintProperty
        ?.getBounds(canvasElementControlManager.enableResetElementAngle);
    if (bounds == null) {
      assert(() {
        l.d('获取不到组合元素的边界');
        return true;
      }());
      return;
    }

    final undoState = group.createStateStack();
    for (var element in children) {
      final elementBounds = element.paintProperty
          ?.getBounds(canvasElementControlManager.enableResetElementAngle);
      if (elementBounds != null) {
        switch (align) {
          case CanvasAlignType.left:
            //所有元素对齐bounds的左边
            element.translateElement(Matrix4.identity()
              ..translate(bounds.left - elementBounds.left, 0.0));
            break;
          case CanvasAlignType.top:
            //所有元素对齐bounds的上边
            element.translateElement(Matrix4.identity()
              ..translate(0.0, bounds.top - elementBounds.top));
            break;
          case CanvasAlignType.right:
            //所有元素对齐bounds的右边
            element.translateElement(Matrix4.identity()
              ..translate(bounds.right - elementBounds.right, 0.0));
            break;
          case CanvasAlignType.bottom:
            //所有元素对齐bounds的下边
            element.translateElement(Matrix4.identity()
              ..translate(0.0, bounds.bottom - elementBounds.bottom));
            break;
          case CanvasAlignType.center:
            //所有元素对齐bounds的中心
            element.translateElement(Matrix4.identity()
              ..translate(bounds.center.dx - elementBounds.center.dx,
                  bounds.center.dy - elementBounds.center.dy));
            break;
          case CanvasAlignType.horizontalCenter:
            //所有元素对齐bounds的水平中心
            element.translateElement(Matrix4.identity()
              ..translate(0.0, bounds.center.dy - elementBounds.center.dy));
            break;
          case CanvasAlignType.verticalCenter:
            //所有元素对齐bounds的垂直中心
            element.translateElement(Matrix4.identity()
              ..translate(bounds.center.dx - elementBounds.center.dx, 0.0));
            break;
        }
      }
    }
    if (undoType == UndoType.normal) {
      final redoState = group.createStateStack();
      canvasDelegate.canvasUndoManager.addUntoState(undoState, redoState);
    }
    //更新选择元素的边界
    canvasElementControlManager.elementSelectComponent
        .updatePaintPropertyFromChildren(
            canvasElementControlManager.enableResetElementAngle);
  }

  /// 均分组内元素
  @api
  void averageElement(ElementGroupPainter? group, CanvasAverageType average,
      {UndoType undoType = UndoType.normal}) {
    final children = group?.children;
    if (group == null || children == null || children.length < 2) {
      assert(() {
        l.d('不满足均分条件');
        return true;
      }());
      return;
    }

    if (average == CanvasAverageType.horizontal ||
        average == CanvasAverageType.vertical) {
      //均分
      if (children.length <= 2) {
        assert(() {
          l.d('不满足均分条件');
          return true;
        }());
        return;
      }
    } else {
      //等宽高, 所有元素的大小, 参考第一个元素
      final firstElement = children.first;
      final firstBounds = firstElement.paintProperty
          ?.getBounds(canvasElementControlManager.enableResetElementAngle);

      if (firstBounds == null) {
        assert(() {
          l.d('获取不到元素的边界');
          return true;
        }());
        return;
      }

      final undoState = group.createStateStack();
      for (var element in children) {
        if (element == firstElement) {
          continue;
        }
        final elementBounds = element.paintProperty
            ?.getBounds(canvasElementControlManager.enableResetElementAngle);
        if (elementBounds != null) {
          switch (average) {
            case CanvasAverageType.width:
              final sx = firstBounds.width / elementBounds.width;
              element.scaleElement(sx: sx);
              break;
            case CanvasAverageType.height:
              final sy = firstBounds.height / elementBounds.height;
              element.scaleElement(sy: sy);
              break;
            case CanvasAverageType.size:
              final sx = firstBounds.width / elementBounds.width;
              final sy = firstBounds.height / elementBounds.height;
              element.scaleElement(sx: sx, sy: sy);
              break;
            default:
              break;
          }
        }
      }

      if (undoType == UndoType.normal) {
        final redoState = group.createStateStack();
        canvasDelegate.canvasUndoManager.addUntoState(undoState, redoState);
      }

      //更新选择元素的边界
      canvasElementControlManager.elementSelectComponent
          .updatePaintPropertyFromChildren(
              canvasElementControlManager.enableResetElementAngle);
    }
  }

  //endregion ---operate---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('beforeElements', beforeElements));
    properties.add(DiagnosticsProperty('elements', elements));
    properties.add(DiagnosticsProperty('afterElements', afterElements));
    properties.add(DiagnosticsProperty('selectedElement', selectedElement));
  }
}

/// 元素对齐方式
enum CanvasAlignType {
  left,
  top,
  right,
  bottom,

  /// 居中对齐
  center,

  ///在水平方向上对齐
  horizontalCenter,

  ///在垂直方向上对齐
  verticalCenter,
}

/// 均分方式
enum CanvasAverageType {
  /// 水平均分
  horizontal,

  /// 垂直均分
  vertical,

  /// 等高
  height,

  /// 等宽
  width,

  /// 等大小
  size,
}
