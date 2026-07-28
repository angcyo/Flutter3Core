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

  /// 构建菜单的[Widget], 返回空则降级到[buildMenuWidget]方法调用
  ///
  /// [CanvasDelegate.showMenus]中显示这些菜单
  ///
  /// [CanvasElementManager.handleElementPointerEvent]驱动
  @callPoint
  List<Widget>? buildMenus({@viewCoordinate Offset? anchorPosition}) => null;

  /// 返回null, 则不显示菜单
  /// - [CanvasDelegate.showWidgetMenu] 通过调用此方法, 显示这些[Widget]菜单
  /// - [CanvasElementManager.handleElementPointerEvent]驱动
  @callPoint
  Widget? buildMenuWidget({@viewCoordinate Offset? anchorPosition}) {
    final canvasMenu = isSelectedElement
        ? _buildElementMenuWidget(anchorPosition: anchorPosition)
        : _buildCanvasMenuWidget(anchorPosition: anchorPosition);
    return canvasMenu;
  }

  //--

  /// 画布菜单, 右键菜单
  /// 构建画布相关菜单, 未选择元素时的菜单
  /// - [buildMenuWidget]
  Widget? _buildCanvasMenuWidget({@viewCoordinate Offset? anchorPosition}) {
    final globalTheme = GlobalTheme.of(context);
    final enableSelect = !isEmptyElement;
    final enablePaste = !isNil(canvasKeyManager._copyElementList);
    final libRes = context?.libRes;
    //外部菜单
    final otherMenus = canvasDelegate.dispatchBuildCanvasMenu();
    final shortcutConfigManager =
        canvasDelegate.canvasKeyManager.shortcutConfigManager;
    return [
      (libRes?.libPaste ?? "粘贴")
          .text(textColor: enablePaste ? null : globalTheme.disableTextColor)
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.pasteElement.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.pasteSelectedElement();
          }, enable: enablePaste)
          .popMenu(enable: enablePaste),
      (libRes?.libSelectAll ?? "全选")
          .text(textColor: enableSelect ? null : globalTheme.disableTextColor)
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.selectAllElement.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.selectAllElement();
          }, enable: enableSelect)
          .popMenu(enable: enableSelect),
      "100%"
          .text()
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasViewBox.scaleTo(sx: 1, sy: 1);
          })
          .popMenu(),
      (libRes?.libZoomIn ?? "放大")
          .text()
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.zoomIn.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.zoomIn(anchorPosition: anchorPosition);
          })
          .popMenu(),
      (libRes?.libZoomOut ?? "缩小")
          .text()
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.zoomOut.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.zoomOut(anchorPosition: anchorPosition);
          })
          .popMenu(),
      (libRes?.libCanvasOptions ?? "画布选项")
          .text()
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasDelegate.showWidgetDialog(
              CanvasOptionsDialog(canvasDelegate),
            );
          })
          .popMenu(),
      hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      if (!canvasDelegate.isCurrentCanvasEmpty &&
          !canvasElementManager.isAllElementHidden())
        (libRes?.libHideAllElements ?? "隐藏所有元素")
            .text()
            .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
            .inkWell(() {
              canvasElementManager.visibleElementList(
                canvasElementManager.elements,
                visible: false,
              );
            })
            .popMenu(),
      if (!canvasDelegate.isCurrentCanvasEmpty &&
          canvasElementManager.isAnyElementHidden())
        (libRes?.libShowAllElements ?? "显示所有元素")
            .text()
            .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
            .inkWell(() {
              canvasElementManager.visibleElementList(
                canvasElementManager.elements,
                visible: true,
              );
            })
            .popMenu(),
      //--
      if (otherMenus.isNotEmpty)
        hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      ...otherMenus,
    ].scroll(
      axis: Axis.vertical,
    )! /*.textStyle(TextStyle(color: Colors.white))*/;
  }

  /// 构建元素相关菜单, 选择了元素时的菜单
  /// - [buildMenuWidget]
  Widget? _buildElementMenuWidget({@viewCoordinate Offset? anchorPosition}) {
    final globalTheme = GlobalTheme.of(context);
    final libRes = context?.libRes;

    final enableSelect = !isEmptyElement;
    final enablePaste = !isNil(canvasKeyManager._copyElementList);

    final enableGroup =
        canvasElementManager.canvasElementControlManager.canGroupElements;
    final enableUngroup =
        canvasElementManager.canvasElementControlManager.canUngroupElements;

    // 选中的元素
    final element = selectedElement;
    //元素菜单
    final elementMenus = element?.buildPainterMenus(
      anchorPosition: anchorPosition,
    );

    //外部菜单
    final otherMenus = canvasDelegate.dispatchBuildCanvasMenu(
      anchorPosition: anchorPosition,
    );

    final shortcutConfigManager =
        canvasDelegate.canvasKeyManager.shortcutConfigManager;
    return [
      //--
      libRes?.libCopy
          .text()
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.copyElement.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.copySelectedElement();
          })
          .popMenu(),
      libRes?.libPaste
          .text(textColor: enablePaste ? null : globalTheme.disableTextColor)
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.selectAllElement.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.pasteSelectedElement();
          }, enable: enablePaste)
          .popMenu(enable: enablePaste),
      libRes?.libDelete
          .text()
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(
                    id: CanvasKeyActions.deleteSelectedElement.id,
                  )
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.deleteSelectedElement();
          })
          .popMenu(),
      //--
      hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      libRes?.libGroup
          .text(textColor: enableGroup ? null : globalTheme.disableTextColor)
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.groupElement.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.groupSelectedElement();
          }, enable: enableGroup)
          .popMenu(enable: enableGroup),
      libRes?.libUngroup
          .text(textColor: enableUngroup ? null : globalTheme.disableTextColor)
          .rowOf(
            ShortcutLabelWidget(
              configBean: shortcutConfigManager
                  .findShortcutConfig(id: CanvasKeyActions.ungroupElement.id)
                  .firstOrNull,
            ),
            mainAxisSize: .min,
            mainAxisAlignment: .spaceBetween,
            gap: kX,
          )
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasKeyManager.ungroupSelectedElement();
          }, enable: enableUngroup)
          .popMenu(enable: enableUngroup),
      //--
      hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      libRes?.libHideElement
          .text()
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasElementManager.visibleElementList(
              canvasElementManager.elementSelectComponent?.children,
              visible: false,
            );
          })
          .popMenu(),
      //--
      if (elementMenus?.isNotEmpty == true)
        hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      ...?elementMenus,
      //--
      if (otherMenus.isNotEmpty)
        hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      ...otherMenus,
    ].scroll(axis: Axis.vertical)!;
  }
}
