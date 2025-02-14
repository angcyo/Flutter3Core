library flutter3_popup;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/15
///

part 'arrow_layout.dart';
part 'arrow_popup_overlay.dart';
part 'arrow_popup_route.dart';

/// 弹窗路由扩展
extension PopupEx on BuildContext {
  /// 使用路由的方式显示界面[ArrowPopupRoute], 手势不可以穿透, 支持系统的back按键
  /// 在指定的[anchorRect]位置, 显示[ArrowPopupRoute]的[Widget]
  /// [anchorRect].[anchorChild]必须指定一个
  ///
  /// [showArrow] 是否显示箭头
  ///
  /// [ArrowPopupRoute]
  Future showArrowPopupRoute(
    Widget child, {
    //--
    Rect? anchorRect,
    BuildContext? anchorChild,
    bool rootNavigator = false,
    //--
    Color? backgroundColor,
    Color? arrowColor,
    bool showArrow = true,
    Color? barriersColor,
    AxisDirection? arrowDirection,
    EdgeInsets? contentPadding = const EdgeInsets.all(kH),
    EdgeInsets? contentMargin = const EdgeInsets.all(kX),
    IgnorePointerType? barrierIgnorePointerType,
  }) async {
    final navigator = Navigator.of(this, rootNavigator: rootNavigator);
    anchorRect ??= anchorChild
        ?.findRenderObject()
        ?.getGlobalBounds(navigator.context.findRenderObject());
    anchorRect ??= findRenderObject()?.getGlobalBounds() ?? Rect.zero;
    final globalTheme = GlobalTheme.of(this);
    return navigator.push(
      ArrowPopupRoute(
        child: child,
        anchorRect: anchorRect,
        backgroundColor: backgroundColor ?? globalTheme.surfaceBgColor,
        arrowColor: arrowColor ?? globalTheme.surfaceBgColor,
        showArrow: showArrow,
        arrowDirection: arrowDirection,
        barriersColor: barriersColor,
        padding: contentPadding,
        margin: contentMargin,
        barrierIgnorePointerType: barrierIgnorePointerType,
      ),
    );
  }

  /// 使用[OverlayEntry]的方式显示, 手势可以穿透
  /// [showArrowPopupRoute]
  /// [ArrowPopupOverlay]
  /// [OverlayEntry.remove] 手动移除
  OverlayEntry showArrowPopupOverlay(
    Widget child, {
    Rect? anchorRect,
    BuildContext? anchorChild,
    Color? backgroundColor = Colors.white,
    Color arrowColor = Colors.white,
    bool showArrow = true,
    Color? barriersColor,
    AxisDirection? arrowDirection,
    bool enablePassEvent = true,
    ArrowPopupOverlayController? controller,
  }) {
    if (controller != null && !controller.canResponse) {
      //不能响应
      return controller.overlayEntry!;
    }
    assert(anchorRect != null || anchorChild != null);
    anchorRect ??= anchorChild?.findRenderObject()?.getGlobalBounds();
    anchorRect ??= findRenderObject()?.getGlobalBounds();
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return ArrowPopupOverlay(
          anchorRect: anchorRect!,
          backgroundColor: backgroundColor,
          arrowColor: arrowColor,
          showArrow: showArrow,
          arrowDirection: arrowDirection,
          barriersColor: barriersColor,
          controller: (controller ?? ArrowPopupOverlayController())
            ..overlayEntry = overlayEntry,
          enablePassEvent: enablePassEvent,
          child: child,
        );
      },
    );
    Overlay.of(this).insert(overlayEntry);
    return overlayEntry;
  }
}
