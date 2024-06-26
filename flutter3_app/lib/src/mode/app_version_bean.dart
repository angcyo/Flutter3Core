import 'package:flutter3_app/flutter3_app.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_version_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序版本信息
@JsonSerializable(includeIfNull: false)
class AppVersionBean {
  static AppVersionBean? _appVersionBean;

  /// 从网络中获取[AppVersionBean]配置, 并且存储到本地
  static Future fetchConfig(
    String url, {
    String name = "app_version.json",
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
      onHttpAction: (data) async {
        if (data is String) {
          //debugger();
          final bean = AppVersionBean.fromJson(data.jsonDecode());
          _appVersionBean = bean;
          AppUpdateDialog.checkUpdateAndShow(
            GlobalConfig.def.globalContext,
            bean,
          );
        }
      },
    );
  }

  factory AppVersionBean.fromJson(Map<String, dynamic> json) =>
      _$AppVersionBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionBeanToJson(this);

  AppVersionBean();

  /// 每个单独设置信息
  Map<String, AppVersionBean>? platformMap;

  /// 是否仅用于调试?
  bool? debug;

  /// 抬头
  String? versionTile;

  /// 版本名称, 用来显示
  String? versionName;

  /// 版本号, 用来比对
  int? versionCode;

  /// 版本描述信息
  String? versionDes;

  /// 是否强制更新, 强制更新则不允许关闭窗口
  bool? forceUpdate;

  /// 版本的下载地址
  String? downloadUrl;

  /// 跳转市场的地址
  String? marketUrl;

  /// [downloadUrl] 外链下载? 还是直接下载
  /// 外链下载, 则跳转到浏览器下载
  /// 直接下载, 则直接下载文件,并安装
  bool? outLink;

  /// 是否跳转到应用市场?
  /// 优先级高于[outLink]
  bool? jumpToMarket;

  /// 版本时间
  String? versionDate;

  /// 每个设备单独的版本信息
  /// [CoreKeys.deviceUuid]
  Map<String, AppVersionBean>? versionUuidMap;

  /// 每个包名单独的版本信息
  /// [AppSettingBean.packageName]
  Map<String, AppVersionBean>? packageNameMap;

  //--

  /// 版本号段对应的 forbidden 信息
  /// [VersionMatcher]
  Map<String, AppVersionBean>? forbiddenVersionMap;
  String? forbiddenTile;
  String? forbiddenReason;
  bool? forceForbidden;
}
