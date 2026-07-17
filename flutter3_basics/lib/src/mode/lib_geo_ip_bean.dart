import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lib_geo_ip_bean.g.dart';

/// ip地址对应的信息
/// https://api.ip.sb/geoip/45.145.154.229
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LibGeoIpBean with Equatable {
  String? country;
  String? organization;
  @JsonKey(name: 'country_code')
  String? countryCode;
  String? isp;
  @JsonKey(name: 'asn_organization')
  String? asnOrganization;
  int? asn;
  int? offset;
  String? timezone;
  double? latitude;
  String? ip;
  @JsonKey(name: 'continent_code')
  String? continentCode;
  double? longitude;

  //--非标准

  @JsonKey(name: 'country_name')
  String? countryName;

  //--

  /// 国家旗帜svg
  /// https://flagpedia.asia/download/api
  String? get countryFlagSvg => countryCode == null
      ? null
      : "https://flagcdn.com/${countryCode!.toLowerCase()}.svg";

  /// 国家旗帜png
  /// - 4:3 的比例 20x15 32x24 40x30 80x60
  /// https://flagpedia.asia/download/api
  String? get countryFlagPng => countryCode == null
      ? null
      : "https://flagcdn.com/40x30/${countryCode!.toLowerCase()}.png";

  LibGeoIpBean();

  factory LibGeoIpBean.fromJson(Map<String, dynamic> json) =>
      _$LibGeoIpBeanFromJson(json);

  Map<String, dynamic> toJson() => _$LibGeoIpBeanToJson(this);

  @override
  String toString() => toJson().toString();

  @override
  List<Object?> get props => [ip];
}
