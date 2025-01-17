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
      if (instance.serviceUuid case final value?) 'serviceUuid': value,
      if (instance.serviceVersion case final value?) 'serviceVersion': value,
      if (instance.servicePort case final value?) 'servicePort': value,
      if (instance.serviceStartTime case final value?)
        'serviceStartTime': value,
      if (instance.deviceId case final value?) 'deviceId': value,
      if (instance.deviceName case final value?) 'deviceName': value,
    };
