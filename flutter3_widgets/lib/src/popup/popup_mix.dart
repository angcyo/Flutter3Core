library flutter3_popup;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

import '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/15
///

part 'arrow_layout.dart';
part 'arrow_popup_overlay.dart';
part 'arrow_popup_route.dart';

/// 弹窗路由扩展
extension PopupEx on BuildContext {
  /// 在指定锚点位置显示一个弹窗路由
  ///
  /// - [alignment]弹窗需要对齐锚点的哪个方向
  /// - [bodyMargin] 弹窗的在对应方向上的边距
  ///
  /// - [showArrowPopupRoute]
  Future showPopupDialog(
    Widget body, {
    GlobalKey? anchorKey,
    //--
    Rect? anchorRect,
    BuildContext? anchorChild,
    bool rootNavigator = false,
    double bodyMargin = kH,
    //--
    Alignment? alignment,
    //--
    Color? backgroundColor,
    double? radius,
    bool animate = true,
    Color? barriersColor = Colors.transparent,
    EdgeInsets? contentPadding = const EdgeInsets.all(kS),
    EdgeInsets? contentMargin = EdgeInsets.zero,
    IgnorePointerType? barrierIgnorePointerType,
    TranslationType? translationType,
    //--
    ArrowLayoutChildOffsetCallback? childOffsetCallback,
  }) {
    return showArrowPopupRoute(
      body,
      anchorKey: anchorKey,
      anchorRect: anchorRect,
      anchorChild: anchorChild,
      rootNavigator: rootNavigator,
      backgroundColor: backgroundColor,
      animate: animate,
      showArrow: false,
      contentMargin: contentMargin,
      contentPadding: contentPadding,
      radius: radius,
      barriersColor: barriersColor,
      translationType: translationType,
      barrierIgnorePointerType: barrierIgnorePointerType,
      childOffsetCallback:
          childOffsetCallback ??
          (anchorRect, childRect) {
            Alignment bodyAlign;
            if (alignment != null) {
              bodyAlign = alignment;
            } else {
              final anchorCx = anchorRect.center.dx;
              final anchorCy = anchorRect.center.dy;
              final screenCx = $screenWidth / 2;
              final screenCy = $screenHeight / 2;
              if (anchorCx < screenCx) {
                if (anchorCy < screenCy) {
                  //锚点在屏幕左上
                  bodyAlign = Alignment.topRight;
                } else {
                  //锚点在屏幕左下
                  bodyAlign = Alignment.bottomRight;
                }
              } else {
                if (anchorCy < screenCy) {
                  //锚点在屏幕右上
                  bodyAlign = Alignment.topLeft;
                } else {
                  //锚点在屏幕右下
                  bodyAlign = Alignment.bottomLeft;
                }
              }
            }
            if (bodyAlign == Alignment.topLeft) {
              return Offset(
                anchorRect.left - childRect.w - bodyMargin,
                anchorRect.top,
              );
            } else if (bodyAlign == Alignment.topCenter) {
              return Offset(
                anchorRect.center.dx - childRect.w / 2,
                anchorRect.top - childRect.h - bodyMargin,
              );
            } else if (bodyAlign == Alignment.topRight) {
              return Offset(anchorRect.right + bodyMargin, anchorRect.top);
            } else if (bodyAlign == Alignment.centerRight) {
              return Offset(
                anchorRect.right + bodyMargin,
                anchorRect.center.dy - childRect.h / 2,
              );
            } else if (bodyAlign == Alignment.bottomRight) {
              return Offset(
                anchorRect.right + bodyMargin,
                anchorRect.bottom - childRect.h,
              );
            } else if (bodyAlign == Alignment.bottomCenter) {
              return Offset(
                anchorRect.center.dx - childRect.w / 2,
                anchorRect.bottom + bodyMargin,
              );
            } else if (bodyAlign == Alignment.bottomLeft) {
              return Offset(
                anchorRect.left - childRect.w - bodyMargin,
                anchorRect.bottom - childRect.h,
              );
            } else if (bodyAlign == Alignment.centerLeft) {
              return Offset(
                anchorRect.left - childRect.w - bodyMargin,
                anchorRect.centerY - childRect.h / 2,
              );
            }
            return Offset(anchorRect.right + 8, anchorRect.top);
          },
    );
  }

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
    GlobalKey? anchorKey,
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
    TranslationType? translationType,
    //--
    ArrowLayoutChildOffsetCallback? childOffsetCallback,
  }) async {
    final that = this;
    final navigator = Navigator.of(this, rootNavigator: rootNavigator);
    final ancestor = navigator.context.findRenderObject();
    anchorRect ??= anchorChild?.findRenderObject()?.getGlobalBounds(ancestor);
    anchorRect ??= findRenderObject()?.getGlobalBounds(ancestor) ?? Rect.zero;
    final globalTheme = GlobalTheme.of(this);
    return navigator.push(
      ArrowPopupRoute(
        child: child /*AnchorLocationLayout(
          anchor: that,
          anchorKey: anchorKey,
          anchorAncestor: ancestor,
          onAnchorUnmount: () {
            navigator.pop();
          },
          child: child,
        )*/,
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
        translationType: translationType,
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
