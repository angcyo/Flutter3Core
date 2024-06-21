// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_setting_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettingBean _$AppSettingBeanFromJson(Map<String, dynamic> json) =>
    AppSettingBean()
      ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AppSettingBean.fromJson(e as Map<String, dynamic>)),
      )
      ..packageName = json['packageName'] as String?
      ..appFlavor = json['appFlavor'] as String?
      ..appState = json['appState'] as String?
      ..appFlavorUuidList = (json['appFlavorUuidList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..debugFlagUuidList = (json['debugFlagUuidList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..buildTime = json['buildTime'] as String?
      ..operatingSystem = json['operatingSystem'] as String?
      ..operatingSystemVersion = json['operatingSystemVersion'] as String?
      ..operatingSystemLocaleName = json['operatingSystemLocaleName'] as String?
      ..operatingSystemUserName = json['operatingSystemUserName'] as String?;

Map<String, dynamic> _$AppSettingBeanToJson(AppSettingBean instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('platformMap', instance.platformMap);
  writeNotNull('packageName', instance.packageName);
  writeNotNull('appFlavor', instance.appFlavor);
  writeNotNull('appState', instance.appState);
  writeNotNull('appFlavorUuidList', instance.appFlavorUuidList);
  writeNotNull('debugFlagUuidList', instance.debugFlagUuidList);
  writeNotNull('buildTime', instance.buildTime);
  writeNotNull('operatingSystem', instance.operatingSystem);
  writeNotNull('operatingSystemVersion', instance.operatingSystemVersion);
  writeNotNull('operatingSystemLocaleName', instance.operatingSystemLocaleName);
  writeNotNull('operatingSystemUserName', instance.operatingSystemUserName);
  return val;
}
