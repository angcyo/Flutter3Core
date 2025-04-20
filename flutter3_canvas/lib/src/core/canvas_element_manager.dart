part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 元素管理, 包含元素的绘制, 选择, 添加/删除等相关操作
///
/// [CanvasDelegate] 的成员
///
class CanvasElementManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  //region ---属性----

  final CanvasDelegate canvasDelegate;

  /// 元素控制管理, 核心成员
  late CanvasElementControlManager canvasElementControlManager =
      CanvasElementControlManager(this);

  //---get---

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  /// 元素选择组件
  /// 选择框绘制, 选中元素操作, 按下选择元素
  /// [ElementSelectComponent]
  ElementSelectComponent get selectComponent =>
      canvasElementControlManager.elementSelectComponent;

  /// 选择元素的组件, 未选中元素时, 返回null
  ElementSelectComponent? get elementSelectComponent =>
      isSelectedElement ? selectComponent : null;

  /// 选中的元素, 如果是单元素, 则返回选中的元素, 否则返回[ElementSelectComponent]
  /// 没有选中元素时, 返回null
  ///
  /// 可以通过此对象来判断选中的是什么元素类型
  /// ```
  /// final isNone = selectedElement == null;
  /// final isText = selectedElement is TextElementPainter;
  /// final isImage = selectedElement is ImageElementPainter;
  /// final isGroup = selectedElement is ElementSelectComponent;
  /// ```
  /// @return
  /// - [ElementPainter]
  /// - [ElementSelectComponent]
  ElementPainter? get selectedElement {
    if (!isSelectedElement) {
      return null;
    }
    return elementSelectComponent?.selectedChildElement;
  }

  //--

  /// 选中的顶级元素列表
  List<ElementPainter>? get selectedElementList => selectComponent.children;

  /// 选中的简单元素列表, 不包含[ElementGroupPainter]
  List<ElementPainter>? get selectedSingleElementList =>
      selectedElementList?.getAllSingleElement();

  //--

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
  /// 请勿直接赋值此对象, 因为会影响[CanvasStateData.elements]的数据
  /// [paintElements]中绘制
  ///
  /// [resetElements]重试所有元素
  ///
  List<ElementPainter> elements = [];

  /// 绘制在[elements]之后的元素列表, 不参与控制操作
  /// [paintElements]
  final List<ElementPainter> afterElements = [];

  //--元素get--

  List<ElementPainter> get allSingleElements {
    final result = <ElementPainter>[];
    for (final element in elements) {
      result.addAll(element.getSingleElementList());
    }
    return result;
  }

  /// 获取包裹所有元素[elements]的边界
  Rect? get allElementsBounds {
    final list = elements;
    if (isNullOrEmpty(list)) {
      return null;
    }
    final group = ElementGroupPainter();
    group.resetChildren(list);
    final bounds = group.paintProperty
        ?.getBounds(canvasElementControlManager.enableResetElementAngle);
    if (isNil(bounds)) {
      return null;
    }
    return bounds;
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
      //--元素绘制入口
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
      //--控制绘制, 在元素最上层绘制, 所以可以实现选中元素在顶层绘制
      canvasElementControlManager.paint(canvas, paintMeta);
      //--绘制菜单
      if (canvasElementControlManager.elementMenuControl
          .needHandleElementMenu()) {
        canvasElementControlManager.elementMenuControl
            .paintMenu(canvas, paintMeta);
      }
      //--绘制吸附提示线
      if (canvasElementControlManager
          .elementAdsorbControl.isCanvasComponentEnable) {
        canvasElementControlManager.elementAdsorbControl
            .paintAdsorb(canvas, paintMeta);
      }
      //--绘制覆盖层
      canvasDelegate._overlayComponent?.painting(canvas, paintMeta);
    });
    //在下面此处绘制可以在坐标轴上↓
    //paint
  }

  /// 绘制元素
  /// [paintElements]驱动
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
  /// [event] 最原始的事件参数, 未经过加工处理
  /// 由[CanvasEventManager.handleEvent]驱动
  @entryPoint
  void handleElementEvent(@viewCoordinate PointerEvent event) {
    canvasElementControlManager.handleEvent(event);

    //元素事件
    if (canvasElementControlManager.enableElementControl ||
        canvasStyle.enableElementEvent == true) {
      //将事件发送元素
      for (final element in elements.reversed) {
        if (element.handleEvent(event)) {
          break;
        }
      }
    }
    //画布菜单
    if (canvasElementControlManager.enableElementControl ||
        canvasStyle.enableCanvasMenu == true) {
      if (event.isMouseRightUp) {
        //鼠标右键点击, 显示菜单
        final menus = canvasDelegate.canvasMenuManager.buildMenus(
          anchorPosition: event.localPosition,
        );
        if (!isNil(menus)) {
          canvasDelegate.showMenus(menus, position: event.localPosition);
        } else {
          final menu = canvasDelegate.canvasMenuManager.buildMenuWidget(
            anchorPosition: event.localPosition,
          );
          if (!isNil(menu)) {
            canvasDelegate.showWidgetMenu(menu!, position: event.localPosition);
          }
        }
      }
    }
  }

  /// 释放资源
  @entryPoint
  void release() {
    detachElementToCanvasDelegate(beforeElements);
    detachElementToCanvasDelegate(elements);
    detachElementToCanvasDelegate(afterElements);
  }

  //endregion ---entryPoint----

  //region ---element操作---

  /// 访问所有元素
  /// [beforeElements]
  /// [elements]
  /// [afterElements]
  ///
  /// [reverse] 是否逆序
  @api
  void visitElementPainter(
    ElementPainterVisitor visitor, {
    bool reverse = false,
    //--
    bool before = true,
    bool that = true,
    bool after = true,
  }) {
    if (reverse) {
      //倒序
      if (after) {
        for (final element in afterElements.reversed) {
          visitor(element);
        }
      }
      if (that) {
        for (final element in elements.reversed) {
          visitor(element);
        }
      }
      if (before) {
        for (final element in beforeElements.reversed) {
          visitor(element);
        }
      }
    } else {
      //正序
      if (before) {
        for (final element in beforeElements) {
          visitor(element);
        }
      }
      if (that) {
        for (final element in elements) {
          visitor(element);
        }
      }
      if (after) {
        for (final element in afterElements) {
          visitor(element);
        }
      }
    }
  }

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

  /// [detachElementToCanvasDelegate]
  void attachElementToCanvasDelegate(List<ElementPainter>? elements) {
    for (final element in elements ?? []) {
      if (element.canvasDelegate != canvasDelegate) {
        element.attachToCanvasDelegate(canvasDelegate);
      }
    }
  }

  /// [attachElementToCanvasDelegate]
  void detachElementToCanvasDelegate(List<ElementPainter>? elements) {
    for (final element in elements ?? []) {
      if (element.canvasDelegate == canvasDelegate) {
        element.detachFromCanvasDelegate(canvasDelegate);
      }
    }
  }

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

  /// 重置[elements]元素,
  /// - 支持多画布[CanvasMultiManager]
  /// - 支持撤销/回退
  /// [CanvasStateData]
  @api
  @supportUndo
  void resetElements(
    List<ElementPainter> newElements, {
    bool selected = false,
    bool followPainter = false,
    bool followContent = false,
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    final oldElements = elements;
    elements = newElements;
    canvasDelegate.canvasMultiManager.selectedCanvasState?.elements = elements;

    attachElementToCanvasDelegate(newElements);
    canvasElementControlManager.onCanvasElementDeleted(oldElements, selectType);
    canvasDelegate.dispatchCanvasElementListChanged(
      oldElements,
      newElements,
      newElements,
      ElementChangeType.add,
      undoType,
      selectType: selectType,
    );
    canvasDelegate.dispatchCanvasElementListRemoveChanged(
        elements, oldElements);
    canvasDelegate.dispatchCanvasElementListAddChanged(elements, newElements);

    selectedOrFollowElements(
      newElements,
      selected: selected,
      followPainter: followPainter,
      followContent: followContent,
      selectType: selectType,
    );

    if (undoType == UndoType.normal) {
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements = oldElements;
          canvasDelegate.canvasMultiManager.selectedCanvasState?.elements =
              elements;
          canvasElementControlManager.onCanvasElementDeleted(
              newElements, selectType);
          detachElementToCanvasDelegate(newElements);
          attachElementToCanvasDelegate(oldElements);
          canvasDelegate.dispatchCanvasElementListChanged(
            newElements,
            oldElements,
            oldElements,
            ElementChangeType.update,
            UndoType.undo,
            selectType: selectType,
          );
        },
        () {
          //debugger();
          elements = newElements;
          canvasDelegate.canvasMultiManager.selectedCanvasState?.elements =
              elements;
          canvasElementControlManager.onCanvasElementDeleted(
              oldElements, selectType);
          detachElementToCanvasDelegate(oldElements);
          attachElementToCanvasDelegate(newElements);
          canvasDelegate.dispatchCanvasElementListChanged(
            oldElements,
            newElements,
            newElements,
            ElementChangeType.update,
            UndoType.redo,
            selectType: selectType,
          );
        },
      ));
    }
  }

  /// 添加元素
  /// [element] 要添加的元素
  /// [selected] 是否选中对应元素
  /// [followPainter] 是否显示元素的边界
  /// [followContent] 是否显示画布内容的边界(优先)
  @api
  @supportUndo
  void addElement(
    ElementPainter? element, {
    @dp Offset? offset,
    bool selected = false,
    bool followPainter = false,
    bool followContent = false,
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
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
      followContent: followContent,
      undoType: undoType,
      selectType: selectType,
    );
  }

  /// 添加一组元素
  /// [list] 要添加的一组元素
  /// [selected] 添加完成后,是否选中
  /// [offset] 所有元素的偏移量
  /// [followPainter] 移动元素到画布中心
  /// [followContent] 是否显示画布内容的边界(优先)
  @api
  @supportUndo
  void addElementList(
    List<ElementPainter>? list, {
    @dp Offset? offset,
    bool selected = false,
    bool followPainter = false,
    bool followContent = false,
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
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
    attachElementToCanvasDelegate(list);
    canvasDelegate.dispatchCanvasElementListChanged(
      old,
      elements,
      list,
      ElementChangeType.add,
      undoType,
      selectType: selectType,
    );
    canvasDelegate.dispatchCanvasElementListAddChanged(elements, list);

    selectedOrFollowElements(
      list,
      selected: selected,
      followPainter: followPainter,
      followContent: followContent,
      selectType: selectType,
    );

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          canvasElementControlManager.onCanvasElementDeleted(list, selectType);
          detachElementToCanvasDelegate(list);
          canvasDelegate.dispatchCanvasElementListChanged(
            newList,
            old,
            list,
            ElementChangeType.update,
            UndoType.undo,
            selectType: selectType,
          );
        },
        () {
          //debugger();
          elements.reset(newList);
          attachElementToCanvasDelegate(list);
          canvasDelegate.dispatchCanvasElementListChanged(
            old,
            newList,
            list,
            ElementChangeType.update,
            UndoType.redo,
            selectType: selectType,
          );
        },
      ));
    }
  }

  /// 选中或者跟随元素
  @api
  void selectedOrFollowElements(
    List<ElementPainter> elements, {
    bool selected = false,
    bool followPainter = false,
    bool followContent = false,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (selected) {
      resetSelectedElementList(elements, selectType: selectType);
      if (followContent) {
        if (canvasDelegate.canvasContentManager.followCanvasContentTemplate()) {
          //跟随内容成功之后, 不需要降级跟随元素, 否则降级处理
          followPainter = false;
        }
      }
      if (followPainter) {
        canvasDelegate.followPainter(elementPainter: selectComponent);
      }
    } else {
      if (followContent) {
        if (canvasDelegate.canvasContentManager.followCanvasContentTemplate()) {
          //跟随内容成功之后, 不需要降级跟随元素, 否则降级处理
          followPainter = false;
        }
      }
      if (followPainter) {
        ElementGroupPainter painter = ElementGroupPainter();
        painter.resetChildren(elements);
        canvasDelegate.followPainter(elementPainter: painter);
      }
    }
  }

  /// 删除所有元素
  @api
  @supportUndo
  void removeAllElement({UndoType undoType = UndoType.normal}) {
    removeElementList(elements.clone(), undoType: undoType);
  }

  /// 删除元素
  @api
  @supportUndo
  void removeElement(ElementPainter element,
      {UndoType undoType = UndoType.normal}) {
    removeElementList(element.ofList(), undoType: undoType);
  }

  /// 删除一组元素, 此方法不支持删除组内[ElementGroupPainter]单个元素
  /// 如果删除的元素在组内, 那么整组一起删除
  ///
  /// [CanvasDelegate.removeElementList]支持删除组内元素
  @api
  @supportUndo
  bool removeElementList(
    List<ElementPainter>? list, {
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (list == null || isNullOrEmpty(list)) {
      return false;
    }
    final old = elements.clone();
    //final op = elements.removeAll(list);
    final op = removeElementListFromTop(list)!;

    //删除选中的元素
    canvasElementControlManager.onCanvasElementDeleted(op, selectType);
    detachElementToCanvasDelegate(op);
    canvasDelegate.dispatchCanvasElementListChanged(
      old,
      elements,
      op,
      ElementChangeType.remove,
      undoType,
    );
    canvasDelegate.dispatchCanvasElementListRemoveChanged(elements, op);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          attachElementToCanvasDelegate(op);
          canvasDelegate.dispatchCanvasElementListChanged(
            newList,
            old,
            op,
            ElementChangeType.update,
            UndoType.undo,
          );
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasElementControlManager.onCanvasElementDeleted(op, selectType);
          detachElementToCanvasDelegate(op);
          canvasDelegate.dispatchCanvasElementListChanged(
            old,
            newList,
            op,
            ElementChangeType.update,
            UndoType.redo,
          );
        },
      ));
    }
    return true;
  }

  /// 重置元素列表
  @api
  @supportUndo
  void resetElementList(
    List<ElementPainter>? list, {
    bool selected = false,
    bool followElement = false,
    BoxFit? fit = BoxFit.none,
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    list ??= [];
    final old = elements.clone();
    final op = list.clone();
    _resetElementList(old, op);

    canvasElementControlManager.onCanvasElementDeleted(old, selectType);
    canvasDelegate.dispatchCanvasElementListChanged(
      old,
      op,
      op,
      ElementChangeType.update,
      undoType,
    );
    canvasDelegate.dispatchCanvasElementListRemoveChanged(elements, old);
    canvasDelegate.dispatchCanvasElementListAddChanged(elements, op);

    if (selected) {
      resetSelectedElementList(list, selectType: selectType);
      if (followElement) {
        canvasDelegate.followPainter(elementPainter: selectComponent, fit: fit);
      }
    } else if (followElement) {
      if (!isNil(list)) {
        ElementGroupPainter painter = ElementGroupPainter();
        painter.resetChildren(list);
        canvasDelegate.followPainter(elementPainter: painter, fit: fit);
      }
    }

    if (undoType == UndoType.normal) {
      final newList = op;
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          _resetElementList(newList, old);
          canvasDelegate.dispatchCanvasElementListChanged(
            newList,
            old,
            op,
            ElementChangeType.update,
            UndoType.undo,
          );
        },
        () {
          //debugger();
          _resetElementList(old, newList);
          canvasDelegate.dispatchCanvasElementListChanged(
            old,
            newList,
            op,
            ElementChangeType.update,
            UndoType.redo,
          );
        },
      ));
    }
  }

  void _resetElementList(List<ElementPainter> from, List<ElementPainter> to) {
    detachElementToCanvasDelegate(from);
    elements.reset(to);
    attachElementToCanvasDelegate(to);
  }

  /// 清空元素
  @api
  @supportUndo
  void clearElements([UndoType undoType = UndoType.normal]) {
    removeElementList(elements.clone(), undoType: undoType);
  }

  /// 根据一个事件,查找元素对应的元素, 从上往下查找, 找到后就返回
  ElementPainter? findElementByEvent({
    @viewCoordinate PointerEvent? event,
    @viewCoordinate Offset? position,
    //--
    bool includeSelectComponent = true,
  }) {
    position ??= event?.localPosition;
    if (position == null) {
      return null;
    }
    @sceneCoordinate
    final offset = canvasDelegate.canvasViewBox.toScenePoint(position);
    return findElement(
      point: offset,
      reverse: true,
      includeSelectComponent: true,
      breakWhenFind: true,
    ).firstOrNull;
  }

  /// 查找元素, 按照元素的先添加先返回的顺序
  /// [checkLockOperate] 是否检查锁定操作
  /// [checkVisible] 是否检查是否可见
  /// [includeSelectComponent] 是否包含选择组件
  /// [ignoreElements] 忽略的元素集合
  /// [reverse] 是否倒序查找元素
  /// [breakWhenFind] 是否中断查找
  @api
  List<ElementPainter> findElement({
    @sceneCoordinate Offset? point,
    @sceneCoordinate Rect? rect,
    @sceneCoordinate Path? path,
    //--
    bool checkLockOperate = true,
    bool checkVisible = true,
    bool includeSelectComponent = false,
    List<ElementPainter>? ignoreElements,
    //--
    bool reverse = false,
    //查找到之后, 是否中断
    bool breakWhenFind = false,
  }) {
    final result = <ElementPainter>[];
    if (includeSelectComponent) {
      if (selectComponent.isSelectedElement) {
        if (selectComponent.hitTest(point: point, rect: rect, path: path)) {
          result.add(selectComponent);
          if (breakWhenFind) {
            return result;
          }
        }
      }
    }
    //--
    for (final element in reverse ? elements.reversed : elements) {
      if (ignoreElements?.contains(element) == true) {
        continue;
      }
      if (checkVisible && !element.isVisible) {
        //元素不可见
        continue;
      }
      if (checkLockOperate && element.isLockOperate) {
        //元素被锁定
        continue;
      }
      if (element.hitTest(point: point, rect: rect, path: path)) {
        result.add(element);
        if (breakWhenFind) {
          return result;
        }
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
    bool followPainter = true,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    resetSelectedElementList(element == null ? [] : [element],
        selectType: selectType);
    if (followPainter) {
      canvasDelegate.followPainter(elementPainter: element);
    }
  }

  /// 选中所有元素
  @api
  void selectAllElement({
    bool followPainter = true,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    resetSelectedElementList(elements, selectType: selectType);
    if (followPainter) {
      canvasDelegate.followRect(rect: elements.allElementBounds);
    }
  }

  /// 添加一个选中的元素
  @api
  void addSelectElement(
    ElementPainter element, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    selectComponent.addSelectElement(element, selectType: selectType);
  }

  /// 添加一组选中的元素
  @api
  void addSelectElementList(
    List<ElementPainter> elements, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    selectComponent.addSelectElementList(elements, selectType: selectType);
  }

  /// 移除一个选中的元素
  @api
  void removeSelectElement(
    ElementPainter element, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    final list = selectComponent.children ?? [];
    if (list.remove(element)) {
      selectComponent.resetSelectElement(list, selectType);
    }
  }

  /// 移除一组选中的元素
  @api
  void removeSelectElementList(
    List<ElementPainter> elements, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    final list = selectComponent.children ?? [];
    list.removeAll(elements);
    selectComponent.resetSelectElement(list, selectType);
  }

  /// 重置选中的元素集合
  @api
  void resetSelectedElementList(
    List<ElementPainter>? elements, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    selectComponent.resetSelectElement(elements, selectType);
  }

  /// 清空选中的元素/取消选中的元素
  @api
  void clearSelectedElement({
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    resetSelectedElementList(null, selectType: selectType);
  }

  /// 如果操作的元素被选中, 则清空所有选中的元素
  @api
  void clearSelectedElementIf(
    ElementPainter? element, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (isElementSelected(element)) {
      clearSelectedElement(selectType: selectType);
    }
  }

  @api
  void clearAnySelectedElementIf(
    List<ElementPainter>? elementList, {
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (isAnyElementSelected(elementList)) {
      clearSelectedElement(selectType: selectType);
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
    bool includeGroupPainter = false,
  }) {
    if (isSelectedElement) {
      final selectComponent = this.selectComponent;
      if (exportSingleElement) {
        return selectComponent.getSingleElementList(
            includeGroupPainter: includeGroupPainter);
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

  /// 是否选中了指定元素
  /// 指定的元素是否在选中列表中,
  /// 也就是指定的元素是否有被选中
  @api
  bool isElementSelected(ElementPainter? element) {
    return selectComponent.containsElement(element);
  }

  /// [elementList] 中是否有被选中的元素
  /// [isElementSelected]
  @api
  bool isAnyElementSelected(List<ElementPainter>? elementList) {
    if (elementList == null || elementList.isEmpty) {
      return false;
    }
    for (final element in elementList) {
      if (isElementSelected(element)) {
        return true;
      }
    }
    return false;
  }

  /// 更新选择元素的边界, 通常在操作子元素绘制属性发生改变后调用
  /// [ElementSelectComponent]
  @api
  void updateSelectComponentPaintProperty() {
    selectComponent.updatePaintPropertyFromChildren();
  }

  //endregion ---select---

  //region ---operate/api---

  /// 查找指定元素对应的父元素, 如果有
  /// [findElementGroupPainter]
  /// [findTopElementPainter]
  ElementGroupPainter? findElementGroupPainter(ElementPainter? element) =>
      findElementGroupPainterInChildren(element, elements);

  /// [findElementGroupPainter]
  ElementGroupPainter? findElementGroupPainterInChildren(
    ElementPainter? element,
    List<ElementPainter>? children,
  ) {
    for (final e in children ?? []) {
      if (e is ElementGroupPainter) {
        if (e.children?.contains(element) == true) {
          return e;
        }
        final result = findElementGroupPainterInChildren(element, e.children);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  /// 查找指定元素对应的顶层元素
  /// [findElementGroupPainter]
  /// [findTopElementPainter]
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
  /// @return 被移除的元素列表
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
    ElementSelectType selectType = ElementSelectType.code,
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
    final removeList = removeElementListFromTop(oldElementList);
    if (index >= 0 && newElementList != null) {
      elements.insertAll(index, newElementList);
    } else {
      if (newElementList != null) {
        elements.addAll(newElementList);
      }
    }

    detachElementToCanvasDelegate(oldElementList);
    attachElementToCanvasDelegate(newElementList);

    final List<ElementPainter> op = newElementList ?? [];
    canvasElementControlManager.onCanvasElementDeleted(
        removeList ?? [], selectType);
    canvasDelegate.dispatchCanvasElementListChanged(
      old,
      elements,
      op,
      ElementChangeType.replace,
      undoType,
    );
    canvasDelegate.dispatchCanvasElementListRemoveChanged(elements, removeList);
    canvasDelegate.dispatchCanvasElementListAddChanged(
        elements, newElementList);

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          detachElementToCanvasDelegate(newElementList);
          attachElementToCanvasDelegate(oldElementList);
          canvasDelegate.dispatchCanvasElementListChanged(
            newList,
            old,
            op,
            ElementChangeType.update,
            UndoType.undo,
          );
        },
        () {
          //debugger();
          elements.reset(newList);
          detachElementToCanvasDelegate(oldElementList);
          attachElementToCanvasDelegate(newElementList);
          canvasDelegate.dispatchCanvasElementListChanged(
            old,
            newList,
            op,
            ElementChangeType.update,
            UndoType.redo,
          );
        },
      ));
    }

    //选中组合元素
    resetSelectedElementList(op, selectType: selectType);
  }

  /// 组合元素
  @api
  @supportUndo
  bool groupElement(
    List<ElementPainter>? elements, {
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (elements == null || elements.length < 2) {
      assert(() {
        l.d('不满足组合条件');
        return true;
      }());
      return false;
    }

    //删除原来的元素
    final newList = this.elements.clone(true);
    newList.removeAll(elements);

    //创建新的组合元素
    final group = ElementGroupPainter();
    group.resetChildren(elements);
    newList.add(group);

    //事件
    canvasElementControlManager.onCanvasElementDeleted(
      elements,
      selectType,
      dispatchElementSelectChanged: false,
    );
    canvasDelegate.dispatchCanvasGroupChanged(group, elements);
    canvasDelegate.dispatchCanvasElementListRemoveChanged(elements, elements);
    canvasDelegate.dispatchCanvasElementListAddChanged(elements, [group]);

    //重置元素列表
    resetElementList(newList, undoType: undoType);

    //选中组合元素
    resetSelectedElementList([group], selectType: selectType);

    return true;
  }

  /// 解组元素
  @api
  @supportUndo
  bool ungroupElement(
    ElementPainter? group, {
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (group == null || group is! ElementGroupPainter) {
      assert(() {
        l.d('不是[ElementGroupPainter]元素,不能解组');
        return true;
      }());
      return false;
    }

    final children = group.children;
    if (children == null || children.isEmpty) {
      assert(() {
        l.d('不满足解组条件');
        return true;
      }());
      return false;
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
    canvasElementControlManager.onCanvasElementDeleted(
      [group],
      selectType,
      dispatchElementSelectChanged: false,
    );
    canvasDelegate.dispatchCanvasUngroupChanged(group);
    canvasDelegate.dispatchCanvasElementListRemoveChanged(elements, [group]);
    canvasDelegate.dispatchCanvasElementListAddChanged(elements, children);

    //重置元素列表
    resetElementList(newList, undoType: undoType);

    //选中组合元素
    resetSelectedElementList(children, selectType: selectType);

    return true;
  }

  /// 对齐元素/对齐组内元素
  /// [averageElement] - 均分元素
  /// [alignElement]   - 对齐元素
  /// [arrangeElement] - 排列元素
  ///
  /// [alignCanvasContent] 是否强行对齐画布内容, 不指定时:当只有一个元素时,自动开启
  /// [CanvasDelegate.canvasContentRect]
  @api
  @supportUndo
  void alignElement(
    ElementGroupPainter? group,
    CanvasAlignType align, {
    bool? alignCanvasContent,
    UndoType undoType = UndoType.normal,
  }) {
    final children = group?.children;
    if (group == null || children == null || isNil(children)) {
      assert(() {
        l.d('没有需要对齐的元素');
        return true;
      }());
      return;
    }
    alignCanvasContent ??= children.length < 2;
    if (alignCanvasContent && canvasDelegate.canvasContentRect == null) {
      assert(() {
        l.d('请先设置画布内容模版[CanvasContentManager.contentTemplate]!');
        return true;
      }());
      return;
    }

    //需要在此容器边界内对齐
    final Rect? alignBounds = alignCanvasContent
        ? canvasDelegate.canvasContentRect
        : group.paintProperty
            ?.getBounds(canvasElementControlManager.enableResetElementAngle);
    if (alignBounds == null) {
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
              ..translate(alignBounds.left - elementBounds.left, 0.0));
            break;
          case CanvasAlignType.top:
            //所有元素对齐bounds的上边
            element.translateElement(Matrix4.identity()
              ..translate(0.0, alignBounds.top - elementBounds.top));
            break;
          case CanvasAlignType.right:
            //所有元素对齐bounds的右边
            element.translateElement(Matrix4.identity()
              ..translate(alignBounds.right - elementBounds.right, 0.0));
            break;
          case CanvasAlignType.bottom:
            //所有元素对齐bounds的下边
            element.translateElement(Matrix4.identity()
              ..translate(0.0, alignBounds.bottom - elementBounds.bottom));
            break;
          case CanvasAlignType.center:
            //所有元素对齐bounds的中心
            element.translateElement(Matrix4.identity()
              ..translate(alignBounds.center.dx - elementBounds.center.dx,
                  alignBounds.center.dy - elementBounds.center.dy));
            break;
          case CanvasAlignType.horizontalCenter:
            //所有元素对齐bounds的水平中心
            element.translateElement(Matrix4.identity()
              ..translate(
                  0.0, alignBounds.center.dy - elementBounds.center.dy));
            break;
          case CanvasAlignType.verticalCenter:
            //所有元素对齐bounds的垂直中心
            element.translateElement(Matrix4.identity()
              ..translate(
                  alignBounds.center.dx - elementBounds.center.dx, 0.0));
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

  /// 均分元素/均分组内元素, 默认均分规则每个元素之间的间隙保持相同
  /// 可以设置[useCenterAverage], 使用中心点均匀分布, 元素中心点之间的距离保持等距
  /// [useCenterAverage] 是否使用中心点进行均分分布, 否则使用元素之间的等距进行均分分布
  ///
  /// [averageElement] - 均分元素
  /// [alignElement]   - 对齐元素
  /// [arrangeElement] - 排列元素
  ///
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
        l.d('数量不够, 不满足均分条件');
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
  ///
  /// [averageElement] - 均分元素
  /// [alignElement]   - 对齐元素
  /// [arrangeElement] - 排列元素
  ///
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
      old,
      elements,
      elementList,
      ElementChangeType.arrange,
      undoType,
    );

    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          canvasDelegate.dispatchCanvasElementListChanged(
            newList,
            old,
            elementList,
            ElementChangeType.update,
            UndoType.undo,
          );
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasDelegate.dispatchCanvasElementListChanged(
            old,
            newList,
            elementList,
            ElementChangeType.update,
            UndoType.redo,
          );
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
      old,
      elements,
      op,
      ElementChangeType.update,
      undoType,
    );
    //undo
    if (undoType == UndoType.normal) {
      final newList = elements.clone();
      canvasDelegate.canvasUndoManager.add(UndoActionItem(
        () {
          //debugger();
          elements.reset(old);
          canvasDelegate.dispatchCanvasElementListChanged(
            newList,
            old,
            op,
            ElementChangeType.update,
            UndoType.undo,
          );
        },
        () {
          //debugger();
          elements.reset(newList);
          canvasDelegate.dispatchCanvasElementListChanged(
            old,
            newList,
            op,
            ElementChangeType.update,
            UndoType.redo,
          );
        },
      ));
    }
  }

  /// 复制元素
  ///
  /// [copyElement]
  /// [copyElementList]
  /// [copySelectedElement]
  /// [addElementList]
  ///
  @api
  @supportUndo
  List<ElementPainter>? copyElement(
    ElementPainter? element, {
    bool autoAddToCanvas = true,
    @dp Offset? offset,
    bool selected = true,
    bool followPainter = true,
    UndoType undoType = UndoType.normal,
  }) {
    if (element == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return null;
    }
    if (element is ElementSelectComponent) {
      return copyElementList(element.children,
          autoAddToCanvas: autoAddToCanvas,
          offset: offset,
          selected: selected,
          followPainter: followPainter,
          undoType: undoType);
    } else {
      return copyElementList(element.ofList(),
          autoAddToCanvas: autoAddToCanvas,
          offset: offset,
          selected: selected,
          followPainter: followPainter,
          undoType: undoType);
    }
  }

  /// 复制元素
  /// [autoAddToCanvas] 是否自动添加到画布
  ///
  /// [copyElement]
  /// [copyElementList]
  /// [copySelectedElement]
  /// [addElementList]
  ///
  /// @return 复制后的元素列表
  @api
  @supportUndo
  List<ElementPainter>? copyElementList(
    List<ElementPainter>? elementList, {
    //--
    bool autoAddToCanvas = true,
    @dp Offset? offset,
    bool selected = true,
    bool followPainter = true,
    UndoType undoType = UndoType.normal,
  }) {
    if (elementList == null) {
      assert(() {
        l.d('无效的操作');
        return true;
      }());
      return null;
    }
    final newElementList = elementList.copyElementList;
    if (autoAddToCanvas) {
      addElementList(
        newElementList,
        offset:
            offset ?? canvasDelegate.canvasStyle.canvasCopyOffset.toOffsetDp(),
        selected: selected,
        followPainter: followPainter,
        undoType: undoType,
      );
    }
    return newElementList;
  }

  /// 复制选中的所有元素
  ///
  /// [copyElement]
  /// [copyElementList]
  /// [copySelectedElement]
  /// [addElementList]
  @api
  @supportUndo
  List<ElementPainter>? copySelectedElement({
    bool autoAddToCanvas = true,
    @dp Offset? offset,
    bool selected = true,
    bool followPainter = true,
  }) =>
      canvasElementControlManager.copySelectedElement(
        autoAddToCanvas: autoAddToCanvas,
        offset: offset,
        selected: selected,
        followPainter: followPainter,
      );

  /// 锁定操作指定的元素
  @api
  @supportUndo
  void lockOperateElementList(
    List<ElementPainter>? elementList, [
    bool lock = true,
    UndoType undoType = UndoType.normal,
  ]) {
    final list = elementList?.clone() ?? <ElementPainter>[];
    if (lock) {
      //锁定元素
      clearAnySelectedElementIf(elementList);
    }
    canvasDelegate.canvasUndoManager.addRunRedo(() {
      for (final painter in list) {
        painter.isLockOperate = !lock;
      }
    }, () {
      for (final painter in list) {
        painter.isLockOperate = lock;
      }
    }, true, undoType);
  }

  /// 不可见指定的元素
  @api
  @supportUndo
  void visibleElementList(
    List<ElementPainter>? elementList, [
    bool visible = true,
    UndoType undoType = UndoType.normal,
  ]) {
    final list = elementList?.clone() ?? <ElementPainter>[];
    if (!visible) {
      //隐藏元素
      clearAnySelectedElementIf(elementList);
    }
    canvasDelegate.canvasUndoManager.addRunRedo(() {
      for (final painter in list) {
        painter.isVisible = !visible;
      }
    }, () {
      for (final painter in list) {
        painter.isVisible = visible;
      }
    }, true, undoType);
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

/// 元素改变的类型
enum ElementChangeType {
  /// [CanvasElementManager.addElementList] 添加了新元素
  add,

  /// [CanvasElementManager.removeElementList] 删除了元素
  remove,

  /// [CanvasElementManager.replaceElementList] 替换了元素
  replace,

  /// [CanvasElementManager.arrangeElementList] 排序了元素顺序
  arrange,

  /// [CanvasElementManager.resetElementList] 重置元素
  /// [CanvasElementManager.singleUpdateElementList] 更新元素
  /// 在回滚/重置时，会使用此类型
  update,

  /// [CanvasMultiManager.selectCanvasState] 切换了画布
  set,
  ;
}

/// 选择元素的类型
enum ElementSelectType {
  /// 忽略本次选中元素
  /// 请求忽略本次选中元素的回调处理
  ignore,

  /// 通过指针选中元素
  pointer,

  /// 通过多指触选中元素
  multiTouch,

  /// 通过代码选中元素
  code,

  /// 通过用户
  user;
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
