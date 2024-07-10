part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/10
///
class PackageInfoMeta {
  PackageInfoMeta();

  /// 包名
  String? packageName;

  /// 显示的名称
  String? name;

  /// 描述信息
  String? des;

  /// 启动的url
  String? schemeUrl;

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      "packageName": packageName,
      "name": name,
      "des": des,
      "schemeUrl": schemeUrl,
    };
  }

  /// fromJson
  factory PackageInfoMeta.fromJson(Map<String, dynamic> json) {
    return PackageInfoMeta()
      ..packageName = json["packageName"]
      ..name = json["name"]
      ..des = json["des"]
      ..schemeUrl = json["schemeUrl"];
  }
}
