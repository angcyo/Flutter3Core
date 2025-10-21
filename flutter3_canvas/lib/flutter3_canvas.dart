library flutter3_canvas;

import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';

part 'src/canvas.dart';
part 'src/canvas_delegate.dart';
part 'src/canvas_ex.dart';
part 'src/component/canvas_bounds_event_component.dart';
part 'src/component/canvas_element_widget.dart';
part 'src/component/component.dart';
part 'src/component/control_limit.dart';
part 'src/component/canvas_overlay_component.dart';
part 'src/component/painter_size_handler.dart';
part 'src/component/painter_touch_spot_handler.dart';
part 'src/core/canvas_axis_manager.dart';
part 'src/core/canvas_content_manager.dart';
part 'src/core/canvas_content_template.dart';
part 'src/core/canvas_element_control_manager.dart';
part 'src/core/canvas_element_manager.dart';
part 'src/core/canvas_event_manager.dart';
part 'src/core/canvas_follow_manager.dart';
part 'src/core/canvas_multi_manager.dart';
part 'src/core/canvas_paint_manager.dart';
part 'src/core/canvas_style.dart';
part 'src/core/canvas_undo_manager.dart';
part 'src/core/canvas_view_box.dart';
part 'src/core/canvas_key_manager.dart';
part 'src/core/canvas_menu_manager.dart';
part 'src/core/control/element_adsorb.dart';
part 'src/core/control/element_control.dart';
part 'src/core/control/element_menu.dart';
part 'src/event/canvas_event.dart';
part 'src/event/canvas_notify.dart';
part 'src/painter/base_char_painter.dart';
part 'src/painter/base_text_painter.dart';
part 'src/painter/element_painter.dart';
part 'src/painter/image_element_painter.dart';
part 'src/painter/painter.dart';
part 'src/painter/path_element_painter.dart';
part 'src/painter/path_simulation_painter.dart';
part 'src/painter/text_element_painter.dart';
part 'src/painter/widget_element_painter.dart';
part 'src/tests/tests_canvas_follow.dart';

Widget canvasSvgWidget(
  String key, {
  String? package = 'flutter3_canvas',
  String? prefix = kDefAssetsSvgPrefix,
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
}) =>
    SvgPicture.asset(key.ensurePackagePrefix(package, prefix).transformKey(),
        semanticsLabel: key,
        colorFilter: colorFilter ?? tintColor?.toColorFilter(),
        width: width,
        height: height,
        fit: fit);

Widget canvasLockWidget({
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
}) =>
    canvasSvgWidget(
      'canvas_lock_point.svg',
      tintColor: tintColor,
      colorFilter: colorFilter,
      width: width,
      height: height,
      fit: fit,
    );

Widget canvasUnlockWidget({
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
}) =>
    canvasSvgWidget(
      'canvas_unlock_point.svg',
      tintColor: tintColor,
      colorFilter: colorFilter,
      width: width,
      height: height,
      fit: fit,
    );
