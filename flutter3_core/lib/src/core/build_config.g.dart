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
  ..buildTime = json['buildTime'] as String?
  ..buildOperatingSystem = json['buildOperatingSystem'] as String?
  ..buildOperatingSystemVersion = json['buildOperatingSystemVersion'] as String?
  ..buildOperatingSystemLocaleName =
      json['buildOperatingSystemLocaleName'] as String?
  ..buildOperatingSystemUserName =
      json['buildOperatingSystemUserName'] as String?;

Map<String, dynamic> _$BuildConfigToJson(BuildConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('platformMap',
      instance.platformMap?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('buildPackageName', instance.buildPackageName);
  writeNotNull('buildFlavor', instance.buildFlavor);
  writeNotNull('buildType', instance.buildType);
  writeNotNull('buildTime', instance.buildTime);
  writeNotNull('buildOperatingSystem', instance.buildOperatingSystem);
  writeNotNull(
      'buildOperatingSystemVersion', instance.buildOperatingSystemVersion);
  writeNotNull('buildOperatingSystemLocaleName',
      instance.buildOperatingSystemLocaleName);
  writeNotNull(
      'buildOperatingSystemUserName', instance.buildOperatingSystemUserName);
  return val;
}
