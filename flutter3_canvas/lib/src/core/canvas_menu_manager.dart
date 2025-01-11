part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 用来实现鼠标右键菜单
///
/// [CanvasDelegate] 的成员
///
class CanvasMenuManager with DiagnosticableTreeMixin, DiagnosticsMixin {
  final CanvasDelegate canvasDelegate;

  CanvasKeyManager get canvasKeyManager => canvasDelegate.canvasKeyManager;

  CanvasEventManager get canvasEventManager =>
      canvasDelegate.canvasEventManager;

  CanvasViewBox get canvasViewBox => canvasDelegate.canvasViewBox;

  /// 元素上下文
  BuildContext? get context => canvasDelegate.delegateContext;

  CanvasMenuManager(this.canvasDelegate);

  /// 返回元素是否为空
  bool get isEmptyElement =>
      canvasDelegate.canvasElementManager.elements.isEmpty;

  /// 返回是否选中元素
  bool get isSelectedElement =>
      canvasDelegate.canvasElementManager.isSelectedElement;

  /// 返回选中的元素
  /// @return
  /// - [ElementPainter]
  /// - [ElementSelectComponent]
  ElementPainter? get selectedElement =>
      canvasDelegate.canvasElementManager.selectedElement;

  /// 构建菜单的Widget, 返回null则不显示菜单
  ///
  /// [CanvasDelegate.showMenu]中显示这些菜单
  ///
  /// [CanvasElementManager.handleElementEvent]驱动
  @callPoint
  List<Widget>? buildMenuWidgets({
    @viewCoordinate Offset? anchorPosition,
  }) {
    return [
      "粘贴".text().click(() {
        canvasKeyManager.pasteSelectedElement();
      }).popMenu(),
      "全选".text().click(() {
        canvasDelegate.canvasElementManager.selectAllElement();
      }).popMenu(),
      "放大"
          .text()
          .click(() {
            final canvasScaleComponent =
                canvasEventManager.canvasScaleComponent;
            canvasViewBox.scaleBy(
              sx: canvasScaleComponent.doubleScaleValue,
              sy: canvasScaleComponent.doubleScaleValue,
              pivot: anchorPosition != null
                  ? canvasViewBox.toScenePoint(anchorPosition)
                  : canvasViewBox.canvasSceneVisibleBounds.center,
              anim: true,
            );
          })
          .popMenu()
          .backgroundColor(Colors.purpleAccent),
      "缩小"
          .text()
          .click(() {
            final canvasScaleComponent =
                canvasEventManager.canvasScaleComponent;
            canvasViewBox.scaleBy(
              sx: canvasScaleComponent.doubleScaleReverseValue,
              sy: canvasScaleComponent.doubleScaleReverseValue,
              pivot: anchorPosition != null
                  ? canvasViewBox.toScenePoint(anchorPosition)
                  : canvasViewBox.canvasSceneVisibleBounds.center,
              anim: true,
            );
          })
          .popMenu()
          .backgroundColor(Colors.purpleAccent),
    ];
  }
}
