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

  CanvasMultiManager(this.canvasDelegate);

  /// 画布状态列表
  final List<CanvasStateData> canvasStateList = [];

  /// 当前选中的画布状态
  CanvasStateData? selectedCanvasState;

  /// 从画布中初始化数据, 此方法为了兼容测试使用
  @implementation
  void initFromCanvasDelegate() {
    if (isNil(canvasStateList)) {
      addCanvasState(
          CanvasStateData(
            elements: canvasElementManager.elements,
            undoList: canvasDelegate.canvasUndoManager.undoList,
            redoList: canvasDelegate.canvasUndoManager.redoList,
          ),
          selected: true);
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
      selectCanvasState(canvasStateData);
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
  @api
  void selectCanvasState(
    CanvasStateData? canvasStateData, {
    bool notifyBasics = true,
    bool notifySelected = true,
    UndoType undoType = UndoType.reset,
  }) {
    if (selectedCanvasState == canvasStateData) {
      return;
    }
    final oldSelected = selectedCanvasState;
    selectedCanvasState = canvasStateData;

    //取消选中元素
    canvasElementManager.clearSelectedElement();

    // 切换画布中的元素
    final oldElements = canvasElementManager.elements.clone();
    canvasElementManager.elements = selectedCanvasState?.elements ?? [];
    // 切换回退栈
    canvasDelegate.canvasUndoManager.undoList =
        selectedCanvasState?.undoList ?? [];
    canvasDelegate.canvasUndoManager.redoList =
        selectedCanvasState?.redoList ?? [];

    // 基础通知
    if (notifyBasics) {
      canvasDelegate.dispatchCanvasElementListChanged(
          oldElements,
          canvasElementManager.elements,
          canvasElementManager.elements,
          undoType);
      canvasDelegate.dispatchCanvasUndoChanged(
          canvasDelegate.canvasUndoManager, undoType);
      canvasDelegate.canvasUndoManager.notifyChanged(undoType);
    }

    // 画布切换通知
    if (notifySelected) {
      canvasDelegate.dispatchCanvasSelectedStateChanged(
          oldSelected, selectedCanvasState);
    }
  }
}

enum CanvasStateType {
  /// 添加画布
  add,

  /// 移除画布
  remove,
}

/// 画布状态数据
class CanvasStateData {
  /// 画布状态数量
  static var _canvasStateCount = 0;

  /// 画布状态id1
  String id = $uuid;

  /// 当前画布的名字
  String? name;

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

  CanvasStateData({
    String? name,
    List<ElementPainter>? elements,
    List<UndoActionItem>? undoList,
    List<UndoActionItem>? redoList,
  }) {
    _canvasStateCount++;
    if (name == null) {
      this.name = "画布 $_canvasStateCount";
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
