part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 用来监听键盘事件
///
/// [CanvasDelegate] 的成员
///
class CanvasKeyManager with DiagnosticableTreeMixin, DiagnosticsMixin {
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
      [canvasDelegate.canvasStyle.dragKeyboardKey],
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
      canvasDelegate.canvasElementManager.canvasElementControlManager
          .removeSelectedElement();
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
          canvasDelegate.canvasElementManager.canvasElementControlManager;
      if (canvasElementControlManager.isSelectedElement) {
        renderObject.requestFocus();
        final offset =
            canvasDelegate.canvasStyle.canvasArrowAdjustOffset.toOffsetDp();
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
          canvasDelegate.canvasElementManager.selectComponent,
          dx: dx,
          dy: dy,
        );
      }
      return true;
    }, matchKeyCount: false);

    //撤销
    renderObject.registerKeyEvent([
      if (isMacOs) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyZ,
        ],
      ],
      if (!isMacOs) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyZ,
        ],
      ],
    ], (info) {
      canvasDelegate.canvasUndoManager.undo();
      return true;
    });

    //重做
    renderObject.registerKeyEvent([
      if (isMacOs) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyY,
        ],
      ],
      if (!isMacOs) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ,
        ],
      ],
    ], (info) {
      canvasDelegate.canvasUndoManager.redo();
      return true;
    });

    //复制
    renderObject.registerKeyEvent([
      if (isMacOs) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyC,
        ],
      ],
      if (!isMacOs) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyC,
        ],
      ],
    ], (info) {
      _copyElementList = canvasDelegate.canvasElementManager
          .copySelectedElement(autoAddToCanvas: false);
      return true;
    });

    //粘贴
    renderObject.registerKeyEvent([
      if (isMacOs) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyV,
        ],
      ],
      if (!isMacOs) ...[
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
      if (isMacOs) ...[
        [
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyA,
        ],
      ],
      if (!isMacOs) ...[
        [
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyA,
        ],
      ],
    ], (info) {
      canvasDelegate.canvasElementManager.selectAllElement();
      return true;
    });
  }

  /// 粘贴选中的元素
  bool pasteSelectedElement() {
    if (!isNil(_copyElementList)) {
      //为了下一次继续粘贴, 这里需要重新复制一份
      final elementList = _copyElementList!.copyElementList;
      canvasDelegate.canvasElementManager.addElementList(elementList,
          selected: true,
          followPainter: true,
          offset: canvasDelegate.canvasStyle.canvasCopyOffset.toOffsetDp());
      _copyElementList = elementList;
      return true;
    }
    return false;
  }
}
