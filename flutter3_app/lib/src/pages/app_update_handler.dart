import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_android_package_installer/flutter_android_package_installer.dart';

import '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/03
///
/// App 更新处理器
/// - 下载
/// - 后台下载
/// - 安装
class AppUpdateHandler {
  /// 海外市场（Google Play）：使用 in_app_update 插件，
  /// 调用 Google Play 官方的应用内更新 API，无需申请 `REQUEST_INSTALL_PACKAGES` 权限。
  static bool Function() isInGooglePlayFn = () =>
      isAndroid &&
      $buildType == BuildTypeEnum.release.name &&
      $buildFlavor != "mainland";

  /// 检查更新并且显示
  /// [forceShow] 是否强制显示更新, 不检查版本号
  /// 在[AppVersionBean.fetchConfig]中触发
  ///
  /// @return 是否有新版本
  @api
  static Future<bool> checkUpdateAndShow(
    BuildContext? context,
    LibAppVersionBean bean, {
    bool? forceShow,
    bool? forceForbiddenShow,
    String? debugLabel,
  }) async {
    debugger(when: !isIos && debugLabel != null);
    NavigatorState? navigator;
    LibRes? libRes;
    if (context == null || context.isMounted != true) {
    } else {
      navigator = context.navigatorOf(true);
      libRes = LibRes.of(context);
    }

    final deviceUuid = $coreKeys.deviceUuid;
    final LibAppVersionBean versionBean = bean.it;
    bool ignoreDeviceUpdate = false; //是否要忽略当前设备的更新

    final allowVersionUuidList = versionBean.allowVersionUuidList;
    if (allowVersionUuidList != null) {
      if (allowVersionUuidList.size() > 0) {
        if (!allowVersionUuidList.contains(deviceUuid)) {
          //当前设备不在白名单中
          ignoreDeviceUpdate = true;
        }
      }
    }

    if (!ignoreDeviceUpdate) {
      final denyVersionUuidList = versionBean.denyVersionUuidList;
      if (denyVersionUuidList != null) {
        if (denyVersionUuidList.contains(deviceUuid)) {
          //当前设备在黑名单中
          ignoreDeviceUpdate = true;
        }
      }
    }

    //check
    final localVersionCode = (await $appVersionCode).toIntOrNull() ?? 0;
    //debugger();
    if (forceForbiddenShow == true ||
        versionBean.debug != true ||
        (versionBean.debug == true && isDebugFlag)) {
      //forbidden检查
      final forbiddenVersionMap = versionBean.forbiddenVersionMap;
      final forbiddenBean =
          forbiddenVersionMap
              ?.find((key, value) => key.matchVersion(localVersionCode))
              ?.value ??
          versionBean;
      if (forceForbiddenShow == true || forbiddenBean.forbiddenReason != null) {
        final forceForbidden = forbiddenBean.forceForbidden == true;
        (GlobalConfig.def.findNavigatorState() ?? navigator)?.showWidgetDialog(
          MessageDialog(
            title: forbiddenBean.forbiddenTile,
            message: forbiddenBean.forbiddenReason ?? "（o´ﾟ□ﾟ`o）",
            confirm: libRes?.libKnown,
            showConfirm: !forceForbidden,
            interceptPop: forceForbidden,
            dialogBarrierDismissible: !forceForbidden,
          ).click(() {
            exitApp();
          }, enable: forceForbidden).ignoreKeyEvent(),
        );
      }

      //更新检查
      if (!ignoreDeviceUpdate) {
        final versionCode = versionBean.versionCode ?? 0;
        if (forceShow == true || versionCode > localVersionCode) {
          //需要更新
          assert(() {
            l.i(
              "需要更新->forceShow:${forceShow?.toDC()} versionCode:$versionCode localVersionCode:$localVersionCode",
            );
            return true;
          }());
          navigator?.showWidgetDialog(
            AppUpdateDialog(versionBean, forceUpdate: null),
          );
          return true;
        }
      }
    }
    return false;
  }

  /// 安装软件
  /// iOS 平台无法安装ipa
  /// Android 平台需要权限
  /// ```
  /// <!-- Android 11+ Permissions -->
  /// <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
  /// ```
  static void startInstallApp({String? path}) {
    //debugger();
    if (path == null || isNil(path)) {
      return;
    }
    if (isAndroid) {
      assert(() {
        l.d("准备安装->$path");
        return true;
      }());
      Permission.requestInstallPackages.request().get((value, error) {
        assert(() {
          l.d("安装权限返回->$value:$error");
          return true;
        }());
        if (value == PermissionStatus.granted) {
          AndroidPackageInstaller.installApk(apkFilePath: path).get((
            value,
            error,
          ) {
            assert(() {
              l.d("安装结果->$value:$error");
              return true;
            }());
          });
        }
      });
    } else if (isMacOS) {
      runCommand("open", [path], throwOnError: false, mode: .detached);
    } else if (isIos) {
      //no op
    } else if (isWeb) {
      //no op
    } else if (isWindows) {
      //runCommand("explorer", [path], throwOnError: false, mode: .detached);
      runCommand(
        path,
        ["/SILENT", "/SUPPRESSMSGBOXES", "/NORESTART"],
        throwOnError: false,
        mode: .detached,
      );
    }
  }
}

/// [AppUpdateHandler]的实例
@globalInstance
AppUpdateHandler appUpdateHandler = AppUpdateHandler();
