// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_app_setting_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibAppSettingBean _$LibAppSettingBeanFromJson(
  Map<String, dynamic> json,
) => LibAppSettingBean()
  ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : LibAppSettingBean.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..packageNameMap = (json['packageNameMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : LibAppSettingBean.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..buildTypeMap = (json['buildTypeMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : LibAppSettingBean.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..versionUuidMap = (json['versionUuidMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : LibAppSettingBean.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..appState = json['appState'] as String?
  ..debugFlagUuidList = (json['debugFlagUuidList'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList();

Map<String, dynamic> _$LibAppSettingBeanToJson(
  LibAppSettingBean instance,
) => <String, dynamic>{
  'platformMap': ?instance.platformMap?.map((k, e) => MapEntry(k, e?.toJson())),
  'packageNameMap': ?instance.packageNameMap?.map(
    (k, e) => MapEntry(k, e?.toJson()),
  ),
  'buildTypeMap': ?instance.buildTypeMap?.map(
    (k, e) => MapEntry(k, e?.toJson()),
  ),
  'versionUuidMap': ?instance.versionUuidMap?.map(
    (k, e) => MapEntry(k, e?.toJson()),
  ),
  'appState': ?instance.appState,
  'debugFlagUuidList': ?instance.debugFlagUuidList,
};
