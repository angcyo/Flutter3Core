library flutter3_pub_core;

import 'dart:async';
import 'dart:developer';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_pub_core/src/marquee/marqueer.dart';
import 'package:flutter3_widgets/flutter3_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hiblob/flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:watch_it/watch_it.dart';

export 'package:easy_refresh/easy_refresh.dart';
export 'package:el_tooltip/el_tooltip.dart';
export 'package:get_it/get_it.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:rxdart/rxdart.dart';
export 'package:watch_it/watch_it.dart';

part 'src/go_router_ex.dart';
// @formatter:off

part 'src/marquee/marquee_ex.dart';
part 'src/refresh/easy_refresh_ex.dart';
part 'src/tooltip/el_tooltip_ex.dart';

// @formatter:on

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/5
///
/// get it
/// https://pub.dev/packages/get_it
///
/// ```
/// $get.registerSingleton<AppModel>(AppModel());
/// $get.registerLazySingleton<AppModel>(() => AppModel());
///
/// $get<AppModel>();
/// ```
/// [GetIt]
final $get = GetIt.instance;

/// watch it
/// ```
/// class MyWidget extends StatelessWidget with WatchItMixin {
///   @override
///   Widget build(BuildContext context) {
///     String country = watchValue((Model x) => x.country);
///     //String country = watchPropertyValue((Model x) => x.country);
///     ...
///   }
/// }
/// ```
///
/// [WatchItMixin]
/// [WatchItStatefulWidgetMixin]
///
/// [watchValue]
/// [watchStream]
/// [watchPropertyValue]
/// [watchFuture]
///
/// [GetIt]
final $di = di;

/// 保持屏幕常亮
void keepScreenOn([bool enable = true]) {
  if (enable) {
    WakelockPlus.enable().get((data, error) {
      debugger(when: !isDesktopOrWeb && error != null);
    });
  } else {
    WakelockPlus.disable().get((data, error) {
      debugger(when: !isDesktopOrWeb && error != null);
    });
  }
}

/// 关闭屏幕亮
void closeScreenOn() {
  WakelockPlus.disable().get((data, error) {
    debugger(when: error != null);
  });
}

@testPoint
void _test() {}

extension Flutter3PubCoreStringEx on String {
  /// 从任意字符串生成确定性的几何图形头像
  Widget hiblob({
    bool isCircle = true,
    double? size,
    String? semanticLabel,
    Backdrop? background,
    HiblobExpressionType? expressionType,
  }) {
    return Hiblob(
      name: this,
      size: size,
      semanticLabel: semanticLabel ?? this,
      options: HiblobOptions(
        background: background ?? (isCircle ? .circle : .squircle),
        expression:
            expressions.findFirst((e) => e.id == expressionType?.name) ?? love,
      ),
    );
  }
}

enum HiblobExpressionType {
  idle,
  happy,
  sad,
  mad,
  surprised,
  wink,
  sleepy,
  smug,
  unsure,
  scared,
  love,
  shy,
  sick,
  thinking,
  grin,
  frown,
}
