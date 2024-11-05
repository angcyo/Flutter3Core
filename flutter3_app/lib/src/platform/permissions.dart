part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/05
///
/// 平台权限相关处理
abstract class Permissions {
  //region --蓝牙相关权限--

  /// 蓝牙的基础权限
  static final bluetoothPermissions = [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
  ];

  /// 是否有蓝牙权限
  static Future<bool> hasBluetoothPermissions() async {
    final list = await Future.wait(bluetoothPermissions.map((e) => e.status));
    assert(() {
      l.d('权限状态:$list');
      return true;
    }());
    return list.all((element) => element.isGranted);
  }

  /// 请求蓝牙权限
  /// ```
  /// // You can request multiple permissions at once.
  /// Map<Permission, PermissionStatus> statuses = await [
  ///   Permission.location,
  ///   Permission.bluetooth,
  /// ].request();
  /// print(statuses[Permission.location]);
  /// print(statuses[Permission.bluetooth]);
  /// ```
  /// [openAppSettings]打开应用设置页面
  static Future<Map<Permission, PermissionStatus>>
      requestBluetoothPermissions() async {
    final result = await bluetoothPermissions.request();
    assert(() {
      l.d('请求权限返回:$result');
      return true;
    }());
    return result;
  }

  //endregion --蓝牙相关权限--

  //region --Wifi相关权限--

  /// 获取wifi名称需要的权限
  static final wifiPermissions = [
    Permission.location,
  ];

  /// 是否有Wifi权限
  static Future<bool> hasWifiPermissions() async {
    final list = await Future.wait(wifiPermissions.map((e) => e.status));
    assert(() {
      l.d('权限状态:$list');
      return true;
    }());
    return list.all((element) => element.isGranted);
  }

  /// 请求Wifi权限
  static Future<Map<Permission, PermissionStatus>>
      requestWifiPermissions() async {
    final result = await wifiPermissions.request();
    assert(() {
      l.d('请求权限返回:$result');
      return true;
    }());
    return result;
  }

//endregion --Wifi相关权限--
}
