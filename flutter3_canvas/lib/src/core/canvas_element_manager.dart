part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 元素管理, 包含元素的绘制, 选择, 添加/删除等相关操作
class CanvasElementManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  //region ---属性----

  final CanvasDelegate canvasDelegate;

  /// 元素控制管理, 核心成员
  late CanvasElementControlManager canvasElementControlManager =
      CanvasElementControlManager(this);

  //---get---

  /// 选择框绘制, 选中元素操作, 按下选择元素
  /// [ElementSelectComponent]
  ElementSelectComponent get selectComponent =>
      canvasElementControlManager.elementSelectComponent;

  /// 选择元素的组件, 未选中元素时, 返回null
  ElementSelectComponent? get elementSelectComponent =>
      isSelectedElement ? selectComponent : null;

  /// 选中的元素, 如果是单元素, 则返回选中的元素, 否则返回[ElementSelectComponent]
  /// 没有选中元素时, 返回null
  ElementPainter? get selectedElement {
    if (!isSelectedElement) {
      return null;
    }
    return elementSelectComponent?.selectedChildElement;
  }

  /// [canvasElementControlManager.isSelectedElement]
  bool get isSelectedElement => canvasElementControlManager.isSelectedElement;

  /// [canvasElementControlManager.selectedElementCount]
  int get selectedElementCount =>
      canvasElementControlManager.selectedElementCount;

  /// [canvasElementControlManager.isSelectedGroupElements]
  bool get isSelectedGroupElements =>
      canvasElementControlManager.isSelectedGroupElements;

  /// [canvasElementControlManager.isSelectedGroupPainter]
  bool get isSelectedGroupPainter =>
      canvasElementControlManager.isSelectedGroupPainter;

  //--核心元素列表--

  /// 绘制在[elements]之前的元素列表, 不参与控制操作
  /// [paintElements]
  final List<ElementPainter> beforeElements = [];

  /// 元素列表, 正常操作区域的元素, 参与控制操作
  /// [paintElements]
  final List<ElementPainter> elements = [];

  /// 绘制在[elements]之后的元素列表, 不参与控制操作
  /// [paintElements]
  final List<ElementPainter> afterElements = [];

  //--元素get--

  List<ElementPainter> get allSingleElements {
    final result = <ElementPainter>[];
    for (var element in elements) {
      result.addAll(element.getSingleElementList());
    }
    return result;
  }

  /// 获取所有元素[elements]的边界
  Rect? get allElementsBounds {
    final list = elements;
    if (isNullOrEmpty(list)) {
      return null;
    }
    final group = ElementGroupPainter();
    group.resetChildren(
        list, canvasElementControlManager.enableResetElementAngle);
    return group.paintProperty
        ?.getBounds(canvasElementControlManager.enableResetElementAngle);
  }

  //endregion ---属性----

  CanvasElementManager(this.canvasDelegate);

  //region ---entryPoint----

  /// [canvas] 处理掉基础的[offset]的canvas
  /// 绘制元素入口, 裁剪了[CanvasViewBox.canvasBounds]区域
  /// [CanvasPaintManager.paint]
  @entryPoint
  void paintElements(Canvas canvas, PaintMeta paintMeta) {
    final canvasViewBox = canvasDelegate.canvasViewBox;
    canvas.withClipRect(canvasViewBox.canvasBounds, () {
      //---元素绘制入口
      //debugger();
      for (final element in beforeElements) {
        paintElement(canvas, paintMeta, element);
      }
      for (final element in elements) {
        paintElement(canvas, paintMeta, element);
      }
      for (final element in afterElements) {
        paintElement(canvas, paintMeta, element);
      }
      //---控制绘制, 在元素最上层绘制, 所以可以实现选中元素在顶层绘制
      canvasElementControlManager.paint(canvas, paintMeta);
    });
  }

  /// 绘制元素
  /// [paintElements]
  @property
  void paintElement(
    Canvas canvas,
    PaintMeta paintMeta,
    ElementPainter element,
  ) {
    final canvasViewBox = canvasDelegate.canvasViewBox;
    if (element.isVisibleInCanvasBox(canvasViewBox)) {
      element.painting(canvas, paintMeta);
    } else {
      assert(() {
        //l.d('元素不可见,跳过绘制:$element');
        return true;
      }());
    }
  }

  /// 事件处理入口
  /// 由[CanvasEventManager.handleEvent]驱动
  @entryPoint
  void handleElementEvent(PointerEvent event, BoxHitTestEntry entry) {
    canvasElementControlManager.handleEvent(event, entry);
  }

  /// 释放资源
  @entryPoint
  void release() {
    for (final element in beforeElements) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    for (final element in elements) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    for (final element in afterElements) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
  }

  //endregion ---entryPoint----

  //region ---element操作---

  /// [afterElements]
  /// [beforeElements]
  bool addBeforeElement(ElementPainter? element) =>
      _addElementIn(beforeElements, element);

  /// [afterElements]
  /// [beforeElements]
  bool addAfterElement(ElementPainter? element) =>
      _addElementIn(afterElements, element);

  /// [afterElements]
  /// [beforeElements]
  bool removeBeforeElement(ElementPainter? element) =>
      _removeElementFrom(beforeElements, element);

  /// [afterElements]
  /// [beforeElements]
  bool removeAfterElement(ElementPainter? element) =>
      _removeElementFrom(afterElements, element);

  /// 在指定容器中添加元素
  /// 返回值表示操作是否成功
  bool _addElementIn(List<ElementPainter> list, ElementPainter? element) {
    if (element == null) {
      assert(() {
        l.w('无效的操作');
        return true;
      }());
      return false;
    }
    if (!list.contains(element)) {
      list.add(element);
      if (element.canvasDelegate != canvasDelegate) {
        element.attachToCanvasDelegate(canvasDelegate);
      }
      canvasDelegate.dispatchCanvasElementListAddChanged(list, [element]);
      canvasDelegate.refresh();
      return true;
    }
    return false;
  }

  /// 从指定容器中移除元素
  /// 返回值表示操作是否成功
  bool _removeElementFrom(List<ElementPainter> list, ElementPainter? element) {
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
      if (element.canvasDelegate == canvasDelegate) {
        element.detachFromCanvasDelegate(canvasDelegate);
      }
      canvasDelegate.dispatchCanvasElementListAddChanged(list, [element]);
      canvasDelegate.refresh();
      return true;
    }
    return false;
  }

  /// 添加元素
  /// [element] 要添加的元素
  /// [selected] 是否选中对应元素
  /// [followPainter] 是否显示元素的边界
  @supportUndo
  @api
  void addElement(
    ElementPainter? element, {
    @dp Offset? offset,
    bool selected = false,
    bool followPainter = false,
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
      offset: offset,
      selected: selected,
      followPainter: followPainter,
      undoType: undoType,
    );
  }

  /// 添加一组元素
  /// [list] 要添加的一组元素
  /// [selected] 添加完成后,是否选中
  /// [followPainter] 移动元素到画布中心
  /// [offset] 所有元素的偏移量
  @supportUndo
  @api
  void addElementList(
    List<ElementPainter>? list, {
    @dp Offset? offset,
    bool selected = false,
    bool followPainter = false,
    UndoType undoType = UndoType.normal,
  }) {
    if (list == null || isNullOrEmpty(list)) {
      assert(() {
        l.w('无效的操作');
        return true;
      }());
      return;
    }
    if (offset != null) {
      for (final element in list) {
        element.translateElement(
            Matrix4.identity()..translate(offset.dx, offset.dy));
      }
    }

    final old = elements.clone();
    elements.addAll(list);
    for (final element in list) {
      element.attachToCanvasDelegate(canvasDelegate);
    }
    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, list, undoType);
    canvasDelegate.dispatchCanvasElementListAddChanged(elements, list);

    if (selected) {
      resetSelectElement(list);
      if (followPainter) {
        canvasDelegate.followPainter(elementPainter: selectComponent);
      }
    } else if (followPainter) {
      ElementGroupPainter painter = ElementGroupPainter();
      painter.resetChildren(
          list, canvasElementControlManager.enableResetElementAngle);
      canvasDelegate.followPainter(elementPainter: painter);
    }

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          canvasElementControlManager.onCanvasElementDeleted(list);
          for (final element in list) {
            element.detachFromCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, list, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          for (final element in list) {
            element.attachToCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, list, UndoType.redo);
        },
      ));
    }
  }

  /// 删除所有元素
  @supportUndo
  @api
  void removeAllElement({UndoType undoType = UndoType.normal}) {
    removeElementList(elements.clone(), undoType: undoType);
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
    //final op = elements.removeAll(list);
    final op = removeElementListFromTop(list)!;

    //删除选中的元素
    canvasElementControlManager.onCanvasElementDeleted(op);
    for (final element in op) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, op, undoType);
    canvasDelegate.dispatchCanvasElementListRemoveChanged(elements, op);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          for (final element in op) {
            element.attachToCanvasDelegate(canvasDelegate);
          }
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasElementControlManager.onCanvasElementDeleted(op);
          for (final element in op) {
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
  void resetElementList(
    List<ElementPainter>? list, {
    bool selected = false,
    bool showRect = false,
    UndoType undoType = UndoType.normal,
  }) {
    list ??= [];
    final old = elements.clone();
    final op = list.clone();
    _resetElementList(old, op);
    canvasDelegate.dispatchCanvasElementListChanged(old, op, op, undoType);

    if (selected) {
      resetSelectElement(list);
      if (showRect) {
        canvasDelegate.followPainter(elementPainter: selectComponent);
      }
    } else if (showRect) {
      ElementGroupPainter painter = ElementGroupPainter();
      painter.resetChildren(
          list, canvasElementControlManager.enableResetElementAngle);
      canvasDelegate.followPainter(elementPainter: painter);
    }

    if (undoType == UndoType.normal) {
      final newList = op;
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
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
    for (final element in from) {
      element.detachFromCanvasDelegate(canvasDelegate);
    }
    elements.reset(to);
    for (final element in to) {
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
    for (final element in elements) {
      if ((!checkLockOperate || !element.paintState.isLockOperate) &&
          element.hitTest(point: point, rect: rect, path: path)) {
        result.add(element);
      }
    }
    return result;
  }

  //endregion ---element操作---

  //region ---select---

  /// 选中指定元素
  @api
  void selectElement(
    ElementPainter? element, {
    bool showRect = true,
  }) {
    resetSelectElement(element == null ? [] : [element]);
    if (showRect) {
      canvasDelegate.followPainter(elementPainter: element);
    }
  }

  /// 选中所有元素
  @api
  void selectAllElement({
    bool showRect = true,
  }) {
    resetSelectElement(elements);
    if (showRect) {
      canvasDelegate.followRect(rect: elements.allElementBounds);
    }
  }

  /// 添加一个选中的元素
  @api
  void addSelectElement(ElementPainter element) {
    final list = selectComponent.children ?? [];
    list.add(element);
    selectComponent.resetSelectElement(list);
  }

  /// 添加一组选中的元素
  @api
  void addSelectElementList(List<ElementPainter> elements) {
    final list = selectComponent.children ?? [];
    list.addAll(elements);
    selectComponent.resetSelectElement(list);
  }

  /// 移除一个选中的元素
  @api
  void removeSelectElement(ElementPainter element) {
    final list = selectComponent.children ?? [];
    if (list.remove(element)) {
      selectComponent.resetSelectElement(list);
    }
  }

  /// 移除一组选中的元素
  @api
  void removeSelectElementList(List<ElementPainter> elements) {
    final list = selectComponent.children ?? [];
    list.removeAll(elements);
    selectComponent.resetSelectElement(list);
  }

  /// 重置选中的元素
  @api
  void resetSelectElement(List<ElementPainter>? elements) {
    selectComponent.resetSelectElement(elements);
  }

  /// 清空选中的元素
  @api
  void clearSelectedElement() {
    resetSelectElement(null);
  }

  /// 如果操作的元素被选中, 则清空所有选中的元素
  @api
  void clearSelectedElementIf(ElementPainter? element) {
    if (element != null &&
        selectComponent.children?.contains(element) == true) {
      clearSelectedElement();
    }
  }

  /// 获取所有选中的元素, 默认包含[ElementGroupPainter]
  /// [exportSingleElement] 是否只返回仅[ElementPainter]类型的元素列表, 拆开了[ElementGroupPainter]
  /// [exportAllElementIfNoSelected] 如果没有选中元素, 是否返回所有元素
  /// [getAllElement]
  /// [getAllSelectedElement]
  @api
  List<ElementPainter>? getAllSelectedElement({
    bool exportSingleElement = false,
    bool exportAllElementIfNoSelected = false,
  }) {
    if (isSelectedElement) {
      final selectComponent = this.selectComponent;
      if (exportSingleElement) {
        return selectComponent.getSingleElementList();
      }
      return selectComponent.children;
    } else if (exportAllElementIfNoSelected) {
      return getAllElement(exportSingleElement: exportSingleElement);
    }
    return null;
  }

  /// [getAllElement]
  /// [getAllSelectedElement]
  @api
  List<ElementPainter>? getAllElement({
    bool exportSingleElement = false,
  }) {
    if (exportSingleElement) {
      final result = <ElementPainter>[];
      for (final element in elements) {
        result.addAll(element.getSingleElementList());
      }
      return result;
    }
    return selectComponent.children;
  }

  /// 是否选中了元素
  @api
  bool isElementSelected(ElementPainter? element) {
    return selectComponent.containsElement(element);
  }

  /// 更新选择元素的边界, 通常在操作子元素绘制属性发生改变后调用
  /// [ElementSelectComponent]
  @api
  void updateSelectComponentPaintProperty() {
    selectComponent.updatePaintPropertyFromChildren(
      canvasElementControlManager.enableResetElementAngle,
    );
  }

  //endregion ---select---

  //region ---operate/api---

  /// 查找指定元素对应的父元素, 如果有
  ElementGroupPainter? findElementGroupPainter(ElementPainter? element) =>
      findElementGroupPainterInChildren(element, elements);

  /// [findElementGroupPainter]
  ElementGroupPainter? findElementGroupPainterInChildren(
      ElementPainter? element, List<ElementPainter>? children) {
    for (final e in children ?? []) {
      if (e is ElementGroupPainter) {
        if (e.children?.contains(element) == true) {
          return e;
        }
        return findElementGroupPainterInChildren(element, e.children);
      }
    }
    return null;
  }

  /// 查找指定元素对应的顶层元素
  ElementPainter? findTopElementPainter(ElementPainter? element) {
    for (final e in elements) {
      if (e == element) {
        return e;
      }
      if (e.getSingleElementList().contains(element)) {
        return e;
      }
    }
    return element;
  }

  /// 从[elements]顶层中, 移除指定的元素列表
  /// 如果移除的是[ElementGroupPainter]内部的子元素, 那么顶层的[ElementGroupPainter]也会被移除
  ///
  /// 此方法不支持undo操作, 请使用[removeElementList]
  @api
  List<ElementPainter>? removeElementListFromTop(List<ElementPainter>? list) {
    if (list == null || isNullOrEmpty(list)) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return null;
    }
    final removeList = <ElementPainter>[];
    for (final element in list) {
      final top = findTopElementPainter(element);
      if (top != null) {
        removeList.add(top);
      }
    }
    //remove
    return elements.removeAll(removeList);
  }

  /// 替换元素, 一个元素替换一个元素
  /// [oldElement] 需要被替换的旧元素
  /// [newElement] 新元素
  /// [keepIndex] 是否保持原来的索引位置
  ///
  /// [replaceElementList]
  @api
  @supportUndo
  void replaceElement(
    ElementPainter? oldElement,
    ElementPainter? newElement, {
    UndoType undoType = UndoType.normal,
    bool keepIndex = false,
  }) {
    if (oldElement == null && newElement == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }

    final List<ElementPainter> oldElementList;
    if (oldElement is ElementSelectComponent) {
      oldElementList = oldElement.children ?? [];
    } else {
      oldElementList = oldElement == null ? [] : [oldElement];
    }

    final List<ElementPainter> newElementList =
        newElement == null ? [] : [newElement];

    replaceElementList(
      oldElementList,
      newElementList,
      keepIndex: keepIndex,
      undoType: undoType,
    );
  }

  /// 一组元素替换一组元素
  /// [keepIndex] 只能记录第一个元素的位置
  @api
  @supportUndo
  void replaceElementList(
    List<ElementPainter>? oldElementList,
    List<ElementPainter>? newElementList, {
    UndoType undoType = UndoType.normal,
    bool keepIndex = false,
  }) {
    if (isNullOrEmpty(oldElementList) && isNullOrEmpty(newElementList)) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }

    final oldFirstElement = oldElementList?.first;

    final old = elements.clone();
    final index = (keepIndex && oldFirstElement != null)
        ? elements.indexOf(oldFirstElement)
        : -1;

    //elements.removeAll(oldElementList ?? []);
    removeElementListFromTop(oldElementList);
    if (index >= 0 && newElementList != null) {
      elements.insertAll(index, newElementList);
    } else {
      if (newElementList != null) {
        elements.addAll(newElementList);
      }
    }

    oldElementList?.forEach((element) {
      element.detachFromCanvasDelegate(canvasDelegate);
    });
    newElementList?.forEach((element) {
      element.attachToCanvasDelegate(canvasDelegate);
    });

    final List<ElementPainter> op = newElementList ?? [];
    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, op, undoType);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          newElementList?.forEach((element) {
            element.detachFromCanvasDelegate(canvasDelegate);
          });
          oldElementList?.forEach((element) {
            element.attachToCanvasDelegate(canvasDelegate);
          });
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          oldElementList?.forEach((element) {
            element.detachFromCanvasDelegate(canvasDelegate);
          });
          newElementList?.forEach((element) {
            element.attachToCanvasDelegate(canvasDelegate);
          });
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, op, UndoType.redo);
        },
      ));
    }

    //选中组合元素
    if (!isNullOrEmpty(op)) {
      resetSelectElement(op);
    }
  }

  /// 组合元素
  @api
  @supportUndo
  void groupElement(List<ElementPainter>? elements,
      {UndoType undoType = UndoType.normal}) {
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

    //事件
    canvasDelegate.dispatchCanvasGroupChanged(group, elements);

    //重置元素列表
    resetElementList(newList, undoType: undoType);

    //选中组合元素
    resetSelectElement([group]);
  }

  /// 解组元素
  @api
  @supportUndo
  void ungroupElement(ElementPainter? group,
      {UndoType undoType = UndoType.normal}) {
    if (group == null || group is! ElementGroupPainter) {
      assert(() {
        l.d('不是[ElementGroupPainter]元素,不能解组');
        return true;
      }());
      return;
    }

    final children = group.children;
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

    for (final element in children) {
      element.onSelfElementUnGroupFrom(group);
    }
    //这里不能使用resetChildren, 应为回退栈的时候, 会无法还原子元素
    //group.resetChildren(null, false);

    //事件
    canvasDelegate.dispatchCanvasUngroupChanged(group);

    //重置元素列表
    resetElementList(newList, undoType: undoType);

    //选中组合元素
    resetSelectElement(children);
  }

  /// 对齐组内元素
  @api
  @supportUndo
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
    for (final element in children) {
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
    updateSelectComponentPaintProperty();
  }

  /// 均分组内元素
  /// [useCenterAverage] 是否使用中心点进行均分分布, 否则使用元素之间的等距进行均分分布
  @api
  @supportUndo
  void averageElement(
    ElementGroupPainter? group,
    CanvasAverageType average, {
    UndoType undoType = UndoType.normal,
    bool useCenterAverage = false,
  }) {
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

      final undoState = group.createStateStack();
      final list = children.sortElement(
        resetElementAngle: canvasElementControlManager.enableResetElementAngle,
        leftTop: average == CanvasAverageType.horizontal,
      );
      final first = list.first;
      final last = list.last;
      final firstBounds = first.paintProperty
          ?.getBounds(canvasElementControlManager.enableResetElementAngle);
      final lastBounds = last.paintProperty
          ?.getBounds(canvasElementControlManager.enableResetElementAngle);

      if (firstBounds == null || lastBounds == null) {
        assert(() {
          l.d('获取不到元素的边界');
          return true;
        }());
        return;
      }

      if (useCenterAverage) {
        //中心点均匀分布, 元素中心点之间的距离保持等距

        //首尾中心点之间的距离
        final centerMiddleSpace = average == CanvasAverageType.horizontal
            ? lastBounds.center.dx - firstBounds.center.dx
            : lastBounds.center.dy - firstBounds.center.dy;

        //每个元素中点之间的距离
        final space = centerMiddleSpace / (children.length - 1);

        double position = 0.0;
        for (final element in list) {
          final bounds = element.paintProperty
              ?.getBounds(canvasElementControlManager.enableResetElementAngle);
          if (element == first) {
            if (average == CanvasAverageType.horizontal) {
              position = bounds?.center.dx ?? 0;
            } else {
              position = bounds?.center.dy ?? 0;
            }
            continue;
          }
          if (element == last) {
            break;
          }
          if (bounds != null) {
            if (average == CanvasAverageType.horizontal) {
              final newCenter = position + space;
              final dx = newCenter - bounds.center.dx;
              element.translateElement(Matrix4.identity()..translate(dx, 0.0));
              position += space;
            } else {
              final newCenter = position + space;
              final dy = newCenter - bounds.center.dy;
              element.translateElement(Matrix4.identity()..translate(0.0, dy));
              position += space;
            }
          }
        }
      } else {
        //所有元素的大小, 排除首尾元素
        final childrenSize = list.fold(0.0, (value, element) {
          if (element == first || element == last) {
            return value;
          }
          final bounds = element.paintProperty
              ?.getBounds(canvasElementControlManager.enableResetElementAngle);
          return value +
              (average == CanvasAverageType.horizontal
                  ? bounds?.width ?? 0
                  : bounds?.height ?? 0);
        });

        //去掉首尾元素, 计算可用的空间大小
        final totalSpace = average == CanvasAverageType.horizontal
            ? lastBounds.left - firstBounds.right
            : lastBounds.top - firstBounds.bottom;

        //去掉中间元素的大小, 计算剩余的空间大小
        final middleSpace = totalSpace - childrenSize;

        //计算每个元素与上一个元素之间的间隔
        final space = middleSpace / (children.length - 1);

        double position = 0.0;
        for (final element in list) {
          final bounds = element.paintProperty
              ?.getBounds(canvasElementControlManager.enableResetElementAngle);
          if (element == first) {
            if (average == CanvasAverageType.horizontal) {
              position = bounds?.right ?? 0;
            } else {
              position = bounds?.bottom ?? 0;
            }
            continue;
          }
          if (element == last) {
            break;
          }
          if (bounds != null) {
            if (average == CanvasAverageType.horizontal) {
              final newLeft = position + space;
              final dx = newLeft - bounds.left;
              element.translateElement(Matrix4.identity()..translate(dx, 0.0));
              position += space + bounds.width;
            } else {
              final newTop = position + space;
              final dy = newTop - bounds.top;
              element.translateElement(Matrix4.identity()..translate(0.0, dy));
              position += space + bounds.height;
            }
          }
        }
      }

      if (undoType == UndoType.normal) {
        final redoState = group.createStateStack();
        canvasDelegate.canvasUndoManager.addUntoState(undoState, redoState);
      }

      //更新选择元素的边界
      updateSelectComponentPaintProperty();
    } else {
      //等宽高, 所有元素的大小, 参考左上的元素

      //先获取左上角的元素
      final anchorElement = children
          .sortElement(
            resetElementAngle:
                canvasElementControlManager.enableResetElementAngle,
            leftTop: true,
          )
          .first;
      final anchorBounds = anchorElement.paintProperty
          ?.getBounds(canvasElementControlManager.enableResetElementAngle);

      if (anchorBounds == null) {
        assert(() {
          l.d('获取不到元素的边界');
          return true;
        }());
        return;
      }

      final undoState = group.createStateStack();
      for (final element in children) {
        if (element == anchorElement) {
          continue;
        }
        final elementBounds = element.paintProperty
            ?.getBounds(canvasElementControlManager.enableResetElementAngle);
        if (elementBounds != null) {
          switch (average) {
            case CanvasAverageType.width:
              final sx = anchorBounds.width / elementBounds.width;
              element.scaleElement(sx: sx);
              break;
            case CanvasAverageType.height:
              final sy = anchorBounds.height / elementBounds.height;
              element.scaleElement(sy: sy);
              break;
            case CanvasAverageType.size:
              final sx = anchorBounds.width / elementBounds.width;
              final sy = anchorBounds.height / elementBounds.height;
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
      updateSelectComponentPaintProperty();
    }
  }

  /// 是否可以按照指定的方式排列元素
  @api
  bool canArrangeElement(dynamic element, CanvasArrangeType arrange) {
    final targetElement = element is ElementSelectComponent
        ? element.children?.first
        : element is ElementPainter
            ? element
            : null;
    if (targetElement == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return false;
    }
    final index = elements.indexOf(targetElement);
    final size = elements.length;
    switch (arrange) {
      case CanvasArrangeType.up || CanvasArrangeType.top:
        return index < size - 1;
      case CanvasArrangeType.down || CanvasArrangeType.bottom:
        return index > 0;
    }
  }

  /// 排列元素
  @api
  @supportUndo
  void arrangeElement(
    ElementPainter? element,
    CanvasArrangeType arrange, {
    UndoType undoType = UndoType.normal,
  }) {
    if (element == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    arrangeElementList(
        element is ElementSelectComponent ? element.children : element.ofList(),
        arrange,
        undoType: undoType);
  }

  /// 排列元素
  @api
  @supportUndo
  void arrangeElementList(
    List<ElementPainter>? elementList,
    CanvasArrangeType arrange, {
    UndoType undoType = UndoType.normal,
  }) {
    if (isNil(elementList)) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }

    final first = elementList!.first;
    final index = elements.indexOf(first);

    if (index < 0) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }

    //debugger();
    final old = elements.clone();
    elements.removeAll(elementList);
    switch (arrange) {
      case CanvasArrangeType.up:
        elements.insertAll(min(index + 1, elements.length), elementList);
        break;
      case CanvasArrangeType.down:
        elements.insertAll(max(index - 1, 0), elementList);
        break;
      case CanvasArrangeType.top:
        elements.addAll(elementList);
        break;
      case CanvasArrangeType.bottom:
        elements.insertAll(0, elementList);
        break;
    }

    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, elementList, undoType);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, elementList, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, elementList, UndoType.redo);
        },
      ));
    }
  }

  /// 简单的更新重置所有元素, 适用于外界已经排好序之后, 触发更新
  @api
  @supportUndo
  void singleUpdateElementList(
    List<ElementPainter>? elementList, {
    UndoType undoType = UndoType.normal,
  }) {
    final old = elements.clone();
    final op = elementList ?? [];
    elements.reset(op);
    canvasDelegate.dispatchCanvasElementListChanged(
        old, elements, op, undoType);
    //undo
    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          canvasDelegate.dispatchCanvasElementListChanged(
              newList, old, op, UndoType.undo);
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasDelegate.dispatchCanvasElementListChanged(
              old, newList, op, UndoType.redo);
        },
      ));
    }
  }

  /// 复制元素
  @api
  @supportUndo
  void copyElement(ElementPainter? element,
      {@dp Offset? offset,
      bool selected = true,
      bool showRect = true,
      UndoType undoType = UndoType.normal}) {
    if (element == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    if (element is ElementSelectComponent) {
      copyElementList(element.children,
          offset: offset,
          selected: selected,
          showRect: showRect,
          undoType: undoType);
    } else {
      copyElementList(element.ofList(),
          offset: offset,
          selected: selected,
          showRect: showRect,
          undoType: undoType);
    }
  }

  /// 复制元素
  @api
  @supportUndo
  void copyElementList(
    List<ElementPainter>? elementList, {
    @dp Offset? offset,
    bool selected = true,
    bool showRect = true,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementList == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return;
    }
    final newElementList = <ElementPainter>[];
    for (final element in elementList) {
      final newElement = element.copyElement();
      newElementList.add(newElement);
    }
    addElementList(
      newElementList,
      offset: offset,
      selected: selected,
      followPainter: showRect,
      undoType: undoType,
    );
  }

  //endregion ---operate/api---

  @override
  String toStringShort() => buildString((builder) {
        builder
          ..addText(isSelectedElement
              ? "选中[${elementSelectComponent?.children?.length}个元素 "
              : "")
          ..addText(
              "[${beforeElements.length}][${elements.length}][${afterElements.length}]");
      });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(ElementDiagnosticsNode(beforeElements).toDiagnosticsNode(
        name: 'beforeElements', style: DiagnosticsTreeStyle.sparse));
    properties.add(ElementDiagnosticsNode(elements).toDiagnosticsNode(
        name: 'elements', style: DiagnosticsTreeStyle.whitespace));
    properties.add(ElementDiagnosticsNode(afterElements).toDiagnosticsNode(
        name: 'afterElements', style: DiagnosticsTreeStyle.dense));
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

  ///在水平方向上居中对齐
  horizontalCenter,

  ///在垂直方向上居中对齐
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

/// 排列元素
enum CanvasArrangeType {
  /// 上移一层->[top]
  up,

  /// 下移一层->[bottom]
  down,

  /// 置为顶层[topMost]
  top,

  /// 置为底层[bottomMost]
  bottom,
}
