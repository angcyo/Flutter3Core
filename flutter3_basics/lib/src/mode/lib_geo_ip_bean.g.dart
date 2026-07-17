// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lib_geo_ip_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibGeoIpBean _$LibGeoIpBeanFromJson(Map<String, dynamic> json) => LibGeoIpBean()
  ..country = json['country'] as String?
  ..organization = json['organization'] as String?
  ..countryCode = json['country_code'] as String?
  ..isp = json['isp'] as String?
  ..asnOrganization = json['asn_organization'] as String?
  ..asn = (json['asn'] as num?)?.toInt()
  ..offset = (json['offset'] as num?)?.toInt()
  ..timezone = json['timezone'] as String?
  ..latitude = (json['latitude'] as num?)?.toDouble()
  ..ip = json['ip'] as String?
  ..continentCode = json['continent_code'] as String?
  ..longitude = (json['longitude'] as num?)?.toDouble()
  ..countryName = json['country_name'] as String?;

Map<String, dynamic> _$LibGeoIpBeanToJson(LibGeoIpBean instance) =>
    <String, dynamic>{
      'country': instance.country,
      'organization': instance.organization,
      'country_code': instance.countryCode,
      'isp': instance.isp,
      'asn_organization': instance.asnOrganization,
      'asn': instance.asn,
      'offset': instance.offset,
      'timezone': instance.timezone,
      'latitude': instance.latitude,
      'ip': instance.ip,
      'continent_code': instance.continentCode,
      'longitude': instance.longitude,
      'country_name': instance.countryName,
    };
