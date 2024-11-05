library flutter3_app;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_app/assets_generated/assets.gen.dart';
import 'package:flutter3_app/src/mode/app_version_bean.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter_android_package_installer/flutter_android_package_installer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_move_task_back/flutter_move_task_back.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent_plus/receive_sharing_intent_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;

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
part 'src/android_app.dart';
part 'src/mobile_ex.dart';
part 'src/pages/app_update_dialog.dart';
part 'src/receive/receive_intent.dart';
part 'src/platform/permissions.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///
/// [beforeAction] 启动之前初始化, 请在此进行数据库表注册[registerIsarCollection]
/// [afterAction] 启动之后初始化
/// [zonedGuarded] 决定是否使用[runZonedGuarded]进行区域异常捕获,
/// [onZonedError] .[runZonedGuarded]中的异常回调
@entryPoint
@initialize
@callPoint
Future runGlobalApp(
  Widget app, {
  FutureVoidAction? beforeAction,
  FutureVoidAction? afterAction,
  bool zonedGuarded = true,
  void Function(Object error, StackTrace stack)? onZonedError,
}) async {
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

  // FlutterError.onError
  wrapFlutterOnError((FlutterErrorDetails details) {
    "Flutter发生一个错误↓".writeToErrorLog();
    details.exceptionAsString().writeToErrorLog();
    "错误详情↓\n${dumpErrorToString(details)}".writeToErrorLog();
    //FlutterError.dumpErrorToConsole(details);
  });
  // PlatformDispatcher.onError
  wrapPlatformDispatcherOnError((error, stack) {
    "Platform发生一个错误↓".writeToErrorLog();
    final details = FlutterErrorDetails(exception: error, stack: stack);
    details.exceptionAsString().writeToErrorLog();
    "错误详情↓\n${dumpErrorToString(details)}".writeToErrorLog();
    return false;
  });

  //ErrorWidget.builder = ;

  //runApp
  Future realRun() async {
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
  }

  if (!zonedGuarded) {
    return await realRun();
  }

  return runZonedGuarded(realRun, (error, stack) {
    "Zoned未捕捉的异常:↓".writeToErrorLog();
    error.writeToErrorLog(level: L.none);
    stack.toString().writeToErrorLog(level: L.none);
    assert(() {
      printError(error, stack);
      return true;
    }());
    onZonedError?.call(error, stack);
  });
}

/// 包裹[FlutterError.onError]处理, 保持旧逻辑不变
void wrapFlutterOnError([FlutterExceptionHandler? onErrorHandler]) {
  final oldOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    oldOnError?.call(details);
    onErrorHandler?.call(details);
  };
}

/// 包裹[PlatformDispatcher.instance.onError]处理, 保持旧逻辑不变
void wrapPlatformDispatcherOnError([ErrorCallback? onErrorCallback]) {
  final oldOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    bool handle = false;
    handle = oldOnError?.call(error, stack) ?? handle;
    handle = onErrorCallback?.call(error, stack) ?? handle;
    return handle;
  };
}

/// [DebugPage]
@initialize
Future _initDebugLastInfo() async {
  $compliance.wait((context, agree) async {
    if (agree) {
      final packageInfo = await $platformPackageInfo;
      final deviceInfo = await $platformDeviceInfo;
      final deviceInfoData = deviceInfo.data..remove("systemFeatures");

      //widget
      final textStyle = GlobalConfig.def.globalTheme.textPlaceStyle;
      DebugPage.debugLastWidgetBuilderList.add((_) =>
          packageInfo.text(textAlign: TextAlign.center, style: textStyle));
      DebugPage.debugLastWidgetBuilderList.add((_) =>
          deviceInfoData.text(textAlign: TextAlign.center, style: textStyle));
      DebugPage.debugLastWidgetBuilderList.add((_) => $appSettingBean
          .toString()
          .text(textAlign: TextAlign.center, style: textStyle));

      //string
      DebugPage.debugLastCopyStringBuilderList
          .add((_) => stringBuilder((builder) {
                builder.appendLine("$packageInfo");
                builder.append("$deviceInfoData");
                builder.append($appSettingBean.toString());
              }));
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
  //调试信息
  checkOrShowNavigatorRouteOverlay(context);
}

/// [NavigatorRouteOverlay]
@entryPoint
void checkOrShowNavigatorRouteOverlay([BuildContext? context]) {
  context ??= GlobalConfig.def.globalAppContext;
  if (context != null && isDebugFlag) {
    NavigatorRouteOverlay.showNavigatorRouteOverlay(context);
  }
}

/// [loadAssetSvgWidget]
Widget loadAppSvgWidget(
  String key, {
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
}) =>
    loadAssetSvgWidget(
      key,
      package: "flutter3_app",
      tintColor: tintColor,
      colorFilter: colorFilter,
      size: size,
      width: width,
      height: height,
      fit: fit,
    );

/// [isDebug]
/// [CoreKeys.isDebugFlag]
bool get isDebugFlag =>
    isDebugFlavor ||
    isDebugFlagDevice ||
    (GlobalConfig.def.isDebugFlagFn?.call() ?? $coreKeys.isDebugFlag);
