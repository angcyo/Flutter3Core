import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

part 'udp_message_bean.g.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2025/01/16
///
/// udp 一包中的消息结构体
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UdpMessageBean {
  factory UdpMessageBean.fromJson(Map<String, dynamic> json) =>
      _$UdpMessageBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UdpMessageBeanToJson(this);

  UdpMessageBean();

  @override
  String toString() => toJson().toString();

  //--

  UdpMessageBean.bytes(this.data) : type = UdpMessageTypeEnum.bytes.name;

  UdpMessageBean.text(String? text)
      : type = UdpMessageTypeEnum.text.name,
        data = text?.bytes;

  UdpMessageBean.html(String? html)
      : type = UdpMessageTypeEnum.html.name,
        data = html?.bytes;

  UdpMessageBean.markdown(String? markdown)
      : type = UdpMessageTypeEnum.markdown.name,
        data = markdown?.bytes;

  //--

  /// 客户端的id
  String? deviceId;

  /// 消息的唯一id
  String? messageId = $uuid;

  /// 这一包的发送时间, 13位毫秒时间戳
  int? time = nowTime();

  /// 消息的数据类型, 如果是文本消息, 默认使用utf8编码
  /// [UdpMessageTypeEnum]
  /// [data]
  String? type = UdpMessageTypeEnum.bytes.name;

  /// 消息的数据
  /// [type]
  List<int>? data;

  //--

  /// 客户端连接的地址, 在服务端收到后自动赋值
  @autoInjectMark
  String? clientAddress;

  /// 客户端连接的端口, 在服务端收到后自动赋值
  @autoInjectMark
  int? clientPort;
}

/// 消息数据的类型
enum UdpMessageTypeEnum {
  /// 字节数据, 默认
  bytes,

  /// 纯文本消息
  text,

  /// html文本消息
  html,

  /// markdown文本消息
  markdown,
  ;
}
