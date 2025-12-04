// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_app_version_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibAppVersionBean _$LibAppVersionBeanFromJson(Map<String, dynamic> json) =>
    LibAppVersionBean()
      ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LibAppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..packageNameMap = (json['packageNameMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LibAppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..versionUuidMap = (json['versionUuidMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LibAppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..tag = json['tag'] as String?
      ..allowVersionUuidList = (json['allowVersionUuidList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..denyVersionUuidList = (json['denyVersionUuidList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..debug = json['debug'] as bool?
      ..versionTile = json['versionTile'] as String?
      ..versionName = json['versionName'] as String?
      ..versionCode = (json['versionCode'] as num?)?.toInt()
      ..versionRange = json['versionRange'] as String?
      ..versionDes = json['versionDes'] as String?
      ..forceUpdate = json['forceUpdate'] as bool?
      ..downloadUrl = json['downloadUrl'] as String?
      ..marketUrl = json['marketUrl'] as String?
      ..outLink = json['outLink'] as bool?
      ..jumpToMarket = json['jumpToMarket'] as bool?
      ..versionDate = json['versionDate'] as String?
      ..forbiddenVersionMap =
          (json['forbiddenVersionMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              LibAppVersionBean.fromJson(e as Map<String, dynamic>),
            ),
          )
      ..forbiddenTile = json['forbiddenTile'] as String?
      ..forbiddenReason = json['forbiddenReason'] as String?
      ..forceForbidden = json['forceForbidden'] as bool?;

Map<String, dynamic> _$LibAppVersionBeanToJson(
  LibAppVersionBean instance,
) => <String, dynamic>{
  'platformMap': ?instance.platformMap?.map((k, e) => MapEntry(k, e.toJson())),
  'packageNameMap': ?instance.packageNameMap?.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'versionUuidMap': ?instance.versionUuidMap?.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'tag': ?instance.tag,
  'allowVersionUuidList': ?instance.allowVersionUuidList,
  'denyVersionUuidList': ?instance.denyVersionUuidList,
  'debug': ?instance.debug,
  'versionTile': ?instance.versionTile,
  'versionName': ?instance.versionName,
  'versionCode': ?instance.versionCode,
  'versionRange': ?instance.versionRange,
  'versionDes': ?instance.versionDes,
  'forceUpdate': ?instance.forceUpdate,
  'downloadUrl': ?instance.downloadUrl,
  'marketUrl': ?instance.marketUrl,
  'outLink': ?instance.outLink,
  'jumpToMarket': ?instance.jumpToMarket,
  'versionDate': ?instance.versionDate,
  'forbiddenVersionMap': ?instance.forbiddenVersionMap?.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'forbiddenTile': ?instance.forbiddenTile,
  'forbiddenReason': ?instance.forbiddenReason,
  'forceForbidden': ?instance.forceForbidden,
};
