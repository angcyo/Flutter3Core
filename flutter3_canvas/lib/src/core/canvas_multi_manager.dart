part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/08/25
///
/// 多画布管理
/// 画布上包含元素列表和回退找列表
class CanvasMultiManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  final CanvasDelegate canvasDelegate;

  CanvasElementManager get canvasElementManager =>
      canvasDelegate.canvasElementManager;

  CanvasMultiManager(this.canvasDelegate) {
    //接管画布元素
    initFromCanvasDelegate();
  }

  /// 画布状态列表
  /// - 包含了画布中的所有元素
  /// - 包含了回退栈信息
  final List<CanvasStateData> canvasStateList = [];

  /// 当前选中的画布状态
  CanvasStateData? selectedCanvasState;

  /// 所有画布是否都是
  bool get isAllCanvasEmpty =>
      canvasStateList.all((e) => e.isElementEmpty) && isCurrentCanvasEmpty;

  /// 当前画布是否为空
  bool get isCurrentCanvasEmpty => selectedCanvasState?.isElementEmpty == true;

  /// 从画布中初始化数据, 此方法为了兼容测试使用
  @implementation
  void initFromCanvasDelegate({bool notify = true, bool selected = true}) {
    if (isNil(canvasStateList)) {
      addCanvasState(
        CanvasStateData(
          elements: canvasElementManager.elements,
          undoList: canvasDelegate.canvasUndoManager.undoList,
          redoList: canvasDelegate.canvasUndoManager.redoList,
        ),
        notify: notify,
        selected: selected,
      );
    }
  }

  /// 选中画布
  @callPoint
  void ensureSelectCanvasState({
    bool notify = true,
    //--
    bool selectedElement = false,
    bool followPainter = false,
    bool followContent = false,
    //--
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    CanvasStateData? selectedCanvasState =
        canvasStateList.findFirst((e) => e.isSelected) ??
        canvasStateList.lastOrNull;
    selectCanvasState(
      selectedCanvasState,
      notifyBasics: notify,
      notifySelected: notify,
      //--
      selectedCanvasStateElement: selectedElement,
      followPainter: followPainter,
      followContent: followContent,
      //--
      selectType: selectType,
    );
  }

  //--

  /// 重置画布列表
  ///
  /// - [resetCanvasStateList]
  /// - [addCanvasStateList]
  @api
  void resetCanvasStateList(
    List<CanvasStateData> stateList, {
    bool notify = true,
    bool? selectedCanvas,
    //--
    bool selectedElement = false,
    bool followPainter = false,
    bool followContent = false,
    //--
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    canvasStateList.reset(stateList);

    if (notify) {
      canvasDelegate.dispatchCanvasMultiStateListChanged(canvasStateList);
    }

    //选中第一个
    if (selectedCanvas != false) {
      ensureSelectCanvasState(
        notify: notify,
        selectedElement: selectedElement,
        followPainter: followPainter,
        followContent: followContent,
        selectType: selectType,
      );
    }
  }

  /// 添加画布列表
  /// [autoSelectedCanvas] 是否自动选择画布
  /// [resetCanvasState] 是否重置所有画布状态
  @api
  void addCanvasStateList(
    List<CanvasStateData> stateList, {
    bool notify = true,
    bool autoSelectedCanvas = true,
    //--
    bool selectedElement = false,
    bool followPainter = false,
    bool followContent = false,
    //--
    bool? resetCanvasState,
    //--
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    resetCanvasState ??= isAllCanvasEmpty;
    if (resetCanvasState) {
      canvasStateList.reset(stateList);
    } else {
      canvasStateList.addAll(stateList);
    }
    if (notify) {
      canvasDelegate.dispatchCanvasMultiStateListChanged(canvasStateList);
    }
    if (autoSelectedCanvas) {
      if (resetCanvasState) {
        ensureSelectCanvasState(
          notify: notify,
          selectedElement: selectedElement,
          followPainter: followPainter,
          followContent: followContent,
          selectType: selectType,
        );
      }
    }
  }

  /// 添加一个画布状态
  /// [notify] 是否通知事件
  /// [selected] 是否选中当前的画布
  @api
  void addCanvasState(
    CanvasStateData canvasStateData, {
    bool notify = true,
    bool selected = false,
  }) {
    if (CanvasStateData._canvasStateCount <= 1) {
      CanvasStateData._canvasStateCount = canvasStateList.length;
    }
    CanvasStateData._canvasStateCount++;
    canvasStateData.index = CanvasStateData._canvasStateCount;

    canvasStateList.add(canvasStateData);
    if (notify) {
      canvasDelegate.dispatchCanvasMultiStateChanged(
        canvasStateData,
        CanvasStateType.add,
      );
      canvasDelegate.dispatchCanvasMultiStateListChanged(canvasStateList);
    }
    if (selected) {
      selectCanvasState(
        canvasStateData,
        notifyBasics: notify,
        notifySelected: notify,
      );
    }
  }

  /// 移除一个画布状态
  @api
  void removeCanvasState(
    CanvasStateData canvasStateData, {
    bool notify = true,
    bool notifyBasics = true,
    bool notifySelected = true,
    UndoType undoType = UndoType.reset,
  }) {
    canvasStateList.remove(canvasStateData);
    if (notify) {
      canvasDelegate.dispatchCanvasMultiStateChanged(
        canvasStateData,
        CanvasStateType.remove,
      );
      canvasDelegate.dispatchCanvasMultiStateListChanged(canvasStateList);
    }

    if (canvasStateData == selectedCanvasState) {
      // 移除选中的画布
      selectCanvasState(
        canvasStateList.firstOrNull,
        notifyBasics: notifyBasics,
        notifySelected: notifySelected,
        undoType: undoType,
      );
    }
  }

  /// 切换选中的画布
  /// - [canvasStateData] 需要选中的画布信息
  /// - [selectedCanvasStateElement] 是否选中画布中的所有元素
  /// @return 操作是否成功
  @api
  bool selectCanvasState(
    CanvasStateData? canvasStateData, {
    bool notifyBasics = true,
    bool notifySelected = true,
    UndoType undoType = UndoType.reset,
    //--
    bool selectedCanvasStateElement = false,
    bool followPainter = false,
    bool followContent = false,
    //--
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    if (selectedCanvasState == canvasStateData) {
      //no op
      return false;
    }
    for (final stateData in canvasStateList) {
      stateData.isSelected = false;
    }
    final oldSelected = selectedCanvasState;
    selectedCanvasState = canvasStateData;
    selectedCanvasState?.isSelected = true;

    // 切换画布中的元素
    final oldElements = canvasElementManager.elements.clone();
    final newElements = selectedCanvasState?.elements ?? [];

    // 一组新的元素, 初始化时, 元素可能就是旧的
    final isNewElements = !newElements.equals(oldElements);
    if (isNewElements) {
      //如果有元素被取消选中元素
      if (canvasElementManager.isSelectedElement) {
        canvasElementManager.clearSelectedElement();
      }
      canvasElementManager.elements = newElements;
      canvasElementManager.detachElementToCanvasDelegate(oldElements);
      canvasElementManager.attachElementToCanvasDelegate(newElements);
    } else {
      canvasElementManager.elements = newElements;
    }

    // 切换回退栈
    canvasDelegate.canvasUndoManager.undoList =
        selectedCanvasState?.undoList ?? [];
    canvasDelegate.canvasUndoManager.redoList =
        selectedCanvasState?.redoList ?? [];
    canvasDelegate.dispatchCanvasUndoChanged(
      canvasDelegate.canvasUndoManager,
      undoType,
    );
    canvasDelegate.canvasUndoManager.notifyChanged(undoType);

    // 基础通知
    if (notifyBasics && isNewElements) {
      //通知之前的元素被清除
      canvasDelegate.canvasElementManager.canvasElementControlManager
          .onCanvasElementDeleted(oldElements, ElementSelectType.code);
      //--
      canvasDelegate.dispatchCanvasElementListChanged(
        oldElements,
        newElements,
        newElements,
        ElementChangeType.set,
        undoType,
      );
      //--
      canvasDelegate.dispatchCanvasElementListRemoveChanged(
        CanvasElementType.element,
        canvasElementManager.elements,
        oldElements,
      );
      canvasDelegate.dispatchCanvasElementListAddChanged(
        CanvasElementType.element,
        canvasElementManager.elements,
        newElements,
      );
    }

    // 画布切换通知
    if (notifySelected) {
      canvasDelegate.dispatchCanvasSelectedStateChanged(
        oldSelected,
        selectedCanvasState,
        selectType,
      );
    }

    // 选中元素/跟随元素
    if (selectedCanvasStateElement) {
      canvasDelegate.canvasElementManager.resetSelectedElementList(
        newElements,
        selectType: selectType,
      );
      if (followContent) {
        if (canvasDelegate.canvasContentManager.followCanvasContentTemplate()) {
          //跟随内容成功之后, 不需要降级跟随元素, 否则降级处理
          followPainter = false;
        }
      }
      if (followPainter) {
        canvasDelegate.followPainter(
          elementPainter: canvasElementManager.selectComponent,
        );
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
        painter.resetChildren(newElements);
        canvasDelegate.followPainter(elementPainter: painter);
      }
    }
    return true;
  }
}

enum CanvasStateType {
  /// 添加画布
  add,

  /// 移除画布
  remove,
}

/// 画布状态数据, 用于支持多画布功能
///
/// [CanvasStateDataIterableEx]
/// [CanvasStateDataListEx]
class CanvasStateData {
  /// 画布状态数量
  @flagProperty
  static var _canvasStateCount = 0;

  //--

  /// 画布状态id1
  @configProperty
  String id = $uuid;

  /// 系统自动生成的画布索引, 支持国际化的画布名称
  @autoInjectMark
  int? index;

  /// 当前画布的名称, 通常是自定义的名称
  @configProperty
  String? name;

  /// 是否选中画布
  @configProperty
  bool isSelected;

  //--

  /// 画布元素列表
  /// [CanvasElementManager.elements]
  @configProperty
  List<ElementPainter> elements = [];

  //---

  /// 画布回退栈
  /// [UndoActionManager.undoList]
  List<UndoActionItem> undoList = [];

  /// [UndoActionManager.redoList]
  List<UndoActionItem> redoList = [];

  /// 当前的画布元素是否为空
  bool get isElementEmpty => elements.isEmpty;

  CanvasStateData({
    String? id,
    String? name,
    int? index,
    this.isSelected = false,
    List<ElementPainter>? elements,
    List<UndoActionItem>? undoList,
    List<UndoActionItem>? redoList,
  }) {
    //--
    if (id != null) {
      this.id = id;
    }
    if (name != null) {
      this.name = name;
    }
    if (index != null) {
      this.index = index;
    }
    //--
    if (elements != null) {
      this.elements = elements;
    }
    //--
    if (undoList != null) {
      this.undoList = undoList;
    }
    if (redoList != null) {
      this.redoList = redoList;
    }
  }

  /// 创建一个画布状态数据
  CanvasStateData.fromElementPainter({
    ElementPainter? element,
    List<ElementPainter>? elements,
    //--
    String? id,
    String? name,
    this.isSelected = false,
    List<UndoActionItem>? undoList,
    List<UndoActionItem>? redoList,
  }) {
    if (element != null) {
      this.elements = [element];
    } else if (elements != null) {
      this.elements = elements;
    }
    //--
    if (id != null) {
      this.id = id;
    }
    if (name != null) {
      this.name = name;
    }
    //--
    if (undoList != null) {
      this.undoList = undoList;
    }
    if (redoList != null) {
      this.redoList = redoList;
    }
  }
}
