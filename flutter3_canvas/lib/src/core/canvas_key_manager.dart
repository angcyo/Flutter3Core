part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 用来监听键盘事件
///
/// - [CanvasDelegate.canvasKeyManager] 的成员
///   - [CanvasKeyManager] 用来监听键盘事件
///   - [CanvasEventManager] 用来处理手势事件
///
class CanvasKeyManager
    with DiagnosticableTreeMixin, DiagnosticsMixin, CanvasDelegateManagerMixin {
  @override
  final CanvasDelegate canvasDelegate;

  /// 快捷键配置管理器
  /// - [CanvasKeyManager.handleKeyEvent]驱动
  ShortcutConfigManager? shortcutConfigManager;

  CanvasKeyManager(this.canvasDelegate) {
    assert(() {
      final shortcutIntentList =
          $globalShortcutConfigManager.shortcutIntentList;
      final count = shortcutIntentList.fold(
        0,
        (p, e) => p + (e.id.startsWith("canvas.") ? 1 : 0),
      );
      l.i(
        "注册快捷意图个数->"
        "[$count/"
        "${shortcutIntentList.length}]!",
      );
      return true;
    }());
    shortcutConfigManager = $globalShortcutConfigManager;
    CanvasShortcutHelper.registerCanvasShortcutIntents(shortcutConfigManager);
  }

  /// 复制的元素列表
  @tempFlag
  List<ElementPainter>? _copyElementList;

  /// 注册所有键盘事件, 注册事件之后通过[KeyEventMixin.onHandleKeyEventMixin]入口进行分发处理
  ///
  /// - [registerKeyEventHandler] -> [KeyEventMixin.registerKeyEvent]
  /// - [unregisterKeyEventHandler]
  ///
  /// - [CanvasRenderBox.attach] 驱动
  @desktopFlag
  @callPoint
  void registerKeyEventHandler(CanvasRenderBox renderObject) {
    //no op
    shortcutConfigManager?.registerShortcutConfigs(
      CanvasShortcutHelper.kCanvasShortcutConfigBeansList,
    );
  }

  /// 取消所有按键的注册
  /// - [registerKeyEventHandler]
  /// - [unregisterKeyEventHandler]
  @callPoint
  void unregisterKeyEventHandler(CanvasRenderBox renderObject) {
    //shortcutConfigManager.clearShortcutConfig();
    //shortcutConfigManager.clearShortcutAction();
    //renderObject.removeAllKeyEventRegister(tag: keyTag);
  }

  /// 新的按键事件处理
  /// - [CanvasRenderBox.handleKeyEventResultMixin]驱动
  @callPoint
  KeyEventResult handleKeyEvent(CanvasRenderBox renderObject, KeyEvent event) {
    //触发注册的快捷键
    final result = shortcutConfigManager?.triggerShortcutAction(
      event: event,
      context: canvasDelegate.delegateContext,
      host: canvasDelegate,
      data: renderObject,
    );
    return result ?? KeyEventResult.ignored;
  }

  //--

  /// 撤销
  @api
  FutureOr<bool> undo() {
    return canvasUndoManager.undo();
  }

  /// 重做
  @api
  FutureOr<bool> redo() {
    return canvasUndoManager.redo();
  }

  //--

  /// 清除复制的元素数据
  @api
  void clearCopyElementList() {
    _copyElementList = null;
  }

  /// 复制选中的元素
  @api
  bool copySelectedElement() {
    if (isSelectedElement) {
      clearClipboard();
      () async {
        _copyElementList = await canvasElementManager.copySelectedElement(
          autoAddToCanvas: false,
        );
      }();
      return true;
    } else {
      return false;
    }
  }

  /// 复制元素列表
  @api
  Future<List<ElementPainter>?> copyElementList(
    List<ElementPainter>? elementList,
  ) async {
    return canvasElementManager.copyElementList(
      elementList,
      autoAddToCanvas: false,
    );
  }

  /// 粘贴选中的元素
  @api
  bool pasteSelectedElement() {
    //debugger();
    if (!isNil(_copyElementList)) {
      //为了下一次继续粘贴, 这里需要重新复制一份
      () async {
        final elementList = await _copyElementList!.copyElementList();
        canvasElementManager.addElementList(
          elementList,
          selected: true,
          followPainter: !isDesktopOrWeb,
          offset: canvasStyle.canvasCopyOffset.toOffsetDp(),
        );
        _copyElementList = elementList;
      }();
      return true;
    }
    return false;
  }

  /// 选择所有元素
  @api
  bool selectAllElement() {
    canvasElementManager.selectAllElement();
    return true;
  }

  /// 删除选中的元素
  @api
  bool deleteSelectedElement() {
    return canvasElementManager.canvasElementControlManager
        .removeSelectedElement();
  }

  /// 删除元素
  @api
  @supportUndo
  bool deleteElementList(
    List<ElementPainter>? list, {
    UndoType undoType = UndoType.normal,
    ElementSelectType selectType = ElementSelectType.code,
  }) {
    return canvasElementManager.removeElementList(
      list,
      undoType: undoType,
      selectType: selectType,
    );
  }

  //--

  /// 放大画布
  @api
  void zoomIn({@viewCoordinate Offset? anchorPosition, bool anim = true}) {
    final canvasScaleComponent = canvasEventManager.canvasScaleComponent;
    canvasViewBox.scaleBy(
      sx: canvasScaleComponent.doubleScaleValue,
      sy: canvasScaleComponent.doubleScaleValue,
      pivot: anchorPosition != null
          ? canvasViewBox.toScenePoint(anchorPosition)
          : canvasViewBox.canvasSceneVisibleBounds.center,
      anim: anim,
    );
  }

  /// 缩小画布
  @api
  void zoomOut({@viewCoordinate Offset? anchorPosition, bool anim = true}) {
    final canvasScaleComponent = canvasEventManager.canvasScaleComponent;
    canvasViewBox.scaleBy(
      sx: canvasScaleComponent.doubleScaleReverseValue,
      sy: canvasScaleComponent.doubleScaleReverseValue,
      pivot: anchorPosition != null
          ? canvasViewBox.toScenePoint(anchorPosition)
          : canvasViewBox.canvasSceneVisibleBounds.center,
      anim: anim,
    );
  }

  //--

  /// 组合选中元素
  @api
  bool groupSelectedElement() {
    return canvasElementManager.groupElement(
      canvasElementManager.elementSelectComponent?.children,
    );
  }

  /// 解组选中的元素
  @api
  bool ungroupSelectedElement() {
    return canvasElementManager.ungroupElement(
      canvasElementManager.selectedElement,
    );
  }

  //--

  /// 移动元素
  /// - [element] 要移动的元素, 不指定则使用选中的元素
  @api
  void moveElement(
    AxisDirection axis, {
    ElementPainter? element,
    bool fast = false,
  }) {
    final canvasElementManager = canvasDelegate.canvasElementManager;
    final canvasStyle = canvasDelegate.canvasStyle;
    final canvasElementControlManager =
        canvasElementManager.canvasElementControlManager;
    if (canvasElementControlManager.isSelectedElement) {
      //renderObject.requestFocus();
      final offset =
          (fast
                  ? canvasStyle.canvasArrowAdjustFastOffset
                  : canvasStyle.canvasArrowAdjustOffset)
              .toOffsetDp();
      final dx = axis == AxisDirection.left
          ? -offset.dx
          : axis == AxisDirection.right
          ? offset.dx
          : 0.0;
      final dy = axis == AxisDirection.up
          ? -offset.dy
          : axis == AxisDirection.down
          ? offset.dy
          : 0.0;
      canvasElementControlManager.translateElement(
        element ?? canvasElementManager.selectComponent,
        dx: dx,
        dy: dy,
      );
    }
  }
}
