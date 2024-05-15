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
part 'arrow_popup_route.dart';

extension PopupEx on BuildContext {
  /// 在指定的[anchorRect]位置, 显示[ArrowPopupRoute]的[Widget]
  /// [anchorRect].[anchorChild]必须指定一个
  void showArrowPopup(
    Widget child, {
    Rect? anchorRect,
    BuildContext? anchorChild,
    Color? backgroundColor = Colors.white,
    Color arrowColor = Colors.white,
    bool showArrow = true,
    Color? barriersColor,
    AxisDirection? arrowDirection,
  }) {
    assert(anchorRect != null || anchorChild != null);
    anchorRect ??= anchorChild?.findRenderObject()?.getGlobalBounds();
    anchorRect ??= findRenderObject()?.getGlobalBounds();
    Navigator.of(this).push(
      ArrowPopupRoute(
        child: child,
        anchorRect: anchorRect!,
        backgroundColor: backgroundColor,
        arrowColor: arrowColor,
        showArrow: showArrow,
        arrowDirection: arrowDirection,
        barriersColor: barriersColor,
      ),
    );
  }
}
