part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 用来监听键盘事件
///
/// [CanvasDelegate] 的成员
///
class CanvasKeyManager
    with DiagnosticableTreeMixin, DiagnosticsMixin, CanvasDelegateManagerMixin {
  @override
  final CanvasDelegate canvasDelegate;

  CanvasKeyManager(this.canvasDelegate);

  /// 复制的元素列表
  List<ElementPainter>? _copyElementList;

  /// 注册所有键盘事件
  @desktopFlag
  @callPoint
  void registerKeyEventHandler(CanvasRenderBox renderObject) {
    //空格键, 开启拖拽
    renderObject.registerKeyEvent([
      [canvasStyle.dragKeyboardKey],
    ], (info) {
      renderObject.markNeedsPaint();
      return true;
    });

    //删除选中元素
    renderObject.registerKeyEvent([
      [
        LogicalKeyboardKey.delete,
      ],
    ], (info) {
      deleteSelectedElement();
      return true;
    });

    //方向键, 移动选中元素
    renderObject.registerKeyEvent([
      [
        LogicalKeyboardKey.arrowUp,
      ],
      [
        LogicalKeyboardKey.arrowDown,
      ],
      [
        LogicalKeyboardKey.arrowLeft,
      ],
      [
        LogicalKeyboardKey.arrowRight,
      ],
    ], (info) {
      final canvasElementControlManager =
          canvasElementManager.canvasElementControlManager;
      if (canvasElementControlManager.isSelectedElement) {
        renderObject.requestFocus();
        final offset = canvasStyle.canvasArrowAdjustOffset.toOffsetDp();
        final dx = info.keys.contains(LogicalKeyboardKey.arrowLeft)
            ? -offset.dx
            : info.keys.contains(LogicalKeyboardKey.arrowRight)
                ? offset.dx
                : 0.0;
        final dy = info.keys.contains(LogicalKeyboardKey.arrowUp)
            ? -offset.dy
            : info.keys.contains(LogicalKeyboardKey.arrowDown)
                ? offset.dy
                : 0.0;
        canvasElementControlManager.translateElement(
          canvasElementManager.selectComponent,
          dx: dx,
          dy: dy,
        );
      }
      return true;
    }, matchKeyCount: false);

    //撤销
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyZ,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyZ,
        ],
      ],
    ], (info) {
      undo();
      return true;
    });

    //重做
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyY,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ,
        ],
      ],
    ], (info) {
      redo();
      return true;
    });

    //复制
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyC,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyC,
        ],
      ],
    ], (info) {
      copySelectedElement();
      return true;
    });

    //粘贴
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyV,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyV,
        ],
      ],
    ], (info) {
      pasteSelectedElement();
      return true;
    });

    //全选
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyA,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyA,
        ],
      ],
    ], (info) {
      selectAllElement();
      return true;
    });

    //放大画布
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.equal,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.equal,
        ],
      ],
    ], (info) {
      zoomIn();
      return true;
    });

    //缩小画布
    renderObject.registerKeyEvent([
      if (isMacOS) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.minus,
        ],
      ],
      if (!isMacOS) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.minus,
        ],
      ],
    ], (info) {
      zoomOut();
      return true;
    });
  }

  //--

  /// 撤销
  @api
  bool undo() {
    return canvasUndoManager.undo();
  }

  /// 重做
  @api
  bool redo() {
    return canvasUndoManager.redo();
  }

  //--

  /// 复制选中的元素
  @api
  bool copySelectedElement() {
    clearClipboard();
    _copyElementList =
        canvasElementManager.copySelectedElement(autoAddToCanvas: false);
    return !isNil(_copyElementList);
  }

  /// 复制元素列表
  @api
  List<ElementPainter>? copyElementList(List<ElementPainter>? elementList) {
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
      final elementList = _copyElementList!.copyElementList;
      canvasElementManager.addElementList(elementList,
          selected: true,
          followPainter: true,
          offset: canvasStyle.canvasCopyOffset.toOffsetDp());
      _copyElementList = elementList;
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
  void zoomIn({
    @viewCoordinate Offset? anchorPosition,
    bool anim = true,
  }) {
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
  void zoomOut({
    @viewCoordinate Offset? anchorPosition,
    bool anim = true,
  }) {
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
}
