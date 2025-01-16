import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_info_bean.g.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2025/01/16
///
/// [UdpService]服务的信息
///
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ServiceInfoBean {
  factory ServiceInfoBean.fromJson(Map<String, dynamic> json) =>
      _$ServiceInfoBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceInfoBeanToJson(this);

  ServiceInfoBean();

  @override
  String toString() => toJson().toString();

  //--

  /// 服务的唯一标识
  String? serviceUuid = $uuid;

  /// 服务的版本号
  int? serviceVersion = 1;

  /// 服务的端口
  /// 客户端的端口, 不一定有
  int? servicePort = -1;

  /// 服务的开始时间戳13位毫秒
  int? serviceStartTime = nowTime();
}
