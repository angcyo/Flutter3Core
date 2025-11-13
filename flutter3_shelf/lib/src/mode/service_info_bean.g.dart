// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_info_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceInfoBean _$ServiceInfoBeanFromJson(Map<String, dynamic> json) =>
    ServiceInfoBean()
      ..serviceUuid = json['serviceUuid'] as String?
      ..serviceVersion = (json['serviceVersion'] as num?)?.toInt()
      ..servicePort = (json['servicePort'] as num?)?.toInt()
      ..serviceStartTime = (json['serviceStartTime'] as num?)?.toInt()
      ..deviceId = json['deviceId'] as String?
      ..deviceName = json['deviceName'] as String?;

Map<String, dynamic> _$ServiceInfoBeanToJson(ServiceInfoBean instance) =>
    <String, dynamic>{
      'serviceUuid': ?instance.serviceUuid,
      'serviceVersion': ?instance.serviceVersion,
      'servicePort': ?instance.servicePort,
      'serviceStartTime': ?instance.serviceStartTime,
      'deviceId': ?instance.deviceId,
      'deviceName': ?instance.deviceName,
    };
