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
  final List<CanvasStateData> canvasStateList = [];

  /// 当前选中的画布状态
  CanvasStateData? selectedCanvasState;

  /// 所有画布是否都是
  bool get isAllCanvasEmpty =>
      canvasStateList.all((e) => e.isElementEmpty) && isCurrentCanvasEmpty;

  /// 当前画布是否为空
  bool get isCurrentCanvasEmpty =>
      (selectedCanvasState?.elements.size() ?? 0) <= 0;

  /// 从画布中初始化数据, 此方法为了兼容测试使用
  @implementation
  void initFromCanvasDelegate({
    bool notify = true,
    bool selected = true,
  }) {
    if (isNil(canvasStateList)) {
      addCanvasState(
          CanvasStateData(
            elements: canvasElementManager.elements,
            undoList: canvasDelegate.canvasUndoManager.undoList,
            redoList: canvasDelegate.canvasUndoManager.redoList,
          ),
          notify: notify,
          selected: selected);
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
  }) {
    CanvasStateData? selectedCanvasState =
        canvasStateList.findFirst((e) => e.isSelected) ??
            canvasStateList.lastOrNull;
    selectCanvasState(
      selectedCanvasState,
      notifyBasics: notify,
      notifySelected: notify,
      //--
      selectedElement: selectedElement,
      followPainter: followPainter,
      followContent: followContent,
    );
  }

  //--

  /// 重置画布列表
  @api
  void resetCanvasStateList(
    List<CanvasStateData> stateList, {
    bool notify = true,
    bool? selectedCanvas,
    //--
    bool selectedElement = false,
    bool followPainter = false,
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
      );
    }
  }

  /// 添加画布列表
  /// [autoSelectedCanvas] 是否自动选择画布
  @api
  void addCanvasStateList(
    List<CanvasStateData> stateList, {
    bool notify = true,
    bool autoSelectedCanvas = true,
    //--
    bool selectedElement = false,
    bool followPainter = false,
    bool followContent = false,
  }) {
    if (isAllCanvasEmpty) {
      canvasStateList.reset(stateList);
    } else {
      canvasStateList.addAll(stateList);
    }
    if (notify) {
      canvasDelegate.dispatchCanvasMultiStateListChanged(canvasStateList);
    }
    if (autoSelectedCanvas) {
      if (isAllCanvasEmpty) {
        ensureSelectCanvasState(
          notify: notify,
          selectedElement: selectedElement,
          followPainter: followPainter,
          followContent: followContent,
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
    canvasStateList.add(canvasStateData);
    if (notify) {
      canvasDelegate.dispatchCanvasMultiStateChanged(
          canvasStateData, CanvasStateType.add);
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
          canvasStateData, CanvasStateType.remove);
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
  /// @return 操作是否成功
  @api
  bool selectCanvasState(
    CanvasStateData? canvasStateData, {
    bool notifyBasics = true,
    bool notifySelected = true,
    UndoType undoType = UndoType.reset,
    //--
    bool selectedElement = false,
    bool followPainter = false,
    bool followContent = false,
  }) {
    if (selectedCanvasState == canvasStateData) {
      return false;
    }
    for (final stateData in canvasStateList) {
      stateData.isSelected = false;
    }
    final oldSelected = selectedCanvasState;
    selectedCanvasState = canvasStateData;
    selectedCanvasState?.isSelected = true;

    //取消选中元素
    canvasElementManager.clearSelectedElement();

    // 切换画布中的元素
    final oldElements = canvasElementManager.elements.clone();
    final newElements = selectedCanvasState?.elements ?? [];
    canvasElementManager.elements = newElements;
    canvasElementManager.detachElementToCanvasDelegate(oldElements);
    canvasElementManager.attachElementToCanvasDelegate(newElements);

    // 切换回退栈
    canvasDelegate.canvasUndoManager.undoList =
        selectedCanvasState?.undoList ?? [];
    canvasDelegate.canvasUndoManager.redoList =
        selectedCanvasState?.redoList ?? [];

    // 基础通知
    if (notifyBasics) {
      canvasDelegate.dispatchCanvasElementListChanged(
        oldElements,
        newElements,
        newElements,
        ElementChangeType.set,
        undoType,
      );
      canvasDelegate.dispatchCanvasUndoChanged(
        canvasDelegate.canvasUndoManager,
        undoType,
      );
      canvasDelegate.canvasUndoManager.notifyChanged(undoType);
    }

    // 画布切换通知
    if (notifySelected) {
      canvasDelegate.dispatchCanvasSelectedStateChanged(
          oldSelected, selectedCanvasState);
    }

    // 选中元素/跟随元素
    if (selectedElement) {
      canvasDelegate.canvasElementManager.resetSelectElement(newElements);
      if (followContent) {
        if (canvasDelegate.canvasContentManager.followCanvasContentTemplate()) {
          //跟随内容成功之后, 不需要降级跟随元素, 否则降级处理
          followPainter = false;
        }
      }
      if (followPainter) {
        canvasDelegate.followPainter(
            elementPainter: canvasElementManager.selectComponent);
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
        painter.resetChildren(
            newElements,
            canvasDelegate.canvasElementManager.canvasElementControlManager
                .enableResetElementAngle);
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
class CanvasStateData {
  /// 画布状态数量
  static var _canvasStateCount = 0;

  /// 画布状态id1
  String id = $uuid;

  /// 当前画布的名字
  String? name;

  /// 是否选中画布
  bool isSelected;

  //--

  /// 画布元素列表
  /// [CanvasElementManager.elements]
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
    this.isSelected = false,
    List<ElementPainter>? elements,
    List<UndoActionItem>? undoList,
    List<UndoActionItem>? redoList,
  }) {
    _canvasStateCount++;
    if (id != null) {
      this.id = id;
    }
    if (name == null) {
      this.name = "Canvas $_canvasStateCount";
    } else {
      this.name = name;
    }
    if (elements != null) {
      this.elements = elements;
    }
    if (undoList != null) {
      this.undoList = undoList;
    }
    if (redoList != null) {
      this.redoList = redoList;
    }
  }
}
