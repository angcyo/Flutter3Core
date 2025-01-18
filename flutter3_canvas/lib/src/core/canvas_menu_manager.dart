part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 用来实现画布鼠标右键菜单
///
/// [CanvasDelegate] 的成员
///
class CanvasMenuManager
    with DiagnosticableTreeMixin, DiagnosticsMixin, CanvasDelegateManagerMixin {
  @override
  final CanvasDelegate canvasDelegate;

  CanvasMenuManager(this.canvasDelegate);

  /// 构建菜单的Widget, 返回null则不显示菜单
  ///
  /// [CanvasDelegate.showMenus]中显示这些菜单
  ///
  /// [CanvasElementManager.handleElementEvent]驱动
  @callPoint
  List<Widget>? buildMenus({
    @viewCoordinate Offset? anchorPosition,
  }) =>
      null;

  /// [CanvasDelegate.showWidgetMenu]中显示这些菜单
  /// [CanvasElementManager.handleElementEvent]驱动
  @callPoint
  Widget? buildMenuWidget({
    @viewCoordinate Offset? anchorPosition,
  }) {
    if (isSelectedElement) {
      return _buildElementMenuWidget(anchorPosition: anchorPosition);
    } else {
      return _buildCanvasMenuWidget(anchorPosition: anchorPosition);
    }
  }

  //--

  /// 构建画布相关菜单, 未选择元素时的菜单
  Widget? _buildCanvasMenuWidget({
    @viewCoordinate Offset? anchorPosition,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final enableSelect = !isEmptyElement;
    final enablePaste = !isNil(canvasKeyManager._copyElementList);
    //外部菜单
    final otherMenus = canvasDelegate.dispatchBuildCanvasMenu();
    return [
      "粘贴"
          .text(textColor: enablePaste ? null : globalTheme.disableTextColor)
          .menuStyleItem()
          .ink(() {
        canvasKeyManager.pasteSelectedElement();
      }, enable: enablePaste).popMenu(enable: enablePaste),
      "全选"
          .text(textColor: enableSelect ? null : globalTheme.disableTextColor)
          .menuStyleItem()
          .ink(() {
        canvasKeyManager.selectAllElement();
      }, enable: enableSelect).popMenu(enable: enableSelect),
      "放大".text().menuStyleItem().ink(() {
        canvasKeyManager.zoomIn(anchorPosition: anchorPosition);
      }).popMenu(),
      "缩小".text().menuStyleItem().ink(() {
        canvasKeyManager.zoomOut(anchorPosition: anchorPosition);
      }).popMenu(),
      //--
      if (otherMenus.isNotEmpty) hLine(context).size(width: kMenuMinWidth),
      ...otherMenus,
    ].scroll(
      axis: Axis.vertical,
    )! /*.textStyle(TextStyle(color: Colors.white))*/;
  }

  /// 构建元素相关菜单, 选择了元素时的菜单
  Widget? _buildElementMenuWidget({
    @viewCoordinate Offset? anchorPosition,
  }) {
    final globalTheme = GlobalTheme.of(context);

    final enableSelect = !isEmptyElement;
    final enablePaste = !isNil(canvasKeyManager._copyElementList);

    final enableGroup =
        canvasElementManager.canvasElementControlManager.canGroupElements;
    final enableUngroup =
        canvasElementManager.canvasElementControlManager.canUngroupElements;

    //外部菜单
    final otherMenus = canvasDelegate.dispatchBuildCanvasMenu();
    return [
      //--
      "复制".text().menuStyleItem().ink(() {
        canvasKeyManager.copySelectedElement();
      }).popMenu(),
      "粘贴"
          .text(textColor: enablePaste ? null : globalTheme.disableTextColor)
          .menuStyleItem()
          .ink(() {
        canvasKeyManager.pasteSelectedElement();
      }, enable: enablePaste).popMenu(enable: enablePaste),
      "删除".text().menuStyleItem().ink(() {
        canvasKeyManager.deleteSelectedElement();
      }).popMenu(),
      //--
      hLine(context).size(width: kMenuMinWidth),
      "组合"
          .text(textColor: enableGroup ? null : globalTheme.disableTextColor)
          .menuStyleItem()
          .ink(() {
        canvasKeyManager.groupSelectedElement();
      }, enable: enableGroup).popMenu(enable: enableGroup),
      "取消组合"
          .text(textColor: enableUngroup ? null : globalTheme.disableTextColor)
          .menuStyleItem()
          .ink(() {
        canvasKeyManager.ungroupSelectedElement();
      }, enable: enableUngroup).popMenu(enable: enableUngroup),
      //--
      if (otherMenus.isNotEmpty) hLine(context).size(width: kMenuMinWidth),
      ...otherMenus,
    ].scroll(
      axis: Axis.vertical,
    )!;
  }
}
