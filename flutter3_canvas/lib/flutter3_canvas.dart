library flutter3_canvas;

import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';

part 'src/axis/axis_manager.dart';
part 'src/canvas.dart';
part 'src/canvas_delegate.dart';
part 'src/canvas_listener.dart';
part 'src/component/canvas_bounds_event_component.dart';
part 'src/component/component.dart';
part 'src/component/control_limit.dart';
part 'src/core/canvas_element_control_manager.dart';
part 'src/core/canvas_element_manager.dart';
part 'src/core/canvas_event_manager.dart';
part 'src/core/canvas_paint_manager.dart';
part 'src/core/canvas_style.dart';
part 'src/core/canvas_undo_manager.dart';
part 'src/core/canvas_view_box.dart';
part 'src/core/control/element_control.dart';
part 'src/event/canvas_event.dart';
part 'src/event/canvas_notify.dart';
part 'src/painter/element_painter.dart';
part 'src/painter/image_element_painter.dart';
part 'src/painter/painter.dart';
part 'src/painter/path_element_painter.dart';
part 'src/painter/text_element_painter.dart';

Widget canvasSvgWidget(
  String key, {
  String? package = 'flutter3_canvas',
  String? prefix = 'assets/svg/',
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
}) =>
    SvgPicture.asset(key.ensurePackagePrefix(package, prefix),
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
