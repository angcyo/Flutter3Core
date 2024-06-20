import 'dart:developer';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_setting_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序设置信息
@JsonSerializable(includeIfNull: false)
class AppSettingBean {
  static AppSettingBean? _appSettingBean;

  /// 从网络中获取[AppSettingBean]配置, 并且存储到本地
  static Future fetchConfig(
    String url, {
    String name = "app_setting.json",
    String package = "flutter3_app",
    String prefix = 'assets/config/',
  }) {
    return ConfigFile.readConfigFile(
      name,
      package: package,
      prefix: prefix,
      forceAssetToFile: isDebug,
      forceFetch: true,
      waitHttp: false,
      httpUrl: url,
      onValueAction: (data) {
        if (data is String) {
          final bean = AppSettingBean.fromJson(data.jsonDecode());
          _appSettingBean = bean;
          debugger();
        }
      },
    );
  }

  factory AppSettingBean.fromJson(Map<String, dynamic> json) =>
      _$AppSettingBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingBeanToJson(this);

  AppSettingBean();

  //--

  /// 应用程序的包名
  String? packageName;

  /// 应用程序的风味, 不同风味的app, 可以有不同的配置
  String? appFlavor;

  /// [appFlavor]
  List<String>? appFlavorUuidList;

  //--

  /// 调试设备的uuid列表
  /// [CoreKeys.deviceUuid]
  List<String>? debugFlagUuidList;
}

/// 应用程序的风味
enum AppFlavorEnum {
  /// 调试
  debug,

  /// 预发
  pretest,

  /// 正式
  release,

  /// 上架审核中...
  review,
}

/// [AppSettingBean]
AppSettingBean get $appSettingBean =>
    AppSettingBean._appSettingBean ??= AppSettingBean();

/// 当前的设备id, 是否处于调试状态
/// [CoreKeys.deviceUuid]
bool get isDebugFlagDevice {
  final bean = $appSettingBean;
  if (bean.debugFlagUuidList == null) {
    return false;
  }
  if (bean.debugFlagUuidList!.isEmpty) {
    return true;
  }
  return bean.debugFlagUuidList!.contains($coreKeys.deviceUuid);
}

/// [AppSettingBean.packageName]
String? get appPackageName => $appSettingBean.packageName;

/// [AppSettingBean.appFlavor]
/// [AppSettingBean.appFlavorUuidList]
AppFlavorEnum get appFlavorEnum {
  final bean = $appSettingBean;
  String? appFlavor =
      bean.appFlavorUuidList?.findFirst((e) => e == $coreKeys.deviceUuid) ??
          bean.appFlavor;
  if (appFlavor == null) {
    return AppFlavorEnum.release;
  }
  return AppFlavorEnum.values.getByName(appFlavor, AppFlavorEnum.release);
}
