library flutter3_basics;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:hsluv/hsluvcolor.dart';
import 'package:intl/intl.dart' as intl;
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:meta/meta_meta.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:bidi/bidi.dart' as bidi;

import 'assets_generated/assets.gen.dart';

export 'package:async/async.dart';
export 'package:clock/clock.dart';
export 'package:collection/collection.dart';
export 'package:equatable/equatable.dart';
export 'package:fixnum/fixnum.dart';
export 'package:flutter_isolate/flutter_isolate.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:hsluv/hsluv.dart';
export 'package:matrix4_transform/matrix4_transform.dart';
export 'package:meta/meta.dart';
export 'package:nil/nil.dart';
export 'package:time/time.dart';
export 'package:vector_math/vector_math_64.dart'
    show Vector, Vector2, Vector3, Vector4, Quaternion, Matrix3, Matrix4;

export 'src/component/dart_scope_functions.dart';
export 'src/component/rnd.dart';
export 'src/utils/hex.dart';

//export 'package:leak_tracker/leak_tracker.dart';

part 'l10n/intl_ex.dart';

part 'src/basics/basics.dart';

part 'src/basics/basics_animation.dart';

part 'src/basics/basics_date_time.dart';

part 'src/basics/basics_decoration.dart';

part 'src/basics/basics_event.dart';

part 'src/basics/basics_ex.dart';

part 'src/basics/basics_file.dart';

part 'src/basics/basics_image.dart';

part 'src/basics/basics_layout.dart';

part 'src/basics/basics_math.dart';

part 'src/basics/basics_painting.dart';

part 'src/basics/basics_path.dart';

part 'src/basics/basics_render.dart';

part 'src/basics/basics_ui.dart';

part 'src/basics/custom_page_route.dart';

part 'src/basics/matrix_ex.dart';

part 'src/basics/system.dart';

part 'src/component/async_operation.dart';

part 'src/component/compliance.dart';

part 'src/component/batch_completer.dart';

part 'src/component/custom_painter.dart';

part 'src/component/fps.dart';

part 'src/component/future_cancel.dart';

part 'src/component/id_gen.dart';

part 'src/component/live_stream_controller.dart';

part 'src/component/mutex_key.dart';

part 'src/component/r_exception.dart';

part 'src/component/request_page.dart';

part 'src/component/stack_list.dart';

part 'src/component/string_cache.dart';

part 'src/component/undo_manager.dart';

part 'src/component/version_matcher.dart';

part 'src/component/app_lifecycle_mixin.dart';

part 'src/debug/debug.dart';

part 'src/debug/debug_keys.dart';

part 'src/debug/navigator_observer_log.dart';

part 'src/debug/state_log.dart';

part 'src/global/global.dart';

part 'src/global/global_config.dart';

part 'src/global/global_constants.dart';

part 'src/global/global_overlays.dart';

part 'src/global/global_theme.dart';

part 'src/global/global_typedef.dart';

part 'src/global/overlay/overlay_animation.dart';

part 'src/global/overlay/overlay_manage.dart';

part 'src/global/overlay/overlay_notification.dart';

part 'src/l.dart';

part 'src/meta/meta.dart';

part 'src/overlay/loading.dart';

part 'src/overlay/loading_indicator.dart';

part 'src/overlay/loading_overlay.dart';

part 'src/overlay/progress_bar.dart';

part 'src/overlay/rotate_animated.dart';

part 'src/overlay/route_will_pop_scope.dart';

part 'src/overlay/stroke_loading.dart';

part 'src/unit/unit.dart';

part 'src/utils/bytes.dart';

part 'src/utils/file_size.dart';

part 'src/utils/frame_split.dart';

part 'src/utils/l_time.dart';

part 'src/utils/list_utils.dart';

part 'src/utils/process_util.dart';

part 'src/utils/string_utils.dart';

part 'src/utils/text_span_builder.dart';

part 'src/widgets/data_provider.dart';

part 'src/widgets/empty.dart';

part 'src/widgets/path_widget.dart';

part 'src/widgets/touch_detector_widget.dart';

part 'src/widgets/value_listener.dart';

/// 类型重定义
typedef UiImage = ui.Image;
typedef UiPath = ui.Path;
typedef UiColor = ui.Color;
typedef UiOffset = ui.Offset;
typedef UiSize = ui.Size;
typedef UiRect = ui.Rect;
typedef UiTextStyle = ui.TextStyle;
typedef UiImageByteFormat = ui.ImageByteFormat;
typedef UiPixelFormat = ui.PixelFormat;
typedef UiImageFilter = ui.ImageFilter;
typedef UiColorFilter = ui.ColorFilter;
typedef UiGradient = ui.Gradient;
typedef UiPlatformDispatcher = ui.PlatformDispatcher;
typedef UiLocale = ui.Locale;
typedef UiPaintingStyle = ui.PaintingStyle;
typedef AnimateAction = void Function(AnimationController controller);
typedef NumFormat = String? Function(num? number);

/// [GestureTapCallback]
typedef GestureContextTapCallback = void Function(BuildContext contet);

///[isNullOrEmpty]
bool isNil(dynamic value) => isNullOrEmpty(value);

/// 这个数字的绝对值。
int abs(int value) => value.abs();

/// 浮点数的绝对值
double fabs(double value) => value.abs();

/// 判断[value]是否为空
bool isNullOrEmpty(dynamic value) {
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

/// 情感状态: 加载失败的图片资源key
String get libAssetsStateLoadErrorKey => Assets.png.stateLoadError.keyName;

/// 情感状态: 没有数据的图片资源key
String get libAssetsStateNoDataKey => Assets.png.stateNoData.keyName;

/// 退出应用
void exitApp() {
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
