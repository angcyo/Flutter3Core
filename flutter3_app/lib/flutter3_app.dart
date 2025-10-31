library flutter3_app;

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_app/assets_generated/assets.gen.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_pub/flutter3_pub.dart';
import 'package:flutter_android_package_installer/flutter_android_package_installer.dart';
import 'package:flutter_move_task_back/flutter_move_task_back.dart';
import 'package:flutter_uri_to_file/flutter_uri_to_file.dart' as uri_to_file;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent_plus/receive_sharing_intent_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'src/mode/lib_app_setting_bean.dart';
import 'src/mode/lib_app_version_bean.dart';

export 'package:device_info_plus/device_info_plus.dart';
export 'package:flutter3_core/flutter3_core.dart';
export 'package:flutter3_pub/flutter3_pub.dart';
export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:share_plus/share_plus.dart';

export 'src/mode/lib_app_setting_bean.dart';
export 'src/mode/lib_app_version_bean.dart';

part 'src/android_app.dart';
part 'src/app_ex.dart';
part 'src/app_info_interceptor.dart';
part 'src/app_log.dart';
part 'src/app_swiper_ex.dart';
part 'src/mobile_ex.dart';
part 'src/pages/app_update_dialog.dart';
part 'src/platform/permissions.dart';
part 'src/receive/receive_intent.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///
/// 使用此方法代替系统的[runApp]
///
/// [beforeAction] 启动之前初始化, 请在此进行数据库表注册[registerIsarCollection]
/// [afterAction] 启动之后初始化
/// [zonedGuarded] 决定是否使用[runZonedGuarded]进行区域异常捕获,
/// [onZonedError] .[runZonedGuarded]中的异常回调
///
@entryPoint
@initialize
@callPoint
Future runGlobalApp(
  Widget app, {
  //--
  FutureVoidAction? beforeAction,
  FutureVoidAction? afterAction,
  //--
  bool zonedGuarded = true,
  void Function(Object error, StackTrace stack)? onZonedError,
  //--
  bool useViewModelProvider = false,
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
    "Flutter发生一个错误[${details.exception.runtimeType}]↓".writeToErrorLog();
    details.exceptionAsString().writeToErrorLog();
    "错误详情↓\n${dumpErrorToString(details)}".writeToErrorLog();
    //FlutterError.dumpErrorToConsole(details);
  });
  // PlatformDispatcher.onError
  wrapPlatformDispatcherOnError((error, stack) {
    "Platform发生一个错误[${error.runtimeType}]↓".writeToErrorLog();
    final details = FlutterErrorDetails(exception: error, stack: stack);
    details.exceptionAsString().writeToErrorLog();
    "错误详情↓\n${dumpErrorToString(details)}".writeToErrorLog();
    return false;
  });

  //ErrorWidget.builder = ;

  //runApp
  Future realRun() async {
    Object? error;
    StackTrace? stack;

    ensureInitialized();
    "开始启动[${Platform.operatingSystem}][main]->${platformDispatcher.defaultRouteName}"
        .writeToLog(level: L.info);

    //debugger();
    //--
    await BuildConfig.initBuildConfig();
    //key-value
    try {
      await initHive();
    } catch (e, s) {
      error = e;
      stack = s;
      printError(e, s);
      debugger(when: isDebug);
    }

    //网络请求基础信息拦截器
    rDio.addInterceptor(AppInfoInterceptor());

    try {
      await initFlutter3Core();
    } catch (e, s) {
      error = e;
      stack = s;
      printError(e, s);
      debugger(when: isDebug);
    }
    AppLifecycleLog.install();

    //debug info
    _initDebugLastInfo();

    //--before
    try {
      await beforeAction?.call();
      await executeGlobalInitialize(before: true);
    } catch (e, s) {
      error = e;
      stack = s;
      printError(e, s);
      debugger(when: isDebug);
    }
    try {
      //open isar, 为了能在[beforeAction]中初始化外部数据库表结构
      await initIsar();
    } catch (e, s) {
      error = e;
      stack = s;
      printError(e, s);
      debugger(when: isDebug);
    }

    //app
    if (error != null) {
      app = ErrorWidget.builder(
        FlutterErrorDetails(exception: error, stack: stack, library: 'angcyo'),
      );
      if (!isDebug && error is RCoreException) {
        exitApp();
      }
    }
    //app
    runApp(
      GlobalApp(
        app: useViewModelProvider ? app.wrapGlobalViewModelProvider() : app,
      ),
    );
    //--after
    try {
      await afterAction?.call();
      await executeGlobalInitialize(after: true);
    } catch (e, s) {
      printError(e, s);
      debugger(when: isDebug);
      if (!isDebug && error is RCoreException) {
        exitApp();
      }
    }

    //--
    "启动完成[${Platform.resolvedExecutable}]:${lTime.time()}".writeToLog(
      level: L.info,
    );
  }

  if (!zonedGuarded) {
    return await realRun();
  }

  return runZonedGuarded(realRun, (error, stack) {
    "Zoned未捕捉的异常[${error.runtimeType}]:↓".writeToErrorLog();
    error.writeToErrorLog();
    stack.toString().writeToErrorLog();
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
      //--app包的信息
      DebugPage.debugLastWidgetBuilderList.add(
        (_) => packageInfo.text(textAlign: TextAlign.center, style: textStyle),
      );
      //--平台设备信息
      DebugPage.debugLastWidgetBuilderList.add(
        (_) =>
            deviceInfoData.text(textAlign: TextAlign.center, style: textStyle),
      );
      //--build信息
      DebugPage.debugLastWidgetBuilderList.add(
        (_) => $buildConfig?.toString().text(
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      );

      //string-copy
      DebugPage.debugLastCopyStringBuilderList.add(
        (_) => stringBuilder((builder) {
          //debugger();
          builder.appendLine("$packageInfo");
          builder.appendLine("$deviceInfoData");
          if ($buildConfig != null) {
            builder.appendLine($buildConfig?.toString());
          }
        }),
      );

      //合规后的初始化
      try {
        await executeGlobalInitialize(compliance: true);
      } catch (e, s) {
        printError(e, s);
        debugger(when: isDebug);
      }
    }
  });
}

/// 在具有[BuildContext]时, 进行首次初始化
/// [MaterialApp.onGenerateTitle]中的[BuildContext]拿不到[Navigator].[Overlay]
/// 推荐在[MaterialApp.home]中使用[Builder]小部件初始化
///
/// [checkOrShowNavigatorRouteOverlay]
///
@entryPoint
@initialize
Future initGlobalAppAtContext(BuildContext context) async {
  //debugger();
  if (GlobalConfig.def.globalAppContext == context) {
    return;
  }
  GlobalConfig.def.updateGlobalAppContext(context);
}

/// [NavigatorRouteOverlay]
@entryPoint
void checkOrShowNavigatorRouteOverlay([BuildContext? context]) {
  context ??= GlobalConfig.def.globalAppContext;
  if (context != null && isDebugFlag) {
    NavigatorRouteOverlay.show(context);
  }
}

/// [loadAssetSvgWidget]
Widget loadRootImageWidget(
  String key, {
  Color? color,
  BlendMode? colorBlendMode,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
}) => loadAssetImageWidget(
  key,
  package: null,
  prefix: null,
  color: color,
  colorBlendMode: colorBlendMode,
  size: size,
  width: width,
  height: height,
  fit: fit,
)!;

/// [loadAssetSvgWidget]
Widget loadRootSvgWidget(
  String key, {
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
  String? package,
  String? prefix,
}) => loadAssetSvgWidget(
  key,
  package: package,
  prefix: prefix,
  tintColor: tintColor,
  colorFilter: colorFilter,
  size: size,
  width: width,
  height: height,
  fit: fit,
);

/// [loadAssetSvgWidget]
Widget loadAppSvgWidget(
  String key, {
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
}) => loadAssetSvgWidget(
  key,
  package: Assets.package,
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
    isDebugType ||
    isDebugFlagDevice ||
    (GlobalConfig.def.isDebugFlagFn?.call() ?? $coreKeys.isDebugFlag);
