// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'udp_client_info_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UdpClientInfoBean _$UdpClientInfoBeanFromJson(Map<String, dynamic> json) =>
    UdpClientInfoBean()
      ..deviceId = json['deviceId'] as String?
      ..name = json['name'] as String?
      ..deviceName = json['deviceName'] as String?
      ..time = (json['time'] as num?)?.toInt()
      ..updateTime = (json['updateTime'] as num?)?.toInt()
      ..offlineTime = (json['offlineTime'] as num?)?.toInt()
      ..clientAddress = json['clientAddress'] as String?
      ..clientPort = (json['clientPort'] as num?)?.toInt();

Map<String, dynamic> _$UdpClientInfoBeanToJson(UdpClientInfoBean instance) =>
    <String, dynamic>{
      if (instance.deviceId case final value?) 'deviceId': value,
      if (instance.name case final value?) 'name': value,
      if (instance.deviceName case final value?) 'deviceName': value,
      if (instance.time case final value?) 'time': value,
      if (instance.updateTime case final value?) 'updateTime': value,
      if (instance.offlineTime case final value?) 'offlineTime': value,
      if (instance.clientAddress case final value?) 'clientAddress': value,
      if (instance.clientPort case final value?) 'clientPort': value,
    };
