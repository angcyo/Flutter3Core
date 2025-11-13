// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'udp_packet_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UdpPacketBean _$UdpPacketBeanFromJson(Map<String, dynamic> json) =>
    UdpPacketBean()
      ..packetId = json['packetId'] as String?
      ..time = (json['time'] as num?)?.toInt()
      ..deviceId = json['deviceId'] as String?
      ..type = json['type'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList();

Map<String, dynamic> _$UdpPacketBeanToJson(UdpPacketBean instance) =>
    <String, dynamic>{
      'packetId': ?instance.packetId,
      'time': ?instance.time,
      'deviceId': ?instance.deviceId,
      'type': ?instance.type,
      'data': ?instance.data,
    };
