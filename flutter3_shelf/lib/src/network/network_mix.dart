part of flutter3_shelf;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/08/09
///
/// `network_info_plus` 网络相关混合操作

/// 获取wifi的名称, 也就是ssid
/// Android需要位置权限
@permissionFlag
Future<String?> $getWifiName() async {
  final info = NetworkInfo();
  String? name = await info.getWifiName();
  if (name != null && name.length > 2) {
    // "FooNetwork" 去掉首尾引号
    name = name.substring(1, name.length - 1);
  }
  return name;
}

/// 获取上次获取到的wifi ip地址
/// 需要先调用[networkWifiIp]
String? _lastWifiIpCache;

String? get $lastWifiIpCache {
  $getWifiIp();
  return _lastWifiIpCache;
}

/// 获取wifi的ip
///
/// - 手机网络, 也会返回ip 10.143.37.113
///
Future<String?> $getWifiIp() async {
  final info = NetworkInfo();
  _lastWifiIpCache = await info.getWifiIP();
  return _lastWifiIpCache;
}

/// [$isWifiConnected]的缓存
bool _isWifiConnectedCache = true;

bool get $isWifiConnectedCache {
  $isWifiConnected();
  return _isWifiConnectedCache;
}

/// 判断wifi是否连接
///
/// `connectivity_plus`
///
/// 移动网络没有网关ip, 通过此方法判断wifi是否连接
///
Future<bool> $isWifiConnected() async {
  final info = NetworkInfo();
  final wifiGatewayIp = await info.getWifiGatewayIP();
  _isWifiConnectedCache = wifiGatewayIp != null && wifiGatewayIp.isNotEmpty;
  assert(() {
    l.v("网关IP:$wifiGatewayIp");
    return true;
  }());
  return _isWifiConnectedCache;
}
