import 'package:flutter3_app/flutter3_app.dart';
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
  @configProperty
  String? deviceId = $deviceUuid;

  /// 客户端的名称
  @configProperty
  String? name;

  //--

  /// 客户端的平台设备名称
  @flagProperty
  String? deviceName = $platformDeviceInfoCache?.platformDeviceName;

  //--

  /// 客户端首次在线时间
  @autoInjectMark
  int? time;

  /// 客户端更新时间, 用来检查离线
  @autoInjectMark
  int? updateTime;

  /// 客户端离线时间
  @autoInjectMark
  int? offlineTime;

  /// 客户端连接的地址, 在服务端收到后自动赋值
  @autoInjectMark
  String? clientAddress;

  /// 客户端连接的端口, 在服务端收到后自动赋值
  @autoInjectMark
  int? clientPort;

  //--

  /// 客户端是否离线
  bool get isOffline => offlineTime != null;

  /// 客户端显示的名称
  String? get clientShowName => name ?? deviceName ?? clientIpAddress;

  /// ip地址
  /// [InternetAddress]
  String? get clientIpAddress => name ?? "$clientAddress:$clientPort";
}
