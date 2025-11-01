import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/28
///
/// App本地通知
/// PLATFORM: ANDROID IOS LINUX MACOS
/// 初始化通知
/// [notifyIcon] 通知栏图标, Android中图标需要放在drawable目录下
/// 默认图标名称`defaultIcon`
///
@callPoint
@PlatformFlag("Android iOS Linux macOS Windows")
void initPlatformNotification({required String notifyIcon}) {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  final initializationSettingsAndroid = AndroidInitializationSettings(
    notifyIcon,
  );

  final initializationSettingsIOS = DarwinInitializationSettings();
  final initializationSettingsMacOS = DarwinInitializationSettings();
  final initializationSettingsLinux = LinuxInitializationSettings(
    defaultActionName:
        'Open notification' /*defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),*/,
  );
  final initializationSettingsWindows = WindowsInitializationSettings(
    appName: 'Flutter Local Notifications Example',
    appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
    // Search online for GUID generators to make your own
    guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
  );

  final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
    windows: initializationSettingsWindows,
  );

  flutterLocalNotificationsPlugin?.initialize(initializationSettings);
}

late FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

/// -[FlutterLocalNotificationsPlugin.cancelAll] 取消所有通知
FlutterLocalNotificationsPlugin? get $notify => flutterLocalNotificationsPlugin;

///[importance] 重要性
///[priority] 优先级
///[channelName] 通道名称/iOS分类标识符
Future<void> showPlatformNotification({
  required int id,
  String? title,
  String? content,
  NotificationDetails? notificationDetails,
  String? channelName,
  Importance? importance,
  Priority? priority,
  String? payload,
  String? androidChannelId,
  String? androidChannelDescription,
}) async {
  channelName ??= "Default";
  final androidNotificationDetails = AndroidNotificationDetails(
    androidChannelId ?? "Default",
    channelName,
    channelDescription: androidChannelDescription,
    importance: importance ?? Importance.max,
    priority: priority ?? Priority.high,
    ticker: content ?? title,
    //actions: ,
    //autoCancel: ,
    //enableLights: ,
    //enableVibration:,
  );
  final iosNotificationDetails = DarwinNotificationDetails(
    categoryIdentifier: channelName,
    //sound: ,
  );

  final macOSNotificationDetails = DarwinNotificationDetails(
    categoryIdentifier: channelName,
  );

  final linuxNotificationDetails = const LinuxNotificationDetails(
    //category: LinuxNotificationCategory(channelName),
    //actions: <LinuxNotificationAction>[],
  );

  final windowsNotificationDetails = WindowsNotificationDetails(
    //icon: ,
    //actions: ,
    //critical: ,
    //group: ,
    //groupSummary: ,
    //largeIcon: ,
    //suppressSound: ,
    //tag: ,
    //timestamp: ,
    //vibrates: ,
  );

  notificationDetails ??= NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
    macOS: macOSNotificationDetails,
    linux: linuxNotificationDetails,
    windows: windowsNotificationDetails,
  );
  await flutterLocalNotificationsPlugin?.show(
    id,
    title,
    content,
    payload: payload,
    notificationDetails,
  );
}

Future<void> cancelNotification(int id, {String? tag}) async {
  await flutterLocalNotificationsPlugin?.cancel(id, tag: tag);
}

//region 通知权限

/// Android平台通知权限是否给予
Future<bool?> isAndroidNotificationsPermissionGranted() async {
  if (isAndroid) {
    final bool granted =
        await flutterLocalNotificationsPlugin
            ?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
    return granted;
  }
  //非Android平台, 返回null
  return null;
}

/// 请求通知权限
Future<bool?> requestNotificationsPermissions() async {
  if (isIos || isMacOS) {
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } else if (isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            ?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool? grantedNotificationPermission = await androidImplementation
        ?.requestNotificationsPermission();
    return grantedNotificationPermission ?? false;
  }
  //未知平台, 返回null
  return null;
}

//endregion 通知权限
