library flutter3_app;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_app/test_app.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

export 'package:device_info_plus/device_info_plus.dart';
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
part 'src/mobile_ex.dart';

@callPoint
void runGlobalApp(Widget app) {
  /*if (isDebug) {
    io(() => testTime());
  }*/

  lTime.tick();

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
    l.e("发生一个错误:↓"..writeToErrorLog());
    l.e(details..writeToErrorLog());
    oldOnError?.call(details);
  };

  runZonedGuarded(() async {
    if (isDebug) {
      await testRunBefore();
    }
    ensureInitialized();

    //网络请求基础信息拦截器
    rDio.addInterceptor(AppInfoInterceptor());

    "开始启动[main]:${ui.PlatformDispatcher.instance.defaultRouteName}"
        .writeToLog();
    await initFlutter3Core();
    if (isDebug) {
      await testRunAfter();
    }
    AppLifecycleLog.install();
    runApp(GlobalApp(app: app.wrapGlobalViewModelProvider()));
    l.i("启动完成:${lTime.time()}"..writeToLog());
  }, (error, stack) {
    l.e("未捕捉的异常:↓"..writeToErrorLog());
    l.e(error..writeToErrorLog());
    l.e(stack.toString()..writeToErrorLog());
  });
}
