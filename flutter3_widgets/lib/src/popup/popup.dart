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
  /// - [anchorRect].[anchorChild]必须指定一个
  ///
  /// - [showArrow] 是否显示箭头
  /// - [arrowDirection] 指定箭头的方向
  /// - [arrowDirectionMinOffset] 箭头的偏移量
  ///
  /// - [ArrowPopupRoute]
  ///
  /// - [showArrowPopupOverlay] 手势可以穿透
  /// - [showArrowPopupRoute] 手势不可以穿透
  Future showArrowPopupRoute(
    Widget child, {
    //--
    Rect? anchorRect,
    BuildContext? anchorChild,
    bool rootNavigator = false,
    //--
    Color? backgroundColor,
    double? radius,
    Color? arrowColor,
    bool showArrow = true,
    bool animate = true,
    Color? barriersColor,
    AxisDirection? arrowDirection,
    double arrowDirectionMinOffset = 15,
    EdgeInsets? contentPadding = const EdgeInsets.all(kH),
    EdgeInsets? contentMargin = const EdgeInsets.all(kX),
    IgnorePointerType? barrierIgnorePointerType,
    //--
    ArrowLayoutChildOffsetCallback? childOffsetCallback,
  }) async {
    final navigator = Navigator.of(this, rootNavigator: rootNavigator);
    anchorRect ??= anchorChild?.findRenderObject()?.getGlobalBounds(
      navigator.context.findRenderObject(),
    );
    anchorRect ??= findRenderObject()?.getGlobalBounds() ?? Rect.zero;
    final globalTheme = GlobalTheme.of(this);
    return navigator.push(
      ArrowPopupRoute(
        child: child,
        anchorRect: anchorRect,
        backgroundColor: backgroundColor ?? globalTheme.surfaceBgColor,
        radius: radius,
        arrowColor: arrowColor ?? globalTheme.surfaceBgColor,
        showArrow: showArrow,
        animate: animate,
        arrowDirection: arrowDirection,
        arrowDirectionMinOffset: arrowDirectionMinOffset,
        barriersColor: barriersColor,
        padding: contentPadding,
        margin: contentMargin,
        barrierIgnorePointerType: barrierIgnorePointerType,
        childOffsetCallback: childOffsetCallback,
      ),
    );
  }

  /// 使用[OverlayEntry]的方式显示, 手势可以穿透
  /// - [showArrowPopupOverlay] 手势可以穿透
  /// - [showArrowPopupRoute] 手势不可以穿透
  /// - [ArrowPopupOverlay]
  /// - [OverlayEntry.remove] 手动移除
  OverlayEntry showArrowPopupOverlay(
    Widget child, {
    Rect? anchorRect,
    BuildContext? anchorChild,
    Color? backgroundColor = Colors.white,
    double? radius,
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
          radius: radius,
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
