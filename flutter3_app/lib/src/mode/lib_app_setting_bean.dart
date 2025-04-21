import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lib_app_setting_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序设置信息
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LibAppSettingBean {
  static LibAppSettingBean? _appSettingBean;

  /// 从网络中获取[LibAppSettingBean]配置, 并且存储到本地
  /// [Asset]资源需要放到app包中
  /// 应用程序初始化成功后初始化...
  static Future fetchAppConfig(
    String url, {
    String name = "app_setting.json",
    String prefix = 'assets/$kConfigPathName/',
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
          final bean = LibAppSettingBean.fromJson(data.jsonDecode());
          _appSettingBean = bean;
          //debugger();
        }
      },
    );
  }

  factory LibAppSettingBean.fromJson(Map<String, dynamic> json) =>
      _$LibAppSettingBeanFromJson(json);

  Map<String, dynamic> toJson() => _$LibAppSettingBeanToJson(this);

  LibAppSettingBean();

  /// 每个平台单独设置信息, 平台名统一小写
  Map<String, LibAppSettingBean>? platformMap;

  //--

  /// 应用程序的状态, 比如正在上架中, 已上架
  /// [AppStateEnum]
  String? appState;

  //--

  /// 调试设备的uuid列表
  /// [CoreKeys.deviceUuid]
  List<String>? debugFlagUuidList;

  @override
  String toString() => toJson().toString();
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

/// [LibAppSettingBean]
LibAppSettingBean get $appSettingBean {
  LibAppSettingBean bean =
      LibAppSettingBean._appSettingBean ?? LibAppSettingBean();
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
  return bean.debugFlagUuidList!.contains($deviceUuid);
}

/// [LibAppSettingBean.appState]
AppStateEnum get $appStateEnum {
  final bean = $appSettingBean;
  String? appState = bean.appState;
  if (appState == null) {
    return AppStateEnum.review;
  }
  return AppStateEnum.values.getByName(appState, AppStateEnum.review);
}
