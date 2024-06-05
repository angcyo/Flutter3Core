library flutter3_app;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

export 'package:device_info_plus/device_info_plus.dart';
export 'package:flutter3_core/flutter3_core.dart';
export 'package:flutter3_pub/flutter3_pub.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:share_plus/share_plus.dart';

part 'src/app_ex.dart';
part 'src/app_info_interceptor.dart';
part 'src/app_log.dart';
part 'src/app_notifications.dart';
part 'src/app_swiper_ex.dart';
part 'src/mobile_ex.dart';

@callPoint
void runGlobalApp(
  Widget app, {
  FutureVoidAction? beforeAction,
  FutureVoidAction? afterAction,
}) {
  /*if (isDebug) {
    io(() => testTime());
  }*/

  lTime.tick();

  // 分享app日志
  GlobalConfig.def.shareAppLogFn = (context, data) async {
    await shareAppLog();
    return true;
  };

  // 分享数据
  GlobalConfig.def.shareDataFn = (context, data) async {
    try {
      if (data is File) {
        await data.path.shareFile(shareContext: context);
        return true;
      } else if (data is Uint8List) {
        await data.share(shareContext: context);
        return true;
      } else if (data is UiImage) {
        await data.share(shareContext: context);
        return true;
      } else if (data is String) {
        await data.share(shareContext: context);
        return true;
      }
      assert(() {
        l.w('不支持的分享数据类型:${data.runtimeType}');
        return true;
      }());
      return false;
    } catch (e) {
      assert(() {
        l.w(e);
        return true;
      }());
      reportError(e);
      return false;
    }
  };

  var oldOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    "发生一个错误:↓".writeToErrorLog();
    details.writeToErrorLog();
    oldOnError?.call(details);
  };

  runZonedGuarded(() async {
    ensureInitialized();

    //网络请求基础信息拦截器
    rDio.addInterceptor(AppInfoInterceptor());

    "开始启动[main]:${UiPlatformDispatcher.instance.defaultRouteName}"
        .writeToLog(level: L.info);
    await initFlutter3Core();
    AppLifecycleLog.install();

    await beforeAction?.call();
    await initIsar();
    runApp(GlobalApp(app: app.wrapGlobalViewModelProvider()));
    await afterAction?.call();

    "启动完成:${lTime.time()}".writeToLog(level: L.info);
  }, (error, stack) {
    "未捕捉的异常:↓".writeToErrorLog();
    error.writeToErrorLog(level: L.none);
    stack.toString().writeToErrorLog(level: L.none);
    printError(error, stack);
  });
}
