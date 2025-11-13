import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'udp_api_bean.g.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/11/13
///
/// UDP 发送指令的数据结构
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UdpApiBean {
  factory UdpApiBean.fromJson(Map<String, dynamic> json) =>
      _$UdpApiBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UdpApiBeanToJson(this);

  UdpApiBean();

  @override
  String toString() => toJson().toString();

  /// 请求的id
  @configProperty
  String? id = $uuid;

  /// 请求的方法
  @configProperty
  String? method;

  /// 请求/返回的数据
  @configProperty
  List<int>? data;
}
