// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildConfig _$BuildConfigFromJson(Map<String, dynamic> json) => BuildConfig()
  ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, BuildConfig.fromJson(e as Map<String, dynamic>)),
  )
  ..buildPackageName = json['buildPackageName'] as String?
  ..buildFlavor = json['buildFlavor'] as String?
  ..buildType = json['buildType'] as String?
  ..buildVersionName = json['buildVersionName'] as String?
  ..buildVersionCode = (json['buildVersionCode'] as num?)?.toInt()
  ..buildTime = json['buildTime'] as String?
  ..buildOperatingSystem = json['buildOperatingSystem'] as String?
  ..buildOperatingSystemVersion = json['buildOperatingSystemVersion'] as String?
  ..buildOperatingSystemLocaleName =
      json['buildOperatingSystemLocaleName'] as String?
  ..buildOperatingSystemUserName =
      json['buildOperatingSystemUserName'] as String?;

Map<String, dynamic> _$BuildConfigToJson(BuildConfig instance) =>
    <String, dynamic>{
      if (instance.platformMap?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'platformMap': value,
      if (instance.buildPackageName case final value?)
        'buildPackageName': value,
      if (instance.buildFlavor case final value?) 'buildFlavor': value,
      if (instance.buildType case final value?) 'buildType': value,
      if (instance.buildVersionName case final value?)
        'buildVersionName': value,
      if (instance.buildVersionCode case final value?)
        'buildVersionCode': value,
      if (instance.buildTime case final value?) 'buildTime': value,
      if (instance.buildOperatingSystem case final value?)
        'buildOperatingSystem': value,
      if (instance.buildOperatingSystemVersion case final value?)
        'buildOperatingSystemVersion': value,
      if (instance.buildOperatingSystemLocaleName case final value?)
        'buildOperatingSystemLocaleName': value,
      if (instance.buildOperatingSystemUserName case final value?)
        'buildOperatingSystemUserName': value,
    };
