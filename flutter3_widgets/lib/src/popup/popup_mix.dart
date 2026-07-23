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
part 'popup_container_dialog.dart';

/// 弹窗路由扩展
extension PopupEx on BuildContext {
  /// 在指定锚点位置显示一个弹窗路由[PopupRoute]
  ///
  /// - [targetAnchor]对齐锚点的什么位置
  /// - [followerAnchor]弹窗需要对齐锚点的哪个方向
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
    double? edgeMargin /*距离容器的边界距离*/,
    //--
    Alignment targetAnchor = .topRight /*对齐锚点的什么位置*/,
    Alignment? popupPreferredFollowerAlignment /*优先对齐方式*/,
    Alignment? followerAnchor /*自身的什么位置*/,
    Offset alignmentOffset = .zero /*对齐后的偏移*/,
    bool matchAnchorSize = false /*是否撑满锚点的宽度大小*/,
    Offset? matchAnchorSizeOffset /*[matchAnchorSize]时的大小补偿*/,
    //--
    @defInjectMark Color? backgroundColor,
    double? radius,
    bool animate = true,
    Color? barriersColor = Colors.transparent,
    EdgeInsets? contentPadding,
    EdgeInsets? contentMargin,
    IgnorePointerType? barrierIgnorePointerType,
    TranslationType? translationType,
    //--
    ArrowLayoutChildOffsetCallback? childOffsetCallback,
  }) {
    if (matchAnchorSize) {
    } else {
      edgeMargin ??= kX;
      contentPadding ??= const EdgeInsets.all(kS);
      contentMargin ??= EdgeInsets.zero;
    }
    popupPreferredFollowerAlignment ??= body
        .getWidgetPopupPreferredFollowerAlignment();
    final navigator = Navigator.of(this, rootNavigator: rootNavigator);
    final parentSize = navigator.context.findRenderObject()?.renderSize;
    final parentWidth = parentSize?.width ?? $screenWidth;
    final parentHeight = parentSize?.height ?? $screenHeight;
    return showArrowPopupRoute(
      body,
      anchorKey: anchorKey,
      anchorRect: anchorRect,
      anchorChild: anchorChild,
      rootNavigator: rootNavigator,
      backgroundColor: backgroundColor,
      animate: animate,
      showArrow: false,
      matchAnchorSize: matchAnchorSize,
      matchAnchorSizeOffset: matchAnchorSizeOffset,
      contentMargin: contentMargin,
      contentPadding: contentPadding,
      radius: radius,
      barriersColor: barriersColor,
      translationType: translationType,
      barrierIgnorePointerType: barrierIgnorePointerType,
      childOffsetCallback:
          childOffsetCallback ??
          (anchorRect, childRect) {
            Alignment bodyFollowerAlign;
            //debugger();
            if (followerAnchor != null) {
              bodyFollowerAlign = followerAnchor;
            } else if (popupPreferredFollowerAlignment != null) {
              bodyFollowerAlign = popupPreferredFollowerAlignment;
            } else {
              final anchorCx = anchorRect.center.dx;
              final anchorCy = anchorRect.center.dy;
              final screenCx = $screenWidth / 2;
              final screenCy = $screenHeight / 2;
              if (anchorCx < screenCx) {
                if (anchorCy < screenCy) {
                  //锚点在屏幕左上
                  bodyFollowerAlign = Alignment.topRight;
                } else {
                  //锚点在屏幕左下
                  bodyFollowerAlign = Alignment.bottomRight;
                }
              } else {
                if (anchorCy < screenCy) {
                  //锚点在屏幕右上
                  bodyFollowerAlign = Alignment.topLeft;
                } else {
                  //锚点在屏幕右下
                  bodyFollowerAlign = Alignment.bottomLeft;
                }
              }
            }

            if (followerAnchor == null &&
                popupPreferredFollowerAlignment != null) {
              if (bodyFollowerAlign.isTop &&
                  anchorRect.bottom + childRect.height + (edgeMargin ?? 0) >
                      parentHeight) {
                //朝底部显示, 并且移除了, 则翻转显示
                bodyFollowerAlign = bodyFollowerAlign.flipVertical;
                targetAnchor = targetAnchor.flipVertical;
              } else if (bodyFollowerAlign.isLeft &&
                  anchorRect.right + childRect.width + (edgeMargin ?? 0) >
                      parentWidth) {
                bodyFollowerAlign = bodyFollowerAlign.flipHorizontal;
                targetAnchor = targetAnchor.flipHorizontal;
              }
            }
            return AlignmentAnchorLayout.getFollowerAlignmentOffset(
              anchorRect: anchorRect,
              parentSize: Size(parentWidth, parentHeight),
              childSize: childRect.size,
              targetAnchor: targetAnchor,
              followerAnchor: bodyFollowerAlign,
              alignmentOffset: alignmentOffset,
              edgeOffset: edgeMargin == null
                  ? null
                  : Offset(edgeMargin, edgeMargin),
            );
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
  /// - [ArrowPopupRoute] -> [PopupRoute] 路由
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
    bool matchAnchorSize = false /*是否撑满锚点的宽度大小*/,
    Offset? matchAnchorSizeOffset /*[matchAnchorSize]时的大小补偿*/,
    //--
    @defInjectMark Color? backgroundColor,
    double? radius,
    Color? arrowColor,
    bool showArrow = true,
    bool animate = true,
    Color? barriersColor,
    AxisDirection? arrowDirection,
    double arrowDirectionMinOffset = 15,
    EdgeInsets? contentPadding = const EdgeInsets.all(kH),
    EdgeInsets? contentMargin,
    IgnorePointerType? barrierIgnorePointerType,
    TranslationType? translationType,
    //--
    ArrowLayoutChildOffsetCallback? childOffsetCallback,
  }) async {
    //debugger();
    if (matchAnchorSize) {
      /*contentPadding ??= const EdgeInsets.all(kH);*/
      /*contentMargin ??= const EdgeInsets.all(kX); */
    } else {
      /*contentPadding ??= const EdgeInsets.all(kH);*/
      contentMargin ??= const EdgeInsets.all(kX);
    }

    final that = this;
    final navigator = Navigator.of(that, rootNavigator: rootNavigator);
    final ancestor = navigator.context.findRenderObject();
    anchorRect ??= anchorChild?.findRenderObject()?.getGlobalBounds(ancestor);
    anchorRect ??= findRenderObject()?.getGlobalBounds(ancestor) ?? Rect.zero;
    final globalTheme = GlobalTheme.of(that);
    return navigator.push(
      ArrowPopupRoute(
        child: matchAnchorSize
            ? child.size(
                width: anchorRect.width + (matchAnchorSizeOffset?.dx ?? 0),
              )
            : child /*AnchorLocationLayout(
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
  ///
  /// - [OverlayEx.showOverlay]
  ///
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
    bool rootOverlay = false,
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
    Overlay.of(this, rootOverlay: rootOverlay).insert(overlayEntry);
    return overlayEntry;
  }
}
