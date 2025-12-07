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
/// Unhandled Exception: MissingPluginException(No implementation found for method getAll on channel dev.flutter.community.plus/package_info)
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

String? get $appVersionNameCache => $platformPackageInfoCache?.version;

/// app版本号
Future<String> get $appVersionCode async =>
    (await $platformPackageInfo).buildNumber;

String? get $appVersionCodeCache => $platformPackageInfoCache?.buildNumber;

/// app平台的包名
Future<String> get $appPlatformPackageName async =>
    (await $platformPackageInfo).packageName;

String? get $appPlatformPackageNameCache =>
    $platformPackageInfoCache?.packageName;

/// 获取应用构建的版本
Future<String> get $appBuildVersion async => stringBuilder((builder) async {
      builder.append(await $appVersionName);
      builder.append("(${await $appVersionCode})");
      final config = $buildConfig;
      if (!isNil(config?.buildType)) {
        builder.append("-${config?.buildType}");
      }
      final flavor = $buildFlavor;
      if (!isNil(flavor)) {
        builder.append("-$flavor");
      }
      if (isDebugFlag) {
        builder.append("(debug)");
      }
    });

/// 获取应用构建的版本
String get $appBuildVersionCache => stringBuilder((builder) async {
      builder.append($appVersionNameCache);
      builder.append("(${$appVersionCodeCache})");
      final config = $buildConfig;
      if (!isNil(config?.buildType)) {
        builder.append("-${config?.buildType}");
      }
      final flavor = $buildFlavor;
      if (!isNil(flavor)) {
        builder.append("-$flavor");
      }
      if (isDebug) {
        builder.append("(debug)");
      }
    });

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
///
/// # 2025-1-17
///
/// ## AndroidDeviceInfo
///
/// ```
/// {product: oriole, supportedAbis: [arm64-v8a, armeabi-v7a, armeabi], serialNumber: unknown,
/// supported32BitAbis: [armeabi-v7a, armeabi], display: AP4A.241205.013, type: user, isPhysicalDevice: true,
/// version: {baseOS: , securityPatch: 2024-12-05, sdkInt: 35, release: 15, codename: REL,
/// previewSdkInt: 0, incremental: 12621605}, manufacturer: Google, tags: release-keys,
/// supported64BitAbis: [arm64-v8a], bootloader: slider-15.1-12292109, fingerprint: google/oriole/oriole:15/AP4A.241205.013/12621605:user/release-keys,
/// host: r-456ae1c9fa6a8c5c-k9hc, isLowRamDevice: false, model: Pixel 6, id: AP4A.241205.013,
/// brand: google, device: oriole, board: oriole, hardware: oriole}
/// ```
///
/// ## IosDeviceInfo
///
/// ```
/// {systemName: iOS, isPhysicalDevice: true, utsname: {release: 24.2.0, sysname: Darwin, nodename: localhost,
/// machine: iPhone14,3, version: Darwin Kernel Version 24.2.0: Thu Nov 14 22:54:45 PST 2024; root:xnu-11215.62.3~1/RELEASE_ARM64_T8110},
/// model: iPhone, localizedModel: iPhone, isiOSAppOnMac: false, systemVersion: 18.2.1, modelName: iPhone 13 Pro Max,
/// name: iPhone, identifierForVendor: 411A82C6-6333-4D3A-A58F-493B83EA380E}
/// ```
///
/// ## WindowsDeviceInfo
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
/// ## MacOsDeviceInfo
///
/// ```
/// {minorVersion: 2, cpuFrequency: 0, computerName: RSen的MacBook Pro,
/// kernelVersion: Darwin Kernel Version 24.2.0: Fri Dec  6 19:02:12 PST 2024;
/// root:xnu-11215.61.5~2/RELEASE_ARM64_T6031, systemGUID: D40584C1-01BC-53A4-86F9-98B1E840D63A,
/// majorVersion: 15, arch: arm64, patchVersion: 0, memorySize: 51539607552, hostName: Darwin,
/// activeCPUs: 16, osRelease: Version 15.2 (Build 24C101), model: Mac15,9,
/// modelName: MacBook Pro (16-inch, 2023)}
/// ```
///
BaseDeviceInfo? get $platformDeviceInfoCache {
  $platformDeviceInfo.ignore();
  /*assert(() {
    l.d(_platformDeviceInfoCache?.runtimeType);
    l.d(_platformDeviceInfoCache?.data);
    return true;
  }());*/
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

/// [BaseDeviceInfo]
extension PlatformDeviceInfoEx on BaseDeviceInfo {
  /// 平台设备的名称
  /// [Platform.operatingSystem]
  String? get platformDeviceName => switch (this) {
        AndroidDeviceInfo info => info.model,
        WindowsDeviceInfo info => info.productName,
        IosDeviceInfo info => info.modelName,
        MacOsDeviceInfo info => info.modelName /*MacBook Pro (14-inch, 2023)*/,
        LinuxDeviceInfo info => info.prettyName,
        _ => null,
      };
}

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
