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
      ..versionDes = json['versionDes'] as String?
      ..forceUpdate = json['forceUpdate'] as bool?
      ..downloadUrl = json['downloadUrl'] as String?
      ..marketUrl = json['marketUrl'] as String?
      ..outLink = json['outLink'] as bool?
      ..jumpToMarket = json['jumpToMarket'] as bool?
      ..versionDate = json['versionDate'] as String?
      ..forbiddenVersionMap =
          (json['forbiddenVersionMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, LibAppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..forbiddenTile = json['forbiddenTile'] as String?
      ..forbiddenReason = json['forbiddenReason'] as String?
      ..forceForbidden = json['forceForbidden'] as bool?;

Map<String, dynamic> _$LibAppVersionBeanToJson(LibAppVersionBean instance) =>
    <String, dynamic>{
      if (instance.platformMap?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'platformMap': value,
      if (instance.packageNameMap?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'packageNameMap': value,
      if (instance.versionUuidMap?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'versionUuidMap': value,
      if (instance.allowVersionUuidList case final value?)
        'allowVersionUuidList': value,
      if (instance.denyVersionUuidList case final value?)
        'denyVersionUuidList': value,
      if (instance.debug case final value?) 'debug': value,
      if (instance.versionTile case final value?) 'versionTile': value,
      if (instance.versionName case final value?) 'versionName': value,
      if (instance.versionCode case final value?) 'versionCode': value,
      if (instance.versionDes case final value?) 'versionDes': value,
      if (instance.forceUpdate case final value?) 'forceUpdate': value,
      if (instance.downloadUrl case final value?) 'downloadUrl': value,
      if (instance.marketUrl case final value?) 'marketUrl': value,
      if (instance.outLink case final value?) 'outLink': value,
      if (instance.jumpToMarket case final value?) 'jumpToMarket': value,
      if (instance.versionDate case final value?) 'versionDate': value,
      if (instance.forbiddenVersionMap?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'forbiddenVersionMap': value,
      if (instance.forbiddenTile case final value?) 'forbiddenTile': value,
      if (instance.forbiddenReason case final value?) 'forbiddenReason': value,
      if (instance.forceForbidden case final value?) 'forceForbidden': value,
    };
