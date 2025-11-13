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
      ..remoteAddress = json['remoteAddress'] as String?
      ..remotePort = (json['remotePort'] as num?)?.toInt();

Map<String, dynamic> _$UdpClientInfoBeanToJson(UdpClientInfoBean instance) =>
    <String, dynamic>{
      'deviceId': ?instance.deviceId,
      'name': ?instance.name,
      'deviceName': ?instance.deviceName,
      'time': ?instance.time,
      'updateTime': ?instance.updateTime,
      'offlineTime': ?instance.offlineTime,
      'remoteAddress': ?instance.remoteAddress,
      'remotePort': ?instance.remotePort,
    };
