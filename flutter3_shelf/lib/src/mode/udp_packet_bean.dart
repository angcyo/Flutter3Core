import 'dart:convert';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:json_annotation/json_annotation.dart';

import 'udp_client_info_bean.dart';
import 'udp_message_bean.dart';

part 'udp_packet_bean.g.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2025/01/16
///
/// udp 每一包的数据结构体
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UdpPacketBean {
  factory UdpPacketBean.fromJson(Map<String, dynamic> json) =>
      _$UdpPacketBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UdpPacketBeanToJson(this);

  UdpPacketBean();

  @override
  String toString() => toJson().toString();

  static Future<UdpPacketBean?> fromBytes(List<int> data) async {
    try {
      return isolateRun((){
        final text = data.utf8Str;
        final packetBean = UdpPacketBean.fromJson(text.fromJson());
        return packetBean;
      });
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
      return null;
    }
  }

  //--

  /// 这一包的唯一id
  @configProperty
  String? packetId = $uuid;

  /// 这一包的发送时间, 13位毫秒时间戳
  @configProperty
  int? time = nowTime();

  /// 这一包发送的设备id
  @configProperty
  String? deviceId;

  /// 这一包的类型
  /// [UdpPacketTypeEnum]
  @configProperty
  String? type;

  //--

  /// 这一包的核心数据
  /// [type]
  /// - 消息包时数据是:[UdpMessageBean]
  /// - 心跳包时数据是:[UdpClientInfoBean]
  @configProperty
  List<int>? data;

  //region get

  /// 将[data]解析成[UdpMessageBean]
  UdpMessageBean? get message {
    if (type == UdpPacketTypeEnum.message.name && data != null) {
      return UdpMessageBean.fromJson(jsonDecode(data!.utf8Str));
    }
    return null;
  }

  /// 将[data]解析成[UdpClientInfoBean]
  UdpClientInfoBean? get client {
    if (type == UdpPacketTypeEnum.heart.name) {
      if (data != null) {
        return UdpClientInfoBean.fromJson(jsonDecode(data!.utf8Str));
      }
    }
    return null;
  }

//endregion get
}

/// 数据包的类型
enum UdpPacketTypeEnum {
  /// 心跳类型
  /// 心跳消息中应该包含客户端的基础信息
  heart,

  /// 消息类型
  message,
  ;
}
