import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'build_config.g.dart';

/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/08
///
/// 构建时的一些参数, 通常情况下, 构建数据构建之后不允许再次动态修改
/// 构建数据模版`build_config.tl.json`
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class BuildConfig {
  static BuildConfig? _buildConfig;

  /// 从[Asset]资源中解析构建信息
  /// [Asset]需要放到app包中
  /// 启动程序时初始化
  ///
  /// [package] 不指定, 就是顶级包
  ///
  @initialize
  static Future<BuildConfig?> initBuildConfig({
    String name = "$kConfigPathName/build_config.json",
    String prefix = kDefAssetsPrefix,
    String? package, //flutter3_app,
  }) async {
    try {
      final string = await loadAssetString(
        name,
        prefix: prefix,
        package: package,
      );
      final json = string.jsonDecode();
      final bean = BuildConfig.fromJson(json);
      bean.json = json;
      _buildConfig = bean;
      //debugger();
    } catch (e) {
      assert(() {
        l.e("$e, 是否在`yaml`中包含了[$prefix$name]");
        return true;
      }());
    }
    return _buildConfig;
  }

  BuildConfig();

  factory BuildConfig.fromJson(Map<String, dynamic> json) =>
      _$BuildConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BuildConfigToJson(this);

  /// 每个平台单独设置信息, 平台名统一小写
  @configProperty
  Map<String, BuildConfig>? platformMap;

  //--

  /// 应用程序设置的包名
  /// 并非真正的包名
  /// 真正的包名需要通过[platformPackageInfo]获取
  @configProperty
  String? buildPackageName;

  /// 应用程序的风味, 不同风味的app, 可以有不同的配置
  @configProperty
  String? buildFlavor;

  /// 构建类型
  /// [BuildTypeEnum]
  @configProperty
  String? buildType;

  //--

  /// 编译时的版本名
  @configProperty
  String? buildVersionName;

  /// 编译时的版本号
  @configProperty
  int? buildVersionCode;

  //--build--

  /// 构建时的时间
  /// 2024-06-21 14:27:05.978594
  @autoInjectMark
  String? buildTime;

  /// 构建时的操作系统
  /// windows
  @autoInjectMark
  String? buildOperatingSystem;

  /// 构建时, 操作系统的版本
  /// "Windows 10 Pro" 10.0 (Build 19045)
  @autoInjectMark
  String? buildOperatingSystemVersion;

  /// 构建时, 操作系统的语言
  /// zh-CN
  @autoInjectMark
  String? buildOperatingSystemLocaleName;

  /// 构建时, 操作系统的用户名
  /// angcyo
  @autoInjectMark
  String? buildOperatingSystemUserName;

  //--

  /// 全部json对象的数据
  /// 额外的自定义数据放在这里
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? json;

  /// [json]
  dynamic operator [](Object? key) => json?[key];

  /// [json]
  void operator []=(String key, dynamic value) {
    json?[key] = value;
  }

  /// 短日志
  String get shortString {
    return "$buildPackageName $buildType ${buildFlavor ?? ""} $buildVersionName($buildVersionCode)\n$buildTime";
  }

  @override
  String toString() => json?.toString() ?? "" /*"${toJson()}"*/;
}

/// 构建时应用程序的构建类型
enum BuildTypeEnum {
  /// 调试
  debug,

  /// 预发
  pretest,

  /// 正式
  release,
  ;
}

/// [BuildConfig]
BuildConfig? get $buildConfig {
  BuildConfig? config = BuildConfig._buildConfig;
  config = config?.platformMap?[$platformName] ?? config;
  return config;
}

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

/// 构建风味
String? get $buildFlavor => $buildConfig?.buildFlavor ?? flutterAppFlavor;

/// 构建时的app包名
/// 真正的app包名通过以下方法获取↓
/// [platformPackageInfo]
/// [appPlatformPackageName]
String? get $buildPackageName => $buildConfig?.buildPackageName;
