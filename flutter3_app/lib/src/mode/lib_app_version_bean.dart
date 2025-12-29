import 'dart:developer';

import 'package:flutter3_app/flutter3_app.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../assets_generated/assets.gen.dart';

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
  static Future fetchConfig(
    String? url, {
    String name = "app_version.json",
    String package = Assets.package,
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
        debugger(when: debugLabel != null);
        if (data is String) {
          appVersionUrl = url;
          final bean = LibAppVersionBean.fromJson(data.jsonDecode());
          _appVersionBean = bean;
          //debugger();
          if (checkUpdate || forceShow == true || forceForbiddenShow == true) {
            final update = await AppUpdateDialog.checkUpdateAndShow(
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
        } else {
          onUpdateAction?.call(false);
        }
      },
    );
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
  Map<String, LibAppVersionBean>? forbiddenVersionMap;

  /// 标题
  String? forbiddenTile;

  /// 原因
  String? forbiddenReason;

  /// 强制禁用
  bool? forceForbidden;

  //endregion 权限信息

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

  @override
  String toString() => toJson().toString();

  //MARK: - get

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
LibAppVersionBean? get $appVersionBean => LibAppVersionBean._appVersionBean?.it;
