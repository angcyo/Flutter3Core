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
      ..appState = json['appState'] as String?
      ..debugFlagUuidList = (json['debugFlagUuidList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

Map<String, dynamic> _$AppSettingBeanToJson(AppSettingBean instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('platformMap',
      instance.platformMap?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('appState', instance.appState);
  writeNotNull('debugFlagUuidList', instance.debugFlagUuidList);
  return val;
}
