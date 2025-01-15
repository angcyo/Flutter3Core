part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/18
///

mixin CanvasComponentMixin {
  /// 是否启用组件
  bool isCanvasComponentEnable = true;
}

mixin CanvasDelegateManagerMixin {
  CanvasDelegate get canvasDelegate;

  //--

  CanvasUndoManager get canvasUndoManager => canvasDelegate.canvasUndoManager;

  CanvasKeyManager get canvasKeyManager => canvasDelegate.canvasKeyManager;

  CanvasEventManager get canvasEventManager =>
      canvasDelegate.canvasEventManager;

  CanvasElementManager get canvasElementManager =>
      canvasDelegate.canvasElementManager;

  CanvasPaintManager get canvasPaintManager =>
      canvasDelegate.canvasPaintManager;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  CanvasStyle get canvasStyle => canvasDelegate.canvasStyle;

  /// 元素上下文
  BuildContext? get context => canvasDelegate.delegateContext;

  /// 坐标系
  CanvasAxisManager get axisManager => canvasPaintManager.axisManager;

  //--

  /// 返回元素是否为空
  bool get isEmptyElement =>
      canvasDelegate.canvasElementManager.elements.isEmpty;

  /// 返回是否选中元素
  bool get isSelectedElement =>
      canvasDelegate.canvasElementManager.isSelectedElement;

  /// 返回是否选中Group元素
  bool get isSelectedGroupElement => selectedElement is ElementGroupPainter;

  /// 返回选中的元素
  /// @return
  /// - [ElementPainter]
  /// - [ElementSelectComponent]
  ElementPainter? get selectedElement =>
      canvasDelegate.canvasElementManager.selectedElement;

  /// 返回选中的所有元素
  List<ElementPainter>? get selectedElementList =>
      canvasDelegate.canvasElementManager.selectedElementList;
}
