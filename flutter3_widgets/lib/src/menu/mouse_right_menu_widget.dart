part of 'menu_mix.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/19
///
/// 鼠标右键弹出菜单的小部件, 默认弹出位置为鼠标点击位置
/// 内部使用[PopupRoute]实现
///
/// - [PopMenuWidget]
///
/// - [LabelMenuTile]
/// - [DesktopTextMenuTile]
/// - [DesktopIconMenuTile]
class MouseRightMenuWidget extends StatefulWidget {
  /// 真实内容
  final Widget? child;

  /// action
  final PointerEventListener? onMouseRightTap;
  final PointerEventContentListener? onMouseRightContentTap;

  //MARK: - menu

  /// 仅设置菜单项
  @configProperty
  final List<Widget>? menus;

  /// 菜单对应的点击事件
  @configProperty
  final List<VoidCallback?>? onMenusTap;

  /// 仅设置菜单整体
  @configProperty
  final Widget? menu;

  /// 对齐后, 额外的偏移量
  final Offset? alignmentOffset;

  /// 是否使用根导航器
  final bool useRootNavigator;

  const MouseRightMenuWidget({
    super.key,
    this.child,
    this.onMouseRightTap,
    this.onMouseRightContentTap,
    //--
    this.useRootNavigator = false,
    this.menus,
    this.onMenusTap,
    this.menu,
    this.alignmentOffset,
  });

  @override
  State<MouseRightMenuWidget> createState() => _MouseRightMenuWidgetState();
}

class _MouseRightMenuWidgetState extends State<MouseRightMenuWidget> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return PointerListenerWidget(
      child: widget.child,
      onPointer: (event) {
        if (event.isMouseRightDown) {
          //l.i("event->$event");
          if (widget.menus != null) {
            context.showMenus(
              widget.menus,
              onMenusTap: widget.onMenusTap,
              position: event.localPosition,
              color: globalTheme.dialogSurfaceBgColor,
              elevation: kMenuStyle.elevation?.resolve({}),
              shape: kMenuStyle.shape?.resolve({}),
              menuPadding: kMenuStyle.padding?.resolve({}),
              offset: widget.alignmentOffset,
              useRootNavigator: widget.useRootNavigator,
            );
          }
          if (widget.menu != null) {
            context.showWidgetMenu(
              widget.menu!,
              position: event.localPosition,
              color: globalTheme.dialogSurfaceBgColor,
              elevation: kMenuStyle.elevation?.resolve({}),
              shape: kMenuStyle.shape?.resolve({}),
              menuPadding: kMenuStyle.padding?.resolve({}),
              offset: widget.alignmentOffset,
              useRootNavigator: widget.useRootNavigator,
            );
          }
          widget.onMouseRightTap?.call(event);
          widget.onMouseRightContentTap?.call(context, event);
        } else {
          //l.d("event->$event");
        }
      },
    );
  }
}

extension MouseRightMenuWidgetEx on Widget {
  /// 鼠标右键触发
  /// - 自定义显示的内容以及方式
  /// ```
  /// .mouseRightTrigger(
  ///   onMouseRightContentTap: (ctx, event) {
  ///     context.showOverlay(
  ///       (ctx, entry) {
  ///         return DebugFileMenuDialog(
  ///           this.path,
  ///           onDeleteAction: onDeleteAction,
  ///           dialogInOverlay: true,
  ///         ).elevation().material();
  ///       },
  ///       alignmentOffset: event.localPosition,
  ///       scaleAlignment: .topLeft,
  ///       hideOverlayOutsideTap: true,
  ///     );
  ///   },
  /// );
  /// ```
  Widget mouseRightTrigger({
    Key? key,
    PointerEventListener? onMouseRightTap,
    PointerEventContentListener? onMouseRightContentTap,
    bool enable = true,
  }) {
    return enable
        ? MouseRightMenuWidget(
            key: key,
            onMouseRightTap: onMouseRightTap,
            onMouseRightContentTap: onMouseRightContentTap,
            child: this,
          )
        : this;
  }

  /// 鼠标右键菜单
  /// - 仅支持显示[PopupMenuRoute]的内容
  /// ```
  /// .mouseRightMenu(
  ///    menus: [
  ///      LabelMenuTile(
  ///        label: "保存",
  ///        labelTextStyle: globalTheme.textBodyStyle,
  ///      ),
  ///    ],
  ///    onMenusTap: [
  ///      () async {
  ///        //save as
  ///        saveFilePath(
  ///          (await frames![i].saveToFilePath(
  ///            await cacheFilePath("output_$i.png"),
  ///          ))?.path,
  ///        );
  ///      },
  ///    ],
  /// )
  /// ```
  Widget mouseRightMenu({
    Key? key,
    List<Widget>? menus,
    List<VoidCallback?>? onMenusTap /*菜单对应的点击事件*/,
    //--菜单整体
    Widget? menu,
    //--
    bool useRootNavigator = false,
    bool enable = true,
  }) {
    if (!enable) {
      return this;
    }
    return MouseRightMenuWidget(
      key: key,
      menus: menus,
      onMenusTap: onMenusTap,
      menu: menu,
      useRootNavigator: useRootNavigator,
      child: this,
    );
  }
}
