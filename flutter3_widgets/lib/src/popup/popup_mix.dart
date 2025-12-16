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
  /// 在指定锚点位置显示一个弹窗路由[PopupRoute]
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
    double? edgeMargin /*距离容器的边界距离*/,
    //--
    Alignment? alignment /*对齐方式*/,
    bool offsetAlignment = false /*根据[alignment]是否偏移自身的宽高*/,
    bool matchAnchorSize = false /*是否撑满锚点的宽度大小*/,
    Offset? matchAnchorSizeOffset /*[matchAnchorSize]时的大小补偿*/,
    //--
    Color? backgroundColor,
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
            //检查是否空间充足
            if (alignment == .bottomLeft ||
                alignment == .bottomRight ||
                alignment == .bottomCenter) {
              //底部剩余空间
              //debugger();
              final bottomSpace = parentHeight - anchorRect.bottom;
              if (bottomSpace < childRect.height) {
                //底部空间不够
                if (alignment == .bottomLeft) {
                  bodyAlign = Alignment.topLeft;
                } else if (alignment == .bottomRight) {
                  bodyAlign = Alignment.topRight;
                } else if (alignment == .bottomCenter) {
                  bodyAlign = Alignment.topCenter;
                }
              }
            } else if (alignment == .topLeft ||
                alignment == .topRight ||
                alignment == .topCenter) {
              //顶部剩余空间
              final topSpace = anchorRect.top;
              if (topSpace < childRect.height) {
                if (alignment == .topLeft) {
                  bodyAlign = Alignment.bottomLeft;
                } else if (alignment == .topRight) {
                  bodyAlign = Alignment.bottomRight;
                } else if (alignment == .topCenter) {
                  bodyAlign = Alignment.bottomCenter;
                }
              }
            }
            //MARK: - offset
            //debugger();
            double offsetX = anchorRect.right + bodyMargin;
            double offsetY = anchorRect.top;
            if (bodyAlign == Alignment.topLeft) {
              offsetX = anchorRect.left - childRect.w - bodyMargin;
              offsetY = anchorRect.top;
              if (offsetAlignment) {
                offsetY -= childRect.height + bodyMargin;
              }
            } else if (bodyAlign == Alignment.topCenter) {
              offsetX = anchorRect.center.dx - childRect.w / 2;
              offsetY = anchorRect.top - childRect.h - bodyMargin;
              if (offsetAlignment) {
                offsetY -= childRect.height + bodyMargin;
              }
            } else if (bodyAlign == Alignment.topRight) {
              offsetX = anchorRect.right + bodyMargin;
              offsetY = anchorRect.top;
              if (offsetAlignment) {
                offsetY -= childRect.height + bodyMargin;
              }
            } else if (bodyAlign == Alignment.centerRight) {
              offsetX = anchorRect.right + bodyMargin;
              offsetY = anchorRect.center.dy - childRect.h / 2;
            } else if (bodyAlign == Alignment.bottomRight) {
              offsetX = anchorRect.right + bodyMargin;
              offsetY = anchorRect.bottom - childRect.h - bodyMargin;
              if (offsetAlignment) {
                offsetY += childRect.h + bodyMargin;
              }
            } else if (bodyAlign == Alignment.bottomCenter) {
              offsetX = anchorRect.center.dx - childRect.w / 2;
              offsetY = anchorRect.bottom + bodyMargin;
              if (offsetAlignment) {
                offsetY += anchorRect.height + childRect.h;
              }
            } else if (bodyAlign == Alignment.bottomLeft) {
              offsetX = anchorRect.left - childRect.w - bodyMargin;
              offsetY = anchorRect.bottom - childRect.h;
              if (offsetAlignment) {
                offsetY += anchorRect.height + childRect.h;
              }
            } else if (bodyAlign == Alignment.centerLeft) {
              offsetX = anchorRect.left - childRect.w - bodyMargin;
              offsetY = anchorRect.centerY - childRect.h / 2;
            }
            //debugger();
            final offsetMargin = edgeMargin ?? 0;
            return Offset(
              childRect.width >= parentWidth
                  ? 0
                  : offsetX.clamp(
                      offsetMargin,
                      parentWidth - offsetMargin - childRect.width,
                    ),
              childRect.height >= parentHeight
                  ? 0
                  : offsetY.clamp(
                      offsetMargin,
                      parentHeight - offsetMargin - childRect.height,
                    ),
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
    Color? backgroundColor,
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
