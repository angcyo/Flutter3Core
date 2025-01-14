part of '../flutter3_app.dart';

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
void initPlatformNotification({
  required String notifyIcon,
}) {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(notifyIcon);

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings();
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    /*defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),*/
  );

  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
  );

  flutterLocalNotificationsPlugin?.initialize(initializationSettings);
}

late FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

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
  AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
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
  DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
    categoryIdentifier: channelName,
    //sound: ,
  );

  DarwinNotificationDetails macOSNotificationDetails =
      DarwinNotificationDetails(
    categoryIdentifier: channelName,
  );

  LinuxNotificationDetails linuxNotificationDetails =
      const LinuxNotificationDetails(
          //category: LinuxNotificationCategory(channelName),
          //actions: <LinuxNotificationAction>[],
          );

  notificationDetails ??= NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
    macOS: macOSNotificationDetails,
    linux: linuxNotificationDetails,
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
    final bool granted = await flutterLocalNotificationsPlugin
            ?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
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
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedNotificationPermission =
        await androidImplementation?.requestNotificationsPermission();
    return grantedNotificationPermission ?? false;
  }
  //未知平台, 返回null
  return null;
}

//endregion 通知权限
