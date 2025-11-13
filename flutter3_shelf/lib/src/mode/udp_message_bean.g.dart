// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'udp_message_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UdpMessageBean _$UdpMessageBeanFromJson(Map<String, dynamic> json) =>
    UdpMessageBean()
      ..deviceId = json['deviceId'] as String?
      ..messageId = json['messageId'] as String?
      ..time = (json['time'] as num?)?.toInt()
      ..type = json['type'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList()
      ..receiveTime = (json['receiveTime'] as num?)?.toInt()
      ..remoteAddress = json['remoteAddress'] as String?
      ..remotePort = (json['remotePort'] as num?)?.toInt();

Map<String, dynamic> _$UdpMessageBeanToJson(UdpMessageBean instance) =>
    <String, dynamic>{
      'deviceId': ?instance.deviceId,
      'messageId': ?instance.messageId,
      'time': ?instance.time,
      'type': ?instance.type,
      'data': ?instance.data,
      'receiveTime': ?instance.receiveTime,
      'remoteAddress': ?instance.remoteAddress,
      'remotePort': ?instance.remotePort,
    };
