library flutter3_basics;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

export 'package:async/async.dart';
export 'package:clock/clock.dart';
export 'package:collection/collection.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:intl/intl.dart';
export 'package:meta/meta.dart';

part 'src/basics/basics.dart';

part 'src/basics/basics_decoration.dart';

part 'src/basics/basics_ex.dart';

part 'src/basics/basics_image.dart';

part 'src/basics/basics_paint.dart';

part 'src/basics/basics_ui.dart';

part 'src/basics/custom_page_route.dart';

part 'src/component/stack_list.dart';

part 'src/debug/app_lifecycle_log.dart';

part 'src/debug/debug.dart';

part 'src/debug/navigator_observer_log.dart';

part 'src/debug/state_log.dart';

part 'src/global/global.dart';

part 'src/global/global_config.dart';

part 'src/global/global_overlays.dart';

part 'src/global/global_ui.dart';

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

part 'src/widgets/empty.dart';

/// 类型重定义
typedef UiImage = ui.Image;
typedef UiColorFilter = ui.ColorFilter;
typedef UiGradient = ui.Gradient;
