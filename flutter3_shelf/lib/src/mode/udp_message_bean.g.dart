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
      ..clientAddress = json['clientAddress'] as String?
      ..clientPort = (json['clientPort'] as num?)?.toInt();

Map<String, dynamic> _$UdpMessageBeanToJson(UdpMessageBean instance) =>
    <String, dynamic>{
      if (instance.deviceId case final value?) 'deviceId': value,
      if (instance.messageId case final value?) 'messageId': value,
      if (instance.time case final value?) 'time': value,
      if (instance.type case final value?) 'type': value,
      if (instance.data case final value?) 'data': value,
      if (instance.clientAddress case final value?) 'clientAddress': value,
      if (instance.clientPort case final value?) 'clientPort': value,
    };
