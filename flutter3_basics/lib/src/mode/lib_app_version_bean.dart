import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lib_app_version_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 应用程序版本信息
/// 通过[$appVersionBean]获取内存缓存信息
///
/// 1. 先获取对应平台的版本信息[LibAppVersionBean.platformMap]
/// 2. 通过包名获取对应的设备版本信息[LibAppVersionBean.packageNameMap]
/// 3. 通过编译类型获取对应的版本信息[LibAppVersionBean.buildTypeMap]
/// 4. 通过uuid获取对应的设备版本信息[LibAppVersionBean.versionUuidMap]
///
/// [AppUpdateDialog.checkUpdateAndShow]
/// [AppUpdateDialog]
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LibAppVersionBean {
  //MARK: - bean

  factory LibAppVersionBean.fromJson(Map<String, dynamic> json) =>
      _$LibAppVersionBeanFromJson(json);

  Map<String, dynamic> toJson() => _$LibAppVersionBeanToJson(this);

  LibAppVersionBean();

  /// 从Markdown格式中, 解析出数据结构
  ///
  /// ```
  /// # 2025-07-28 `5.9.1-alpha16` 5910
  ///
  /// - 修复1
  /// - 修复2
  /// - 新增1
  /// - 移除1
  /// ```
  ///
  factory LibAppVersionBean.fromMarkdown(String markdown) {
    final bean = LibAppVersionBean();

    final versionDesBuffer = StringBuffer();
    markdown.eachLine((line) {
      final lineStr = line.trim();
      final lineParts = lineStr.split(" ").map((e) => e.trim()).toList();
      if (lineStr.startsWith("#") && lineParts.length >= 2) {
        //title
        if (bean.versionDes != null) {
          //已经有数据了, 则结束解析. 仅解析最上面的一条数据
          return true;
        }

        final platform = lineParts.getOrNull(4)?.toLowerCase();
        if (platform != null && platform != $platformName) {
          //与当前平台不一致, 则继续解析
        } else {
          //2025-07-28 `5.9.1-alpha16` 5910 platform
          bean.versionDate = lineParts.getOrNull(1);
          bean.versionName = lineParts.getOrNull(2)?.trimBoth("`");
          bean.versionCode = lineParts.getOrNull(3)?.trimBoth("`").toInt();
        }
      } else if (bean.versionDate != null) {
        if (versionDesBuffer.isNotEmpty || lineStr.isNotEmpty) {
          versionDesBuffer.writeln(lineStr);
        }
      }
    });
    bean.versionDes = versionDesBuffer.toString();
    return bean;
  }

  //region 精确平台/包名/指定设备

  /// 1. 每个平台单独设置信息, 小写字母
  /// [$platformName]
  Map<String, LibAppVersionBean?>? platformMap;

  /// 2. 每个包名单独的版本信息
  /// [$buildPackageName]
  /// [AppSettingBean.packageName]
  Map<String, LibAppVersionBean?>? packageNameMap;

  /// 3. 每个编译类型单独的版本信息
  /// [$buildType]
  /// [BuildConfig.buildType]
  Map<String, LibAppVersionBean?>? buildTypeMap;

  /// 4. 每个设备单独的版本信息
  /// [CoreKeys.deviceUuid]
  Map<String, LibAppVersionBean?>? versionUuidMap;

  //endregion 精确平台/包名/指定设备

  //region 过滤

  /// 允许自定义的标签字段
  String? tag;

  /// 指定那些设备uuid能更新
  List<String>? allowVersionUuidList;

  /// 指定那些设备uuid不能更新
  List<String>? denyVersionUuidList;

  /// 是否仅用于调试?
  /// 开启后, 仅在[isDebugFlag]为true时有效
  bool? debug;

  //endregion 过滤

  //region 核心信息

  /// 抬头, 不指定则使用[versionName]
  String? versionTile;

  /// 版本名称, 用来显示
  String? versionName;

  /// 版本号, 用来比对
  int? versionCode;

  /// 可以更新到此版本范围
  ///
  /// - 支持 [100~999] 版本号
  /// - 支持 [1.0.0~9.9.9] 版本名称
  ///
  /// - [versionCode]
  /// - [VersionMatcher]
  ///   - [ValueRange]
  String? versionRange;

  /// 版本描述信息, Markdown格式
  ///
  /// - [AppUpdateDialog]
  ///
  String? versionDes;

  /// 是否强制更新, 强制更新则不允许关闭窗口
  bool? forceUpdate;

  /// 版本的下载地址
  String? downloadUrl;

  /// 跳转市场的地址
  /// - [marketUrl]
  /// - [jumpToMarket]
  ///
  /// # ios app store
  /// ```
  /// itms-apps://itunes.apple.com/app/id6670739251
  /// itms-apps://itunes.apple.com/app/id6762029425
  /// ```
  /// # android google play
  /// ```
  /// market://details?id=com.laser.abc.light
  /// market://details?id=com.kop.laser.mobile
  /// //--
  /// https://play.google.com/store/apps/details?id=com.laser.abc.light
  /// https://play.google.com/store/apps/details?id=com.kop.laser.mobile
  /// //&reviewId=0
  /// ```
  String? marketUrl;

  /// [downloadUrl] 外链下载? 还是直接下载
  /// 外链下载, 则跳转到浏览器下载
  /// 直接下载, 则直接下载文件,并安装
  bool? outLink;

  /// 是否跳转到应用市场?
  /// 优先级高于[outLink]
  /// - [marketUrl]
  /// - [jumpToMarket]
  bool? jumpToMarket;

  /// 版本时间
  /// `2025-06-10`
  String? versionDate;

  //endregion 核心信息

  //region 权限信息

  /// 版本号段对应的 forbidden 信息
  /// ```
  /// "100~999" : {
  ///   "forceForbidden": true,
  ///   "forbiddenTile": "forbiddenTile",
  ///   "forbiddenReason": "forbiddenReason",
  /// }
  /// ```
  /// [VersionMatcher]
  Map<String, LibAppVersionBean?>? forbiddenVersionMap;

  /// 标题
  String? forbiddenTile;

  /// 原因
  String? forbiddenReason;

  /// 强制禁用
  bool? forceForbidden;

  //endregion 权限信息

  @override
  String toString() => toJson().toString();
}
