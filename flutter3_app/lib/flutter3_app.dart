library flutter3_app;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_app/test_app.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

export 'package:device_info_plus/device_info_plus.dart';
export 'package:flutter3_basics/flutter3_basics.dart';
export 'package:flutter3_core/flutter3_core.dart';
export 'package:flutter3_pub/flutter3_pub.dart';
export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:share_plus/share_plus.dart';

part 'src/app_ex.dart';

part 'src/app_info_interceptor.dart';

part 'src/app_log.dart';

part 'src/app_notifications.dart';

part 'src/app_swiper_ex.dart';

@callPoint
void runGlobalApp(Widget app) {
  /*if (isDebug) {
    io(() => testTime());
  }*/

  lTime.tick();

  var oldOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    l.e("发生一个错误:↓"..toErrorLogSync());
    l.e(details..toErrorLogSync());
    oldOnError?.call(details);
  };

  runZonedGuarded(() async {
    if (isDebug) {
      await testRunBefore();
    }
    ensureInitialized();

    //网络请求基础信息拦截器
    rDio.addInterceptor(AppInfoInterceptor());

    "开始启动[main]:${PlatformDispatcher.instance.defaultRouteName}".toLogSync();
    await initFlutter3Core();
    if (isDebug) {
      await testRunAfter();
    }
    AppLifecycleLog.install();
    runApp(GlobalApp(app: app.wrapGlobalViewModelProvider()));
    l.i("启动完成:${lTime.time()}"..toLogSync());
  }, (error, stack) {
    l.e("未捕捉的异常:↓"..toErrorLogSync());
    l.e(error..toErrorLogSync());
    l.e(stack.toString()..toErrorLogSync());
  });
}
