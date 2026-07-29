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

  /// 构建一个菜单项
  Widget buildMenuItem(
    GlobalTheme globalTheme,
    String? text,
    GestureTapCallback? onTap, {
    bool enable = true,
    ShortcutConfigBean? shortcutConfig,
  }) {
    return (text ?? "")
        .text(
          textColor: enable ? null : globalTheme.disableTextColor,
          maxLines: 1,
        )
        .expanded()
        .rowOf(
          ShortcutLabelWidget(configBean: shortcutConfig),
          mainAxisSize: .max,
          mainAxisAlignment: .spaceBetween,
        )
        .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
        .inkWell(onTap, enable: enable)
        .popMenu(enable: enable);
  }

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
      buildMenuItem(
        globalTheme,
        libRes?.libPaste,
        () {
          canvasKeyManager.pasteSelectedElement();
        },
        enable: enablePaste,
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.pasteElement.id)
            .firstOrNull,
      ),
      buildMenuItem(
        globalTheme,
        libRes?.libSelectAll,
        () {
          canvasKeyManager.selectAllElement();
        },
        enable: enableSelect,
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.selectAllElement.id)
            .firstOrNull,
      ),
      "100%"
          .text()
          .menuStyleItem(width: canvasDelegate.canvasStyle.menuItemWidth)
          .inkWell(() {
            canvasViewBox.scaleTo(sx: 1, sy: 1);
          })
          .popMenu(),
      buildMenuItem(
        globalTheme,
        libRes?.libZoomIn,
        () {
          canvasKeyManager.zoomIn(anchorPosition: anchorPosition);
        },
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.zoomIn.id)
            .firstOrNull,
      ),
      buildMenuItem(
        globalTheme,
        libRes?.libZoomOut,
        () {
          canvasKeyManager.zoomOut(anchorPosition: anchorPosition);
        },
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.zoomOut.id)
            .firstOrNull,
      ),
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
      buildMenuItem(
        globalTheme,
        libRes?.libCopy,
        () {
          canvasKeyManager.copySelectedElement();
        },
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.copyElement.id)
            .firstOrNull,
      ),
      buildMenuItem(
        globalTheme,
        libRes?.libPaste,
        () {
          canvasKeyManager.pasteSelectedElement();
        },
        enable: enablePaste,
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.pasteElement.id)
            .firstOrNull,
      ),
      buildMenuItem(
        globalTheme,
        libRes?.libDelete,
        () {
          canvasKeyManager.deleteSelectedElement();
        },
        enable: enablePaste,
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.deleteSelectedElement.id)
            .firstOrNull,
      ),
      //--
      hLine(context).size(width: canvasDelegate.canvasStyle.menuItemWidth),
      buildMenuItem(
        globalTheme,
        libRes?.libGroup,
        () {
          canvasKeyManager.groupSelectedElement();
        },
        enable: enableGroup,
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.groupElement.id)
            .firstOrNull,
      ),

      buildMenuItem(
        globalTheme,
        libRes?.libUngroup,
        () {
          canvasKeyManager.ungroupSelectedElement();
        },
        enable: enableUngroup,
        shortcutConfig: shortcutConfigManager
            .findShortcutConfig(id: CanvasKeyActions.ungroupElement.id)
            .firstOrNull,
      ),
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
