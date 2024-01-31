library flutter3_basics;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:hsluv/hsluvcolor.dart';
import 'package:intl/intl.dart' as intl;
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

export 'package:async/async.dart';
export 'package:clock/clock.dart';
export 'package:collection/collection.dart';
export 'package:equatable/equatable.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:hsluv/hsluv.dart';
export 'package:matrix4_transform/matrix4_transform.dart';
export 'package:meta/meta.dart';
export 'package:nil/nil.dart';

export 'src/component/dart_scope_functions.dart';
export 'src/component/rnd.dart';

part 'src/basics/basics.dart';

part 'src/basics/basics_animation.dart';

part 'src/basics/basics_date_time.dart';

part 'src/basics/basics_decoration.dart';

part 'src/basics/basics_event.dart';

part 'src/basics/basics_ex.dart';

part 'src/basics/basics_image.dart';

part 'src/basics/basics_math.dart';

part 'src/basics/basics_painting.dart';

part 'src/basics/basics_path.dart';

part 'src/basics/basics_render.dart';

part 'src/basics/basics_ui.dart';

part 'src/basics/custom_page_route.dart';

part 'src/component/async_operation.dart';

part 'src/component/custom_painter.dart';

part 'src/component/future_cancel.dart';

part 'src/component/matrix_ex.dart';

part 'src/component/r_exception.dart';

part 'src/component/request_page.dart';

part 'src/component/stack_list.dart';

part 'src/debug/debug.dart';

part 'src/debug/navigator_observer_log.dart';

part 'src/debug/state_log.dart';

part 'src/global/global.dart';

part 'src/global/global_config.dart';

part 'src/global/global_constants.dart';

part 'src/global/global_overlays.dart';

part 'src/global/global_theme.dart';

part 'src/global/overlay/overlay_animation.dart';

part 'src/global/overlay/overlay_manage.dart';

part 'src/global/overlay/overlay_notification.dart';

part 'src/l.dart';

part 'src/meta/meta.dart';

part 'src/overlay/loading_indicator.dart';

part 'src/overlay/loading_overlay.dart';

part 'src/overlay/route_will_pop_scope.dart';

part 'src/utils/filesize.dart';

part 'src/utils/frame_split.dart';

part 'src/utils/l_time.dart';

part 'src/utils/list_utils.dart';

part 'src/utils/string_utils.dart';

part 'src/utils/text_span_builder.dart';

part 'src/widgets/data_provider.dart';

part 'src/widgets/empty.dart';

part 'src/widgets/value_listener.dart';

/// 类型重定义
typedef UiImage = ui.Image;
typedef UiImageFilter = ui.ImageFilter;
typedef UiColorFilter = ui.ColorFilter;
typedef UiGradient = ui.Gradient;

/// 判断[value]是否为空
bool isNullOrEmpty(Object? value) {
  if (value == null) {
    return true;
  }
  if (value is String) {
    return value.isEmpty;
  }
  if (value is Iterable) {
    return value.isEmpty;
  }
  if (value is Map) {
    return value.isEmpty;
  }
  return false;
}

/// 将所有非空对象转换为字符串
/// [separator] 分隔符
String join(String separator,
    [Object? part1,
    Object? part2,
    Object? part3,
    Object? part4,
    Object? part5,
    Object? part6,
    Object? part7,
    Object? part8,
    Object? part9,
    Object? part10,
    Object? part11,
    Object? part12,
    Object? part13,
    Object? part14,
    Object? part15]) {
  return [
    part1,
    part2,
    part3,
    part4,
    part5,
    part6,
    part7,
    part8,
    part9,
    part10,
    part11,
    part12,
    part13,
    part14,
    part15
  ].whereNotNull().join(separator);
}
