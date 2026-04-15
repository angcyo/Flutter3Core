// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildConfig _$BuildConfigFromJson(Map<String, dynamic> json) => BuildConfig()
  ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : BuildConfig.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..buildTypeMap = (json['buildTypeMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : BuildConfig.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..buildFlavorMap = (json['buildFlavorMap'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      e == null ? null : BuildConfig.fromJson(e as Map<String, dynamic>),
    ),
  )
  ..json = json['json'] as Map<String, dynamic>?;

Map<String, dynamic> _$BuildConfigToJson(
  BuildConfig instance,
) => <String, dynamic>{
  'platformMap': ?instance.platformMap?.map((k, e) => MapEntry(k, e?.toJson())),
  'buildTypeMap': ?instance.buildTypeMap?.map(
    (k, e) => MapEntry(k, e?.toJson()),
  ),
  'buildFlavorMap': ?instance.buildFlavorMap?.map(
    (k, e) => MapEntry(k, e?.toJson()),
  ),
  'json': ?instance.json,
};
