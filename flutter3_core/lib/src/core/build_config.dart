import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'build_config.g.dart';

/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/08
///
/// 构建时的一些参数, 通常情况下, 构建数据构建之后不允许再次动态修改
/// 构建数据模版`build_config.tl.json`
///
/// - 顶层: 兜底配置
///   - [BuildConfig.platformMap] . [$platformName]
///     - [BuildConfig.buildTypeMap]
///       - [BuildConfig.buildFlavorMap]
///
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class BuildConfig {
  /// 需要在[initBuildConfig]之后才有值
  @tempFlag
  static BuildConfig? _rootBuildConfig;

  /// 从[Asset]资源中解析构建信息
  /// [Asset]需要放到app包中
  /// 启动程序时初始化
  ///
  /// [package] 不指定, 就是顶级包
  ///
  @initialize
  @CallFrom("runGlobalApp")
  static Future<BuildConfig?> initBuildConfig({
    String name = "$kConfigPathName/build_config.json",
    String prefix = kDefAssetsPrefix,
    String? package, //flutter3_app,
  }) async {
    try {
      //debugger();
      final string = await loadAssetString(
        name,
        prefix: prefix,
        package: package,
      );
      final json = string.jsonDecode();
      final bean = BuildConfig.fromJson(json);
      //bean.json = json;
      _rootBuildConfig = bean;
      //debugger();
    } catch (e) {
      assert(() {
        l.e(
          "${e.toString().trimLines(" ")}, 是否在`pubspec.yaml`文件中配置了构建资产[assets] - $prefix$name",
        );
        return true;
      }());
    }
    return _rootBuildConfig;
  }

  //MARK: - 固定常量key

  /// 构建类型
  /// [BuildTypeEnum]
  static String kBuildTypeKey = "buildType";

  /// 应用程序的风味, 不同风味的app, 可以有不同的配置
  static String kBuildFlavorKey = "buildFlavor";

  //--build_config脚本生成属性--

  /// 编译时的版本名
  static String kBuildVersionNameKey = "buildVersionName";

  /// 编译时的版本号
  /// - [int]
  static String kBuildVersionCodeKey = "buildVersionCode";

  //--

  /// 构建时的时间
  /// 2024-06-21 14:27:05.978594
  static String kBuildTimeKey = "buildTime";

  /// 构建时的操作系统
  /// windows
  static String kBuildOperatingSystemKey = "buildOperatingSystem";

  /// 构建时, 操作系统的版本
  /// "Windows 10 Pro" 10.0 (Build 19045)
  static String kBuildOperatingSystemVersionKey = "buildOperatingSystemVersion";

  /// 构建时, 操作系统的语言
  /// zh-CN
  static String kBuildOperatingSystemLocaleNameKey =
      "buildOperatingSystemLocaleName";

  /// 构建时, 操作系统的用户名
  /// angcyo
  static String kBuildOperatingSystemUserNameKey =
      "buildOperatingSystemUserName";

  /// 应用程序设置的包名
  /// 并非真正的包名
  /// 真正的包名需要通过[BuildConfig.platformPackageNameMap]获取
  static String kBuildPackageNameKey = "buildPackageName";

  //MARK: - BuildConfig

  BuildConfig();

  factory BuildConfig.fromJson(Map<String, dynamic> json) =>
      _$BuildConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BuildConfigToJson(this);

  //MARK: - 核心映射Map

  /// 1. 每个平台单独设置信息, 平台名统一小写
  /// [$platformName] 对应的配置
  @configProperty
  Map<String, BuildConfig?>? platformMap;

  /// 2. [buildType] 对应的配置
  @configProperty
  Map<String, BuildConfig?>? buildTypeMap;

  /// 3. [buildFlavor] 对应的配置
  @configProperty
  Map<String, BuildConfig?>? buildFlavorMap;

  //MARK: json数据

  /// 全部json对象的数据
  /// 额外的自定义数据放在这里
  Map<String, dynamic>? json;

  /// [mergeJson]
  @api
  dynamic operator [](Object? key) {
    if (_mergeJson != null) {
      //debugger();
      return _mergeJson?[key];
    }
    return mergeJson?[key];
  }

  /// [json]
  void operator []=(String key, dynamic value) {
    json ??= {};
    _mergeJson = null;
    json?[key] = value;
  }

  /// 短日志
  String get shortString {
    return "$buildPackageName $buildType ${buildFlavor ?? ""} $buildVersionName($buildVersionCode)\n$buildTime";
  }

  @override
  String toString() => toJson().toString();

  //MARK: get

  /// - [mergeJson]
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? _mergeJson;

  /// 从顶层开始,将所有[json]按照层级规则合并后的json数据
  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? get mergeJson {
    //1:root
    final rootConfig = this;
    //2:platform
    final platformConfig = platformMap?[$platformName];
    //3:buildType
    final buildType =
        platformConfig?.json?[BuildConfig.kBuildTypeKey] ??
        rootConfig.json?[BuildConfig.kBuildTypeKey];
    final buildTypeConfig =
        platformConfig?.buildTypeMap?[buildType] ??
        rootConfig.buildTypeMap?[buildType];
    //4:buildFlavor
    final buildFlavor =
        buildTypeConfig?.json?[BuildConfig.kBuildFlavorKey] ??
        platformConfig?.json?[BuildConfig.kBuildFlavorKey] ??
        rootConfig.json?[BuildConfig.kBuildFlavorKey];
    final buildFlavorConfig =
        buildTypeConfig?.buildFlavorMap?[buildFlavor] ??
        platformConfig?.buildFlavorMap?[buildFlavor] ??
        rootConfig.buildFlavorMap?[buildFlavor];
    return _mergeJson = {
      ...?rootConfig.json,
      ...?platformConfig?.json,
      ...?buildTypeConfig?.json,
      ...?buildFlavorConfig?.json,
    };
  }

  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get buildPackageName => this[BuildConfig.kBuildPackageNameKey];

  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get buildType => this[BuildConfig.kBuildTypeKey];

  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get buildFlavor => this[BuildConfig.kBuildFlavorKey];

  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get buildVersionName => this[BuildConfig.kBuildVersionNameKey];

  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  int? get buildVersionCode => this[BuildConfig.kBuildVersionCodeKey];

  @api
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get buildTime => this[BuildConfig.kBuildTimeKey];
}

/// 构建时应用程序的构建类型
enum BuildTypeEnum {
  /// 调试
  debug,

  /// 预发
  pretest,

  /// 正式
  release,
}

/// 顶层的[BuildConfig]
/// - 在获取[BuildConfig.json]中的数据时, 优先使用顶层对象.
BuildConfig? get $buildConfig => BuildConfig._rootBuildConfig;

/// 获取构建[BuildConfig.json]中断额数据时, 优先使用此对象
@alias
BuildConfig? get $bc => $buildConfig;

/// 是否是调试构建类型状态
bool get isDebugType {
  final config = $buildConfig;
  if (config == null) {
    return isDebug;
  }
  if (config.buildType == null) {
    //未指定
    return isDebug;
  }
  return config.buildType != BuildTypeEnum.release.name;
}

/// 构建类型
/// - [isDebug] 下, 强行返回[BuildTypeEnum.debug]
String? get $buildType =>
    isDebug ? BuildTypeEnum.debug.name : $buildConfig?.buildType;

/// 构建风味
String? get $buildFlavor =>
    $buildConfig?.buildFlavor ?? flutterAppFlavor ?? (isDebug ? "debug" : null);

/// 构建时的app包名
/// 真正的app包名通过以下方法获取↓
/// [platformPackageInfo]
/// [appPlatformPackageName]
String? get $buildPackageName => $buildConfig?.buildPackageName;
