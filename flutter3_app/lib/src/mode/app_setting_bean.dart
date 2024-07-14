import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_setting_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序设置信息
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class AppSettingBean {
  static AppSettingBean? _appSettingBean;

  /// 从网络中获取[AppSettingBean]配置, 并且存储到本地
  /// [Asset]资源需要放到app包中
  static Future fetchAppConfig(
    String url, {
    String name = "app_setting.json",
    String prefix = 'assets/config/',
    String? package, //flutter3_app
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
          //debugger();
        }
      },
    );
  }

  factory AppSettingBean.fromJson(Map<String, dynamic> json) =>
      _$AppSettingBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingBeanToJson(this);

  AppSettingBean();

  /// 每个单独设置信息
  Map<String, AppSettingBean>? platformMap;

  //--

  /// 应用程序的包名
  String? packageName;

  /// 应用程序的风味, 不同风味的app, 可以有不同的配置
  String? appFlavor;

  /// 应用程序的状态, 比如正在上架中, 已上架
  String? appState;

  /// [appFlavor]
  List<String>? appFlavorUuidList;

  //--

  /// 调试设备的uuid列表
  /// [CoreKeys.deviceUuid]
  List<String>? debugFlagUuidList;

  //--build--

  /// 编译时间
  /// 2024-06-21 14:27:05.978594
  String? buildTime;

  /// windows
  String? operatingSystem;

  /// "Windows 10 Pro" 10.0 (Build 19045)
  String? operatingSystemVersion;

  /// zh-CN
  String? operatingSystemLocaleName;

  /// angcyo
  String? operatingSystemUserName;

  @override
  String toString() => toJson().toString();
}

/// 应用程序的风味
enum AppFlavorEnum {
  /// 调试
  debug,

  /// 预发
  pretest,

  /// 正式
  release
}

/// 应用程序的状态
enum AppStateEnum {
  /// 上架中
  review,

  /// 内测状态
  inside,

  /// 测试状态
  test,

  /// 发布
  publish
}

/// [AppSettingBean]
AppSettingBean get $appSettingBean {
  AppSettingBean bean = AppSettingBean._appSettingBean ??= AppSettingBean();
  bean = bean.platformMap?[$platformName] ?? bean;
  return bean;
}

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

/// 是否是调试风味状态
bool get isDebugFlavor {
  final bean = $appSettingBean;
  return bean.appFlavor != null && $appFlavorEnum != AppFlavorEnum.release;
}

/// [AppSettingBean.packageName]
String? get $appPackageName => $appSettingBean.packageName;

/// [AppSettingBean.appFlavor]
/// [AppSettingBean.appFlavorUuidList]
AppFlavorEnum get $appFlavorEnum {
  final bean = $appSettingBean;
  String? appFlavor =
      bean.appFlavorUuidList?.findFirst((e) => e == $coreKeys.deviceUuid) ??
          bean.appFlavor;
  if (appFlavor == null) {
    return AppFlavorEnum.release;
  }
  return AppFlavorEnum.values.getByName(appFlavor, AppFlavorEnum.release);
}

/// [AppSettingBean.appState]
AppStateEnum get $appStateEnum {
  final bean = $appSettingBean;
  String? appState = bean.appState;
  if (appState == null) {
    return AppStateEnum.review;
  }
  return AppStateEnum.values.getByName(appState, AppStateEnum.review);
}
