import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'udp_client_info_bean.g.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2025/01/16
///
/// 客户端信息数据结构
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UdpClientInfoBean {
  factory UdpClientInfoBean.fromJson(Map<String, dynamic> json) =>
      _$UdpClientInfoBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UdpClientInfoBeanToJson(this);

  UdpClientInfoBean();

  @override
  String toString() => toJson().toString();

  //--

  /// 客户端的id
  String? deviceId;

  /// 客户端的名称
  String? name;

  /// 客户端在线时间
  int? time;

  //--

  /// 客户端连接的地址, 在服务端收到后自动赋值
  @autoInjectMark
  String? clientAddress;

  /// 客户端连接的端口, 在服务端收到后自动赋值
  @autoInjectMark
  int? clientPort;

  //--

  /// 客户端显示的名称
  String? get clientShowName => name ?? "$clientAddress:$clientPort";
}
