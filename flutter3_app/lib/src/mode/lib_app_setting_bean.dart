import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lib_app_setting_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序设置信息
///
/// - 通过[$appSettingBean]获取内存缓存
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

  //region 精确平台/包名/指定设备

  /// 1. 每个平台单独设置信息, 小写字母
  /// [$platformName]
  Map<String, LibAppSettingBean?>? platformMap;

  /// 2. 每个包名单独的版本信息
  /// [$buildPackageName]
  /// [AppSettingBean.packageName]
  Map<String, LibAppSettingBean?>? packageNameMap;

  /// 3. 每个编译类型单独的版本信息
  /// [$buildType]
  /// [BuildConfig.buildType]
  Map<String, LibAppSettingBean?>? buildTypeMap;

  /// 4. 每个设备单独的版本信息
  /// [CoreKeys.deviceUuid]
  Map<String, LibAppSettingBean?>? versionUuidMap;

  //endregion 精确平台/包名/指定设备

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

  //MARK: - get

  /// 获取匹配的版本配置信息
  LibAppSettingBean get it {
    LibAppSettingBean bean = this;
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

/// 应用程序的状态
enum AppStateEnum {
  /// 上架中
  review,

  /// 内测状态
  inside,

  /// 测试状态
  test,

  /// 发布
  publish,
}

/// [LibAppSettingBean]
LibAppSettingBean get $appSettingBean =>
    LibAppSettingBean._appSettingBean?.it ?? LibAppSettingBean();

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
