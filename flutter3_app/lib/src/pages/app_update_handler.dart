import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter_android_package_installer/flutter_android_package_installer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../flutter3_app.dart' show $appVersionCode;
import 'app_update_dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/03
///
/// App 更新处理器
/// - 下载
/// - 后台下载
/// - 安装
class AppUpdateHandler {
  /// 缓存
  /// - [$appVersionBean]
  @tempFlag
  static LibAppVersionBean? _appVersionBean;

  /// [_appVersionBean] 获取成功后对应的url
  @output
  static String? appVersionUrl;

  /// 从网络地址[url]中获取[LibAppVersionBean]配置, 并且存储到本地
  /// 应用程序初始化成功后初始化...
  /// [checkUpdate] 是否检查更新弹窗
  ///
  /// - [onUpdateAction] 有无新版本的回调
  ///
  /// [AppUpdateDialog.checkUpdateAndShow]
  static Future fetchVersionConfig(
    String? url, {
    String name = "app_version.json",
    String package = libFlutter3BasicsPackage,
    String prefix = 'assets/$kConfigPathName/',
    bool checkUpdate = true,
    BoolCallback? onUpdateAction,
    bool? forceShow,
    bool? forceForbiddenShow,
    String? debugLabel,
  }) async {
    if (url == null) {
      onUpdateAction?.call(false);
      return;
    }
    return ConfigFile.readConfigFile(
      name,
      package: package,
      prefix: prefix,
      forceAssetToFile: false,
      forceFetch: true,
      waitHttp: false,
      httpUrl: url,
      debugLabel: debugLabel,
      onHttpAction: (data) async {
        debugger(when: !isIos && debugLabel != null);
        if (data is String) {
          appVersionUrl = url;
          final bean = LibAppVersionBean.fromJson(data.jsonDecode());
          checkVersionAndShow(
            bean,
            checkUpdate: checkUpdate,
            onUpdateAction: onUpdateAction,
            forceShow: forceShow,
            forceForbiddenShow: forceForbiddenShow,
            debugLabel: debugLabel,
          );
        } else {
          onUpdateAction?.call(false);
        }
      },
    );
  }

  /// 检查版本信息and显示
  static Future checkVersionAndShow(
    LibAppVersionBean bean, {
    bool checkUpdate = true,
    BoolCallback? onUpdateAction,
    bool? forceShow,
    bool? forceForbiddenShow,
    String? debugLabel,
  }) async {
    _appVersionBean = bean;
    if (checkUpdate || forceShow == true || forceForbiddenShow == true) {
      final update = await checkUpdateAndShow(
        GlobalConfig.def.globalContext,
        bean,
        forceShow: forceShow,
        forceForbiddenShow: forceForbiddenShow,
        debugLabel: debugLabel,
      );
      onUpdateAction?.call(update);
    } else {
      onUpdateAction?.call(false);
    }
    assert(() {
      l.i("当前版本信息->${$appVersionBean}");
      return true;
    }());
  }

  static List<LibAppVersionBean>? fromMarkdownList(String? markdown) {
    if (markdown == null || markdown.isEmpty) {
      return null;
    }
    List<LibAppVersionBean> result = [];

    LibAppVersionBean? last;
    final versionDesBuffer = StringBuffer();
    markdown.eachLine((line) {
      final lineStr = line.trim();
      final lineParts = lineStr.split(" ").map((e) => e.trim()).toList();
      if (lineStr.startsWith("#") && lineParts.length >= 2) {
        //title
        if (last != null) {
          last!.versionDes = versionDesBuffer.toString();
          result.add(last!);
          versionDesBuffer.clear();
          last = null;
        }
        final platform = lineParts.getOrNull(4)?.toLowerCase();
        if (platform != null && platform != $platformName) {
          //与当前平台不一致, 则继续解析
        } else {
          //2025-07-28 `5.9.1-alpha16` 5910 platform
          last = LibAppVersionBean()
            ..versionDate = lineParts.getOrNull(1)
            ..versionName = lineParts.getOrNull(2)?.trimBoth("`")
            ..versionCode = lineParts.getOrNull(3)?.trimBoth("`").toInt();
        }
      } else if (last?.versionDate != null) {
        if (lineStr.isNotEmpty) {
          versionDesBuffer.appendIfNotEmpty();
          versionDesBuffer.write(lineStr);
        }
      }
    });
    if (last != null) {
      last!.versionDes = versionDesBuffer.toString();
      result.add(last!);
      versionDesBuffer.clear();
      last = null;
    }
    return result;
  }

  /// 海外市场（Google Play）：使用 in_app_update 插件，
  /// 调用 Google Play 官方的应用内更新 API，无需申请 `REQUEST_INSTALL_PACKAGES` 权限。
  static bool Function() isInGooglePlayFn = () =>
      isAndroid &&
      $buildType == BuildTypeEnum.release.name &&
      $buildFlavor != "mainland";

  /// 检查更新并且显示
  /// [forceShow] 是否强制显示更新, 不检查版本号
  /// 在[AppUpdateHandler.fetchVersionConfig]中触发
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

extension LibAppVersionBeanEx on LibAppVersionBean {
  //MARK: - get

  /// debug匹配通过
  bool get matchDebug => (debug == true && isDebugFlag) || debug == null;

  /// 允许的设备uuid匹配通过
  bool get matchAllowVersionUuid =>
      (allowVersionUuidList == null || allowVersionUuidList!.isEmpty)
      ? true
      : allowVersionUuidList!.contains($deviceUuid);

  /// 拒绝的设备uuid匹配通过
  bool get matchDenyVersionUuid =>
      (denyVersionUuidList == null || denyVersionUuidList!.isEmpty)
      ? true
      : !denyVersionUuidList!.contains($deviceUuid);

  /// 所有匹配通过
  bool get matchAll =>
      matchDebug && matchAllowVersionUuid && matchDenyVersionUuid;

  /// 获取匹配的版本配置信息
  LibAppVersionBean get it {
    LibAppVersionBean bean = this;
    //1: 平台检查, 获取对应平台的版本信息
    bean = bean.platformMap?[$platformName] ?? bean;

    //2: 区分package, 获取对应报名的版本信息
    bean = bean.packageNameMap?[$buildPackageName] ?? bean;

    //3: 区分buildType, 获取对应报名的版本信息
    bean = bean.buildTypeMap?[$buildType] ?? bean;

    //4: 获取指定设备的版本信息
    final deviceUuid = $coreKeys.deviceUuid;
    bean = bean.versionUuidMap?[deviceUuid] ?? bean;

    return bean;
  }
}

/// [LibAppVersionBean]
@api
LibAppVersionBean? get $appVersionBean => AppUpdateHandler._appVersionBean?.it;
