import 'package:flutter3_app/flutter3_app.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_version_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序版本信息
///
/// 1. 先获取对应平台的版本信息[AppVersionBean.platformMap]
/// 2. 通过包名获取对应的设备版本信息[AppVersionBean.packageNameMap]
/// 3. 通过uuid获取对应的设备版本信息[AppVersionBean.versionUuidMap]
///
/// [AppUpdateDialog.checkUpdateAndShow]
/// [AppUpdateDialog]
@JsonSerializable(includeIfNull: false, explicitToJson: true)
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
          //debugger();
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

  //region --精确平台/包名/指定设备--

  /// 每个平台单独设置信息, 小写字母
  /// [$platformName]
  Map<String, AppVersionBean>? platformMap;

  /// 每个包名单独的版本信息
  /// [AppSettingBean.packageName]
  Map<String, AppVersionBean>? packageNameMap;

  /// 每个设备单独的版本信息
  /// [CoreKeys.deviceUuid]
  Map<String, AppVersionBean>? versionUuidMap;

  //endregion --精确平台/包名/指定设备--

  //region --过滤--

  /// 指定那些设备能更新
  List<String>? allowVersionUuidList;

  /// 指定那些设备不能更新
  List<String>? denyVersionUuidList;

  /// 是否仅用于调试?
  bool? debug;

  //endregion --过滤--

  //region --核心信息--

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

  //endregion --核心信息--

  //region --权限信息--

  /// 版本号段对应的 forbidden 信息
  /// [VersionMatcher]
  Map<String, AppVersionBean>? forbiddenVersionMap;
  String? forbiddenTile;
  String? forbiddenReason;
  bool? forceForbidden;

//endregion --权限信息--
}
