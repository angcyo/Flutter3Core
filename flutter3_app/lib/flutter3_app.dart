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

import 'src/mode/app_setting_bean.dart';

export 'package:device_info_plus/device_info_plus.dart';
export 'package:flutter3_core/flutter3_core.dart';
export 'package:flutter3_pub/flutter3_pub.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:share_plus/share_plus.dart';

export 'src/mode/app_setting_bean.dart';
export 'src/mode/app_version_bean.dart';

part 'src/app_ex.dart';
part 'src/app_info_interceptor.dart';
part 'src/app_log.dart';
part 'src/app_notifications.dart';
part 'src/app_swiper_ex.dart';
part 'src/mobile_ex.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///
@entryPoint
@initialize
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
    details.exceptionAsString().writeToErrorLog();
    dumpErrorToString(details).writeToErrorLog();
    oldOnError?.call(details);
    //FlutterError.dumpErrorToConsole(details);
  };

  //ErrorWidget.builder = ;

  runZonedGuarded(() async {
    ensureInitialized();
    //key-value
    await initHive();

    //网络请求基础信息拦截器
    rDio.addInterceptor(AppInfoInterceptor());

    "开始启动[main]:${platformDispatcher.defaultRouteName}"
        .writeToLog(level: L.info);
    await initFlutter3Core();
    AppLifecycleLog.install();

    //debug info
    _initDebugLastInfo();

    //--
    await beforeAction?.call();
    //open isar
    await initIsar();
    runApp(GlobalApp(app: app.wrapGlobalViewModelProvider()));
    await afterAction?.call();

    //--
    "启动完成:${lTime.time()}".writeToLog(level: L.info);
  }, (error, stack) {
    "未捕捉的异常:↓".writeToErrorLog();
    error.writeToErrorLog(level: L.none);
    stack.toString().writeToErrorLog(level: L.none);
    printError(error, stack);
  });
}

/// [DebugPage]
@initialize
Future _initDebugLastInfo() async {
  $compliance.wait((agree) async {
    if (agree) {
      final packageInfo = await platformPackageInfo;
      final deviceInfo = await platformDeviceInfo;
      final deviceInfoData = deviceInfo.data..remove("systemFeatures");
      DebugPage.debugLastWidgetList.add(packageInfo.text(
          textAlign: TextAlign.center,
          style: GlobalConfig.def.globalTheme.textPlaceStyle));
      DebugPage.debugLastWidgetList.add(deviceInfoData.text(
          textAlign: TextAlign.center,
          style: GlobalConfig.def.globalTheme.textPlaceStyle));

      DebugPage.debugLastCopyString = stringBuilder((builder) {
        builder.appendLine("$packageInfo");
        builder.append("$deviceInfoData");
      });
    }
  });
}

/// 在具有[BuildContext]时, 进行首次初始化
/// [MaterialApp.onGenerateTitle]中的[BuildContext]拿不到[Navigator].[Overlay]
/// 推荐在[MaterialApp.home]中使用[Builder]小部件初始化
@entryPoint
@initialize
Future initGlobalAppAtContext(BuildContext context) async {
  //debugger();
  if (GlobalConfig.def.globalAppContext == context) {
    return;
  }
  GlobalConfig.def.globalAppContext = context;
  if (isDebugFlag) {
    NavigatorRouteOverlay.showNavigatorRouteOverlay(context);
  }
}

/// [isDebug]
/// [CoreKeys.isDebugFlag]
bool get isDebugFlag =>
    isDebugFlagDevice ||
    (GlobalConfig.def.isDebugFlagFn?.call() ?? $coreKeys.isDebugFlag);
