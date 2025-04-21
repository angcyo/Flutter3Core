// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_app_setting_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibAppSettingBean _$LibAppSettingBeanFromJson(Map<String, dynamic> json) =>
    LibAppSettingBean()
      ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LibAppSettingBean.fromJson(e as Map<String, dynamic>)),
      )
      ..appState = json['appState'] as String?
      ..debugFlagUuidList = (json['debugFlagUuidList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();

Map<String, dynamic> _$LibAppSettingBeanToJson(LibAppSettingBean instance) =>
    <String, dynamic>{
      if (instance.platformMap?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'platformMap': value,
      if (instance.appState case final value?) 'appState': value,
      if (instance.debugFlagUuidList case final value?)
        'debugFlagUuidList': value,
    };
