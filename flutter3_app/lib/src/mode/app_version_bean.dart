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
  static void fetchConfig(
    String url, {
    String name = "app_version.json",
    String package = "flutter3_app",
  }) {
    ConfigFile.readConfigFile(
      name,
      package: package,
      forceFetch: true,
      waitHttp: true,
      httpUrl: url,
    ).get((data, error) async {
      if (data is String) {
        final bean = AppVersionBean.fromJson(data.jsonDecode());
        _appVersionBean = bean;
        final localVersionCode = (await appVersionCode).toIntOrNull() ?? 0;
        final versionBean = bean.versionUuidMap?[$coreKeys.deviceUuid] ?? bean;
        if (versionBean.debug != true ||
            (versionBean.debug == true && isDebugFlag)) {
          //forbidden检查
          final forbiddenVersionMap = versionBean.forbiddenVersionMap;
          final forbiddenBean = forbiddenVersionMap
                  ?.find((key, value) => key.matchVersion(localVersionCode))
                  ?.value ??
              versionBean;
          if (forbiddenBean.forbiddenReason != null) {
            GlobalConfig.def.findNavigatorState()?.showWidgetDialog(
                GlobalConfig.def.globalContext,
                MessageDialog(
                  title: forbiddenBean.forbiddenTile,
                  message: forbiddenBean.forbiddenReason,
                ));
            if (forbiddenBean.forceForbidden == true) {
            } else {}
          } else {
            //更新检查
            final versionCode = versionBean.versionCode ?? 0;
            if (versionCode > localVersionCode) {
              //需要更新
              GlobalConfig.def.findNavigatorState()?.showWidgetDialog(
                  GlobalConfig.def.globalContext,
                  MessageDialog(
                    title: versionBean.versionName,
                    message: versionBean.versionDes,
                  ));
            }
          }
        }
      }
    });
  }

  factory AppVersionBean.fromJson(Map<String, dynamic> json) =>
      _$AppVersionBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionBeanToJson(this);

  AppVersionBean();

  /// 是否仅用于调试?
  bool? debug;

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

  /// [downloadUrl] 外链下载? 还是直接下载
  /// 外链下载, 则跳转到浏览器下载
  /// 直接下载, 则直接下载文件,并安装
  bool? outLink;

  /// 是否跳转到应用市场?
  bool? jumpToMarket;

  /// 版本时间
  String? versionDate;

  /// 每个设备单独的版本信息
  /// [CoreKeys.deviceUuid]
  Map<String, AppVersionBean>? versionUuidMap;

  //--

  /// 版本号段对应的 forbidden 信息
  /// [VersionMatcher]
  Map<String, AppVersionBean>? forbiddenVersionMap;
  String? forbiddenTile;
  String? forbiddenReason;
  bool? forceForbidden;
}
