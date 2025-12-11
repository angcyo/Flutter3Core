part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// 网络地址
class NetworkAddress {
  NetworkAddress(this.ip, {required this.openPorts, this.exists = true});

  ///  ip
  String ip;

  /// 开放的端口
  List<int> openPorts;

  /// 是否存在这个[ip]
  bool exists;

  @override
  String toString() {
    return "Instance of 'NetworkAddress(ip:$ip, exists: $exists, openPort: ${openPorts.toList()});'";
  }
}
