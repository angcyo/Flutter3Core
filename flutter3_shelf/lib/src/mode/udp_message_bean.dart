import 'package:flutter3_app/flutter3_app.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local/api/udp_api_bean.dart';

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

  UdpMessageBean.api(UdpApiBean? api)
    : type = UdpMessageTypeEnum.api.name,
      data = api.toJsonString().bytes;

  /// copyWith
  UdpMessageBean copyWith({
    String? deviceId,
    String? messageId,
    int? time,
    String? type,
    List<int>? data,
    int? receiveTime,
    String? remoteAddress,
    int? remotePort,
  }) {
    return UdpMessageBean()
      ..deviceId = deviceId ?? this.deviceId
      ..messageId = messageId ?? this.messageId
      ..time = time ?? this.time
      ..type = type ?? this.type
      ..data = data ?? this.data
      ..receiveTime = receiveTime ?? this.receiveTime
      ..remoteAddress = remoteAddress ?? this.remoteAddress
      ..remotePort = remotePort ?? this.remotePort;
  }

  //--

  /// 客户端的id
  @configProperty
  String? deviceId;

  /// 消息的唯一id
  @configProperty
  String? messageId = $uuid;

  /// 这一包的发送时间, 13位毫秒时间戳
  /// [receiveTime]
  @configProperty
  int? time = nowTime();

  /// 消息的数据类型, 如果是文本消息, 默认使用utf8编码
  /// [UdpMessageTypeEnum]
  /// [data]
  @configProperty
  String? type = UdpMessageTypeEnum.text.name;

  /// 消息的数据
  /// [type]
  @configProperty
  List<int>? data;

  //--

  /// 收到消息的时间
  /// [time]
  /// [receiveTime]
  @autoInjectMark
  int? receiveTime;

  /// 客户端连接的地址, 在服务端收到后自动赋值
  @autoInjectMark
  String? remoteAddress;

  /// 客户端连接的端口, 在服务端收到后自动赋值
  @autoInjectMark
  int? remotePort;

  //--

  /// 消息的文本内容
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get text {
    //debugger();
    if (type == UdpMessageTypeEnum.api.name) {
      final apiBean = this.apiBean;
      return apiBean?.data?.utf8Str ?? apiBean?.headers?.toString();
    }
    return data?.utf8Str;
  }

  /// 数据接收耗时
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get receiveDurationStr =>
      receiveTime != null && time != null && receiveTime! >= time!
      ? LTime.diffTime(time!, endTime: receiveTime!)
      : null;

  /// 数据大小字符串
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get dataSizeStr => data?.size().toSizeStr();

  /// 获取请求的api结构体
  UdpApiBean? get apiBean {
    if (type == UdpMessageTypeEnum.api.name) {
      final jsonString = data?.utf8Str;
      if (isNil(jsonString)) {
        return null;
      }
      try {
        return UdpApiBean.fromJson(jsonString!.fromJson());
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
    return null;
  }
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

  /// api 消息 [UdpMessageBean.data]是[UdpApiBean]结构体的jsonString
  api,
}
