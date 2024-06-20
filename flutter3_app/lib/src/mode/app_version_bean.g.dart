// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppVersionBean _$AppVersionBeanFromJson(Map<String, dynamic> json) =>
    AppVersionBean()
      ..platformMap = (json['platformMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
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
      ..versionUuidMap = (json['versionUuidMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..packageNameMap = (json['packageNameMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..forbiddenVersionMap =
          (json['forbiddenVersionMap'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AppVersionBean.fromJson(e as Map<String, dynamic>)),
      )
      ..forbiddenTile = json['forbiddenTile'] as String?
      ..forbiddenReason = json['forbiddenReason'] as String?
      ..forceForbidden = json['forceForbidden'] as bool?;

Map<String, dynamic> _$AppVersionBeanToJson(AppVersionBean instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('platformMap', instance.platformMap);
  writeNotNull('debug', instance.debug);
  writeNotNull('versionTile', instance.versionTile);
  writeNotNull('versionName', instance.versionName);
  writeNotNull('versionCode', instance.versionCode);
  writeNotNull('versionDes', instance.versionDes);
  writeNotNull('forceUpdate', instance.forceUpdate);
  writeNotNull('downloadUrl', instance.downloadUrl);
  writeNotNull('marketUrl', instance.marketUrl);
  writeNotNull('outLink', instance.outLink);
  writeNotNull('jumpToMarket', instance.jumpToMarket);
  writeNotNull('versionDate', instance.versionDate);
  writeNotNull('versionUuidMap', instance.versionUuidMap);
  writeNotNull('packageNameMap', instance.packageNameMap);
  writeNotNull('forbiddenVersionMap', instance.forbiddenVersionMap);
  writeNotNull('forbiddenTile', instance.forbiddenTile);
  writeNotNull('forbiddenReason', instance.forbiddenReason);
  writeNotNull('forceForbidden', instance.forceForbidden);
  return val;
}
