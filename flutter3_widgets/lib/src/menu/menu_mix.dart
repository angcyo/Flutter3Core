import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';

part 'mouse_right_menu_widget.dart';
part 'pop_menu_widget.dart';
part 'popup_menu_route.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/19
///

/// 菜单相关扩展
/// - 右键菜单
/// - 长按菜单
///
/// - [BottomMenuItemsDialog]
/// - [DialogExtension.showMenus]
/// - [DialogExtension.showWidgetMenu]
extension MenuWidgetEx on Widget {
  /// 适配菜单
  ///
  /// - [useClickMenu] 是否使用点击菜单
  /// - [useLongPressMenu] 是否使用长按菜单, 移动端默认true
  /// - [useMouseRightMenu] 是否使用鼠标右键菜单, 默认true
  ///
  /// - [menus] 菜单列表
  /// - [onMenusTap] 菜单点击回调, 会自动pop路由
  @adaptiveLayout
  Widget adaptiveMenus(WidgetNullList? menus,
      List<VoidCallback?>? onMenusTap, {
        bool? useClickMenu,
        @defInjectMark bool? useLongPressMenu,
        @defInjectMark bool? useMouseRightMenu,
      }) {
    final List<Widget>? menuList = menus?.filterNull();
    if (isNil(menuList)) {
      return this;
    }
    //--
    void showMenus_(BuildContext context, Offset offset) {
      context.showMenus(
        menuList!,
        onMenusTap: onMenusTap,
        enableDisableStyle: onMenusTap != null,
        targetAnchor: .topLeft,
        followerAnchor: .topLeft,
        alignmentOffset: offset,
      );
    }

    void showMenusDialog_(BuildContext context) {
      context.showWidgetDialog(
        BottomMenuItemsDialog([
          for (var index = 0; index < (menuList?.length ?? 0); index++)
            BottomMenuItemTile(
              onTap: onMenusTap?.getOrNull(index),
              child: menuList![index],
            ),
        ]),
      );
    }

    //--
    Widget result = this;
    /*result = result.click(
      null,
      behavior: .opaque,
      onContentDownTap: useClickMenu == true
          ? (ctx, downDetails) {
              if (isMobile) {
                showMenusDialog_(ctx);
              } else {
                showMenus_(ctx, downDetails.localPosition);
              }
            }
          : null,
      onContentDownLongPress: (useLongPressMenu ?? isMobile)
          ? (ctx, downDetails) {
              if (isMobile) {
                showMenusDialog_(ctx);
              } else {
                showMenus_(ctx, downDetails.localPosition);
              }
            }
          : null,
    );*/
    final body = result;
    result = Builder(
      builder: (ctx) {
        return body.onTouchDetector(
          onClick: useClickMenu == true
              ? (render, event) {
            if (isMobile) {
              showMenusDialog_(ctx);
            } else {
              showMenus_(ctx, event.localPosition);
            }
          }
              : null,
          enableLongPress: useLongPressMenu ?? isMobile,
          onLongPress: (render, event) {
            if (isMobile) {
              showMenusDialog_(ctx);
            } else {
              showMenus_(ctx, event.localPosition);
            }
          },
        );
      },
    );
    if ((useMouseRightMenu ?? true)) {
      result = result.mouseRightMenu(
        onMouseRightContextTap: (ctx, downDetails) {
          showMenus_(ctx, downDetails.localPosition);
        },
      );
    }
    return result;
  }
}
