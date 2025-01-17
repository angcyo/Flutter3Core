part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///

/// 包信息
/// https://pub.dev/packages/package_info_plus
/// ```
/// //Be sure to add this line if `PackageInfo.fromPlatform()` is called before runApp()
/// WidgetsFlutterBinding.ensureInitialized();
/// ```
///
/// ```
/// String appName = packageInfo.appName;
/// String packageName = packageInfo.packageName;
/// String version = packageInfo.version;            //versionName
/// String buildNumber = packageInfo.buildNumber;    //versionCode
/// ```
/// # 在Release模式下运行会报错
/// ```
/// Unhandled Exception: MissingPluginException(No implementation found for method getAll on channel dev.fluttercommunity.plus/package_info)
/// ```
Future<PackageInfo> get $platformPackageInfo async {
  final packageInfo = await PackageInfo.fromPlatform();
  _platformPackageInfoCache = packageInfo;
  return packageInfo;
}

/// [$platformPackageInfo]的缓存数据
/// 请使用[$platformPackageInfo]先获取一次数据, 缓存才有效
/// [PackageInfo.version]
/// [PackageInfo.buildNumber]
/// [PackageInfo.packageName]
PackageInfo? get $platformPackageInfoCache {
  $platformPackageInfo.ignore();
  return _platformPackageInfoCache;
}

PackageInfo? _platformPackageInfoCache;

/// app版本名称
Future<String> get $appVersionName async =>
    (await $platformPackageInfo).version;

/// app版本号
Future<String> get $appVersionCode async =>
    (await $platformPackageInfo).buildNumber;

/// app平台的包名
Future<String> get $appPlatformPackageName async =>
    (await $platformPackageInfo).packageName;

//--

/// https://pub.dev/packages/device_info_plus
/// 获取对应平台的设备信息
Future<BaseDeviceInfo> get $platformDeviceInfo async {
  final deviceInfo = isAndroid
      ? await DeviceInfoPlugin().androidInfo
      : isIos
          ? await DeviceInfoPlugin().iosInfo
          : isLinux
              ? await DeviceInfoPlugin().linuxInfo
              : isMacOS
                  ? await DeviceInfoPlugin().macOsInfo
                  : isWindows
                      ? await DeviceInfoPlugin().windowsInfo
                      : await DeviceInfoPlugin().webBrowserInfo;
  _platformDeviceInfoCache = deviceInfo;
  return deviceInfo;
}

/// 缓存
/// # WindowsDeviceInfo
///
/// ```
///{computerName: Hi-angcyo-pc, numberOfCores: 16, systemMemoryInMegabytes: 65534,
///userName: angcyo, majorVersion: 10, minorVersion: 0, buildNumber: 19045, platformId: 2,
///csdVersion: , servicePackMajor: 0, servicePackMinor: 0, suitMask: 256, productType: 1,
///reserved: 0, buildLab: 19041.vb_release.191206-1406,
///buildLabEx: 19041.1.amd64fre.vb_release.191206-1406,
///digitalProductId: [164, 0, 0, 0, 3, 0, 0, 0, 48, 48, 51, 51, 48, 45, 56, 48, 48, 48, 48, 45, 48, 48, 48, 48, 48, 45, 65, 65, 48, 53, 53, 0, 236, 12, 0, 0, 91, 84, 72, 93, 88, 49, 57, 45, 57, 56, 56, 52, 49, 0, 0, 0, 236, 12, 0, 0, 0, 0, 168, 210, 123, 110, 137, 129, 79, 109, 9, 0, 0, 0, 0, 0, 61, 18, 63, 98, 207, 87, 18, 208, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 111, 97, 221, 128],
///displayVersion: 22H2, editionId: Professional, installDate: 2022-03-26 13:17:42.000,
///productId: 00330-80000-00000-AA055, productName: Windows 10 Pro, registeredOwner: angcyo@126.com,
///releaseId: 2009, deviceId: {E401667C-1DD8-42E3-9245-F91D5CFCF200}}
/// ```
///
BaseDeviceInfo? get $platformDeviceInfoCache {
  $platformDeviceInfo.ignore();
  assert(() {
    l.d(_platformDeviceInfoCache?.runtimeType);
    l.d(_platformDeviceInfoCache?.data);
    return true;
  }());
  return _platformDeviceInfoCache;
}

BaseDeviceInfo? _platformDeviceInfoCache;

/// 获取Android平台的版本
/// 非Android平台返回null
Future<int?> get $androidSdkInt async => isAndroid
    ? ((await $platformDeviceInfo) as AndroidDeviceInfo?)?.version.sdkInt
    : null;

/// 手机型号
Future<String?> get $platformDeviceModel async => isAndroid
    //product: T33_7863_U254_V11_FHD_1095_Natv
    //supportedAbis: [arm64-v8a, armeabi-v7a, armeabi]
    ? ((await $platformDeviceInfo) as AndroidDeviceInfo?)?.model
    : isIos
        ? ((await $platformDeviceInfo) as IosDeviceInfo?)?.model
        : isLinux
            ? ((await $platformDeviceInfo) as LinuxDeviceInfo?)?.prettyName
            : isMacOS
                ? ((await $platformDeviceInfo) as MacOsDeviceInfo?)?.model
                : isWindows
                    ? ((await $platformDeviceInfo) as WindowsDeviceInfo?)
                        ?.productName
                    : null;

/// https://pub.dev/packages/share_plus
/// `share_plus 需要 iPad 用户提供参数 sharePositionOrigin 。`
extension ShareBytesEx on Uint8List {
  /// 分享字节数据
  Future<ShareResult> share({
    String? subject,
    String? text,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    return Share.shareXFiles(
      [XFile.fromData(this)],
      subject: subject,
      text: text,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
  }
}

/// 图片分享
extension ShareImageEx on UiImage {
  /// 分享图片
  Future<ShareResult> share({
    String? subject,
    String? text,
    String? imageName,
    UiImageByteFormat format = UiImageByteFormat.png,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    final byteData = await toByteData(format: format);
    final bytes = byteData?.buffer.asUint8List();
    return Share.shareXFiles(
      [
        XFile.fromData(
          bytes ?? Uint8List(0),
          mimeType: imageName?.mimeType(bytes) ?? "image/png",
          name: imageName,
        )
      ],
      subject: subject,
      text: text,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
  }
}

extension ShareFileEx on File {
  /// 分享文件
  Future<ShareResult> share({
    String? subject,
    String? text,
    String? mimeType,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async =>
      path.shareFile(
        otherFiles: null,
        subject: subject,
        text: text,
        mimeType: mimeType ?? 'application/octet-stream',
        shareContext: shareContext,
        sharePositionOrigin: sharePositionOrigin,
      );
}

/// https://pub.dev/packages/share_plus
extension ShareStringEx on String {
  /// 分享文本
  /// https://pub.dev/packages/share_plus
  @allPlatformFlag
  Future<ShareResult> share({
    String? subject,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    return Share.share(
      this,
      subject: subject,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
  }

  /// 分享文件
  /// [mimeType] 文件类型
  ///
  /// https://pub.dev/packages/share_plus
  @PlatformFlag("Android iOS MacOS Web Windows")
  Future<ShareResult> shareFile({
    List<String>? otherFiles,
    String? subject,
    String? text,
    String? mimeType,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    return Share.shareXFiles(
      [
        XFile(this, mimeType: mimeType),
        ...?otherFiles?.map((e) => XFile(e, mimeType: mimeType))
      ],
      subject: subject,
      text: text,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
  }
}
