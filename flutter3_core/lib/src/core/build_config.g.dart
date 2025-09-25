// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildConfig _$BuildConfigFromJson(Map<String, dynamic> json) => BuildConfig()
  ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, BuildConfig.fromJson(e as Map<String, dynamic>)),
  )
  ..buildTypeMap = (json['buildTypeMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, BuildConfig.fromJson(e as Map<String, dynamic>)),
  )
  ..buildFlavorMap = (json['buildFlavorMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, BuildConfig.fromJson(e as Map<String, dynamic>)),
  )
  ..buildPackageName = json['buildPackageName'] as String?
  ..buildType = json['buildType'] as String?
  ..buildFlavor = json['buildFlavor'] as String?
  ..buildVersionName = json['buildVersionName'] as String?
  ..buildVersionCode = (json['buildVersionCode'] as num?)?.toInt()
  ..buildTime = json['buildTime'] as String?
  ..buildOperatingSystem = json['buildOperatingSystem'] as String?
  ..buildOperatingSystemVersion = json['buildOperatingSystemVersion'] as String?
  ..buildOperatingSystemLocaleName =
      json['buildOperatingSystemLocaleName'] as String?
  ..buildOperatingSystemUserName =
      json['buildOperatingSystemUserName'] as String?
  ..json = json['json'] as Map<String, dynamic>?;

Map<String, dynamic> _$BuildConfigToJson(
  BuildConfig instance,
) => <String, dynamic>{
  'platformMap': ?instance.platformMap?.map((k, e) => MapEntry(k, e.toJson())),
  'buildTypeMap': ?instance.buildTypeMap?.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'buildFlavorMap': ?instance.buildFlavorMap?.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'buildPackageName': ?instance.buildPackageName,
  'buildType': ?instance.buildType,
  'buildFlavor': ?instance.buildFlavor,
  'buildVersionName': ?instance.buildVersionName,
  'buildVersionCode': ?instance.buildVersionCode,
  'buildTime': ?instance.buildTime,
  'buildOperatingSystem': ?instance.buildOperatingSystem,
  'buildOperatingSystemVersion': ?instance.buildOperatingSystemVersion,
  'buildOperatingSystemLocaleName': ?instance.buildOperatingSystemLocaleName,
  'buildOperatingSystemUserName': ?instance.buildOperatingSystemUserName,
  'json': ?instance.json,
};
