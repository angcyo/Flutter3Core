part of 'menu_mix.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/19
///
/// 鼠标右键弹出菜单的小部件
///
/// - [PopMenuWidget]
///
/// - [LabelMenuTile]
/// - [DesktopTextMenuTile]
/// - [DesktopIconMenuTile]
class MouseRightMenuWidget extends StatefulWidget {
  /// 真实内容
  final Widget? body;

  //MARK: - menu

  /// 仅设置菜单项
  @configProperty
  final List<Widget>? menus;

  /// 菜单对应的点击事件
  @configProperty
  final List<VoidCallback>? onMenusTap;

  /// 仅设置菜单整体
  @configProperty
  final Widget? menu;

  const MouseRightMenuWidget({
    super.key,
    this.body,
    this.menus,
    this.onMenusTap,
    this.menu,
  });

  @override
  State<MouseRightMenuWidget> createState() => _MouseRightMenuWidgetState();
}

class _MouseRightMenuWidgetState extends State<MouseRightMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return PointerListenerWidget(
      child: widget.body,
      onPointer: (event) {
        if (event.isMouseRightDown) {
          //l.i("event->$event");
          if (widget.menus != null) {
            context.showMenus(
              widget.menus,
              onMenusTap: widget.onMenusTap,
              position: event.localPosition,
            );
          }
          if (widget.menu != null) {
            context.showWidgetMenu(widget.menu!, position: event.localPosition);
          }
        } else {
          //l.d("event->$event");
        }
      },
    );
  }
}

extension MouseRightMenuWidgetEx on Widget {
  /// 鼠标右键菜单
  Widget mouseRightMenu({
    List<Widget>? menus,
    List<VoidCallback>? onMenusTap /*菜单对应的点击事件*/,
    Widget? menu,
  }) {
    return MouseRightMenuWidget(
      body: this,
      menus: menus,
      onMenusTap: onMenusTap,
      menu: menu,
    );
  }
}
