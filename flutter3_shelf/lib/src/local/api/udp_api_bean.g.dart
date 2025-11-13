// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'udp_api_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UdpApiBean _$UdpApiBeanFromJson(Map<String, dynamic> json) => UdpApiBean()
  ..id = json['id'] as String?
  ..method = json['method'] as String?
  ..headers = json['headers'] as Map<String, dynamic>?
  ..data = (json['data'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList();

Map<String, dynamic> _$UdpApiBeanToJson(UdpApiBean instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'method': ?instance.method,
      'headers': ?instance.headers,
      'data': ?instance.data,
    };
