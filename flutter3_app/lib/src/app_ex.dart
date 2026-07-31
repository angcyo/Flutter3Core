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
/// - [$platformDeviceInfo] 平台设备信息
/// - [$platformPackageInfo] 平台软件信息
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
///
/// - [$platformDeviceInfoCache]
/// - [$platformPackageInfoCache]
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

//MARK: - BaseDeviceInfo

/// https://pub.dev/packages/device_info_plus
/// 获取对应平台的设备信息
/// - [$platformDeviceInfo] 平台设备信息
/// - [$platformPackageInfo] 平台软件信息
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
/// ```
/// BaseDeviceInfo{data: {physicalRamSize: 7220, type: user, manufacturer: samsung, freeDiskSize: 53382492160, bootloader: S9010ZCSBGZE3, fingerprint: samsung/r0qzcx/r0q:16/BP2A.250605.031.A3/S9010ZCSBGZE3:user/release-keys,
/// host: 21DN4606, isLowRamDevice: false, model: SM-S9010, id: BP2A.250605.031.A3, brand: samsung, hardware: qcom, product: r0qzcx,
/// totalDiskSize: 113986449408, supportedAbis: [arm64-v8a, armeabi-v7a, armeabi],
/// supported32BitAbis: [armeabi-v7a, armeabi], display: BP2A.250605.031.A3.S9010ZCSBGZE3, isPhysicalDevice: true,
/// version: {baseOS: samsung/r0qzcx/r0q:16/BP2A.250605.031.A3/S9010ZCU9GYJ1:user/release-keys, securityPatch: 2026-02-05,
/// sdkInt: 36, release: 16, codename: REL, previewSdkInt: 0, incremental: S9010ZCSBGZE3},
/// systemFeatures: [android.hardware.sensor.proximity, com.samsung.android.sdk.camera.processor, com.samsung.feature.aodservice_v10, com.sec.feature.motionrecognition_service, com.sec.feature.cover.sview, android.hardware.telephony.ims.singlereg, android.hardware.sensor.accelerometer, android.software.controls, android.hardware.faketouch, android.software.telecom, com.samsung.feature.audio_listenback, android.hardware.telephony.subscription, android.hardware.usb.accessory, android.hardware.telephony.data, android.software.backup, android.hardware.touchscreen, android.hardware.touchscreen.multitouch, android.software.erofs, android.software.print, android.software.activities_on_secondary_displays, com.sec.feature.nfc_authentication_cover, android.hardware.wifi.rtt, com.samsung.feature.nowbar, com.google.android.feature.ACCESSIBILITY_PRELOAD, com.sec.feature.nfc_authentication, android.software.voice_recognizers, android.software.picture_in_picture, android.hardware.fingerprint, com.samsung.android.knox.knoxsdk, android.hardware.telephony.satellite, android.hardware.sensor.gyroscope, android.hardware.audio.low_latency, android.software.vulkan.deqp.level, android.software.cant_save_state, android.hardware.security.model.compatible, android.hardware.telephony.messaging, com.samsung.feature.device_category_phone, android.hardware.telephony.calling, android.hardware.opengles.aep, com.sec.feature.sensorhub, android.hardware.bluetooth, com.samsung.feature.audio_fast_listenback, android.software.window_magnification, android.hardware.telephony.radio.access, android.hardware.camera.autofocus, android.hardware.telephony.gsm, android.hardware.telephony.ims, com.sec.feature.cocktailpanel, android.software.incremental_delivery, android.software.sip.voip, android.hardware.se.omapi.ese, android.software.opengles.deqp.level, com.sec.feature.saccessorymanager, com.samsung.feature.samsung_experience_mobile, com.samsung.android.camerasdkservice, com.samsung.android.camera.cameraserviceworker, android.hardware.camera.concurrent, android.hardware.usb.host, android.hardware.audio.output, com.google.android.feature.services_updater, android.software.verified_boot, android.hardware.camera.flash, android.hardware.camera.front, android.hardware.se.omapi.uicc, android.hardware.strongbox_keystore, android.hardware.screen.portrait, android.hardware.nfc, com.nxp.mifare, cn.google.services, android.hardware.sensor.stepdetector, android.software.home_screen, com.sec.feature.cover.ledbackcover, vendor.android.hardware.camera.preview-dis.back, android.hardware.microphone, com.sec.feature.cover.clearcameraviewcover, com.samsung.feature.aremoji.v2, android.software.autofill, com.samsung.android.sdk.camera.processor.effect, android.software.securely_removes_users, android.hardware.bluetooth_le, android.hardware.sensor.compass, android.hardware.touchscreen.multitouch.jazzhand, android.hardware.sensor.barometer, android.software.app_widgets, android.software.input_methods, android.hardware.sensor.light, android.hardware.vulkan.version, android.software.companion_device_setup, com.sec.feature.wirelesscharger_authentication, android.software.device_admin, android.hardware.wifi.passpoint, android.hardware.camera, android.software.credentials, android.hardware.screen.landscape, android.hardware.ram.normal, com.samsung.android.authfw, com.samsung.android.api.version.2402, com.samsung.android.api.version.2403, com.samsung.android.api.version.2501, com.samsung.android.api.version.2502, com.samsung.android.api.version.2601, com.samsung.android.api.version.2701, com.samsung.android.api.version.2801, com.samsung.android.api.version.2802, com.samsung.android.api.version.2803, com.samsung.android.api.version.2901, com.samsung.android.api.version.2902, com.samsung.android.api.version.2903, com.samsung.android.api.version.3001, com.samsung.android.api.version.3002, com.samsung.android.api.version.3101, com.samsung.android.api.version.3201, com.samsung.android.api.version.3301, com.samsung.android.api.version.3302, com.samsung.android.api.version.3401, com.samsung.android.api.version.3402, com.samsung.android.api.version.3501, com.samsung.android.api.version.3601, com.sec.feature.cover, android.software.managed_users, com.sec.feature.nsflp, android.software.webview, android.hardware.sensor.stepcounter, android.hardware.camera.capability.manual_post_processing, android.hardware.camera.any, android.hardware.camera.capability.raw, android.hardware.vulkan.compute, com.samsung.android.oneui.version.10000, com.samsung.android.oneui.version.10100, com.samsung.android.oneui.version.10200, com.samsung.android.oneui.version.10500, com.samsung.android.oneui.version.20000, com.samsung.android.oneui.version.20100, com.samsung.android.oneui.version.20500, com.samsung.android.oneui.version.30000, com.samsung.android.oneui.version.30100, com.samsung.android.oneui.version.30101, com.samsung.android.oneui.version.40000, com.samsung.android.oneui.version.40100, com.samsung.android.oneui.version.40101, com.samsung.android.oneui.version.50000, com.samsung.android.oneui.version.50100, com.samsung.android.oneui.version.50101, com.samsung.android.oneui.version.60000, com.samsung.android.oneui.version.60100, com.samsung.android.oneui.version.60101, com.samsung.android.oneui.version.70000, com.samsung.android.oneui.version.80000, android.software.connectionservice, android.hardware.touchscreen.multitouch.distinct, android.hardware.location.network, com.sec.android.secimaging, android.software.cts, android.software.sip, android.hardware.camera.capability.manual_sensor, android.software.app_enumeration, android.hardware.camera.level.full, com.sec.feature.usb_authentication, android.hardware.wifi.direct, android.software.live_wallpaper, com.sec.feature.pocketmode, android.software.ipsec_tunnels, android.software.freeform_window_management, android.hardware.audio.pro, android.hardware.nfc.hcef, android.hardware.nfc.uicc, com.samsung.feature.support_repair_mode, android.hardware.location.gps, com.samsung.android.camera.deviceinjector, android.software.midi, android.hardware.nfc.any, android.hardware.nfc.ese, android.hardware.nfc.hce, android.hardware.hardware_keystore, android.hardware.wifi, android.hardware.location, com.google.android.mainline.patchlevel.2, android.hardware.vulkan.level, com.sec.feature.cover.flip, com.samsung.android.cameraxservice, com.samsung.android.knox.knoxsdk.api.level.33, com.samsung.android.knox.knoxsdk.api.level.34, com.samsung.android.knox.knoxsdk.api.level.35, com.samsung.android.knox.knoxsdk.api.level.36, com.samsung.android.knox.knoxsdk.api.level.37, com.samsung.android.knox.knoxsdk.api.level.38, com.samsung.android.knox.knoxsdk.api.level.39, android.hardware.wifi.aware, android.software.secure_lock_screen, android.hardware.biometrics.face, com.sec.feature.cover.nfcledcover, android.hardware.telephony, com.sec.android.smartface.smart_stay, android.software.file_based_encryption],
/// tags: release-keys, supported64BitAbis: [arm64-v8a], availableRamSize: 2564, name: Galaxy S22, device: r0q, board: taro}}
/// ```
///
/// ```
/// BaseDeviceInfo{data: {physicalRamSize: 15107, type: user, manufacturer: OnePlus, freeDiskSize: 351883997184, bootloader: unknown, fingerprint: OnePlus/PKX110/OP60F5L1:16/AP3A.240617.008/V.19749a3_aaad6b_a9b132:user/release-keys,
/// host: kvm-slave-build-s-system-11317604, isLowRamDevice: false, model: PKX110, id: AP3A.240617.008, brand: OnePlus, hardware: qcom, product: PKX110,
/// totalDiskSize: 1004035698688, supportedAbis: [arm64-v8a], supported32BitAbis: [], display: PKX110_16.0.8.300(CN01), isPhysicalDevice: true,
/// version: {baseOS: , securityPatch: 2026-06-01, sdkInt: 36, release: 16, codename: REL, previewSdkInt: 0, incremental: V.19749a3_aaad6b_a9b132},
/// systemFeatures: [com.oplus.software.children_space_google_play_exp, android.hardware.sensor.proximity, com.quicinc.voice.assist.asr, oplus.video.hdr10plus_support, android.hardware.sensor.accelerometer, android.software.controls, android.hardware.faketouch, android.software.telecom, android.hardware.telephony.subscription, com.oplus.software.children_space_google_play_gdpr, android.hardware.usb.accessory, oppo.back.touch.fingerprint.sensor, android.hardware.telephony.cdma, android.hardware.telephony.data, android.hardware.telephony.mbms, android.hardware.sensor.dynamic.head_tracker, android.software.backup, android.hardware.touchscreen, android.hardware.touchscreen.multitouch, oppo.common.support.curved.display, android.software.erofs, android.software.print, android.hardware.consumerir, android.software.activities_on_secondary_displays, oplus.software.support_gp.type_phone, android.software.device_lock, oppo.ovs.smartmic.support, android.software.voice_recognizers, android.software.picture_in_picture, android.hardware.fingerprint, android.hardware.sensor.gyroscope, android.hardware.audio.low_latency, android.software.vulkan.deqp.level, android.software.cant_save_state, oplus.hardware.pwd_retrieve_settings, android.hardware.security.model.compatible, android.hardware.telephony.messaging, android.hardware.telephony.calling, oplus.all.client, android.hardware.opengles.aep, oplus.software.support_gp.product_full, android.hardware.bluetooth, android.software.window_magnification, android.hardware.telephony.radio.access, android.hardware.camera.autofocus, android.hardware.telephony.gsm, android.hardware.telephony.ims, android.software.incremental_delivery, android.software.sip.voip, android.hardware.se.omapi.ese, android.software.opengles.deqp.level, oplus.software.view.rgbnormalize, oplus.secrecy.support, oplus.software.gallery.olive, oplus.hardware.weaver_locksettings, android.hardware.camera.concurrent, android.hardware.usb.host, oppo.hardware.fingerprint.optical.support, android.hardware.audio.output, com.google.android.feature.services_updater, android.software.ipsec_tunnel_migration, oplus.obrain.support, android.software.verified_boot, android.hardware.camera.flash, android.hardware.camera.front, android.hardware.se.omapi.uicc, android.hardware.strongbox_keystore, android.hardware.screen.portrait, android.hardware.nfc, oplus.software.display.wcg_2.0_support, com.android.se, com.nxp.mifare, cn.google.services, android.hardware.sensor.stepdetector, android.software.home_screen, oplus.video.hdr10_support, oplus.software.video.roiencode_support, android.hardware.microphone, oplus.software.video.osie_support, com.oneplus.software.oos, android.software.autofill, android.software.securely_removes_users, android.hardware.bluetooth_le, android.hardware.sensor.compass, ro.oplus.security.fido2.ls.supported, android.hardware.touchscreen.multitouch.jazzhand, android.software.app_widgets, android.software.input_methods, oplus.hardware.fingerprint.unlock_without_icon.support, android.hardware.sensor.light, oplus.hardware.pwd_attestation_locksettings, oppo.breeno.three.words.support, android.hardware.vulkan.version, android.software.companion_device_setup, android.software.device_admin, android.hardware.wifi.passpoint, android.hardware.camera, android.software.credentials, android.hardware.screen.landscape, android.software.device_id_attestation, android.hardware.ram.normal, oplus.software.permission.direction_sensor, com.qualcomm.qti.feature.DCF_OFFLOAD, android.software.managed_users, com.oplus.software.overseas.afteroos113, android.software.webview, android.hardware.sensor.stepcounter, android.hardware.camera.capability.manual_post_processing, android.hardware.camera.any, android.hardware.camera.capability.raw, android.hardware.vulkan.compute, android.hardware.touchscreen.multitouch.distinct, android.hardware.location.network, android.software.cts, android.software.sip, android.hardware.camera.capability.manual_sensor, android.software.app_enumeration, android.hardware.camera.level.full, android.hardware.wifi.direct, android.software.live_wallpaper, android.software.ipsec_tunnels, oplus.hardware.resume_on_reboot, android.hardware.audio.pro, com.oneplus.software.oos.n_theme_ready, android.hardware.nfc.hcef, android.hardware.nfc.uicc, android.hardware.location.gps, android.software.midi, android.hardware.nfc.any, android.hardware.nfc.ese, android.hardware.nfc.hce, android.hardware.hardware_keystore, android.hardware.wifi, android.hardware.location, com.google.android.mainline.patchlevel.2, android.hardware.vulkan.level, android.software.virtualization_framework, android.hardware.keystore.app_attest_key, oplus.software.audio.karaoke_v2.support, oplus.software.support_gp.brand_oneplus, oplus.software.support_gp.region_domestic, oplus.software.vibration_alarm_clock, oplus.software.video.sr_support, android.software.secure_lock_screen, android.hardware.biometrics.face, android.hardware.telephony, android.software.file_based_encryption],
/// tags: release-keys, supported64BitAbis: [arm64-v8a], availableRamSize: 3021, name: 一加 13T angcyo, device: OP60F5L1, board: sun}}
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
/// - [$platformDeviceInfoCache]
/// - [$platformDeviceInfoCache]
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

int? get $androidSdkIntCache => isAndroid
    ? (_platformDeviceInfoCache as AndroidDeviceInfo?)?.version.sdkInt
    : null;

/// 手机型号
Future<String?> get $platformDeviceModel async => isAndroid
    //product: T33_7863_U254_V11_FHD_1095_Natv
    //supportedAbis: [arm64-v8a, armeabi-v7a, armeabi]
    //SM-S9010
    ? ((await $platformDeviceInfo) as AndroidDeviceInfo?)?.model
    : isIos
    ? ((await $platformDeviceInfo) as IosDeviceInfo?)?.model
    : isLinux
    ? ((await $platformDeviceInfo) as LinuxDeviceInfo?)?.prettyName
    : isMacOS
    ? ((await $platformDeviceInfo) as MacOsDeviceInfo?)?.model
    : isWindows
    ? ((await $platformDeviceInfo) as WindowsDeviceInfo?)?.productName
    : null;

/// 平台上的设备名称
/// - [$platformDeviceInfoCache]
/// - [$platformPackageInfoCache]
/// - [Platform.version]
String? get $platformDeviceName => $platformDeviceInfoCache?.platformDeviceName;

String? get $platformDeviceFullName =>
    $platformDeviceInfoCache?.platformDeviceFullName;

/// 平台的版本
/// [Platform.version]
String get $platformVersion => Platform.version;

/// [BaseDeviceInfo]
extension PlatformDeviceInfoEx on BaseDeviceInfo {
  /// 平台设备的名称
  /// [Platform.operatingSystem]
  String? get platformDeviceName => switch (this) {
    AndroidDeviceInfo info => info.model /*PKX110*/ /*Pixel 7*/ /*SM-S9010*/,
    WindowsDeviceInfo info => info.productName,
    IosDeviceInfo info => info.modelName,
    MacOsDeviceInfo info => info.modelName /*MacBook Pro (14-inch, 2023)*/,
    LinuxDeviceInfo info => info.prettyName,
    _ => null,
  };

  /// 平台设备的全名称
  /// - [platformDeviceName]
  String? get platformDeviceFullName => switch (this) {
    // Galaxy S22(SM-S9010) 35
    // 一加 13T angcyo(PKX110) 36
    AndroidDeviceInfo info =>
      "${info.name}(${info.model}) ${info.version.sdkInt}",
    WindowsDeviceInfo info => info.productName,
    IosDeviceInfo info => info.modelName,
    MacOsDeviceInfo info => info.modelName /*MacBook Pro (14-inch, 2023)*/,
    LinuxDeviceInfo info => info.prettyName,
    _ => null,
  };
}

/// [PackageInfo]
extension PackageInfoEx on PackageInfo {
  /// 构建版本名和构建版本号
  String get versionText => "$version($buildNumber)";

  /// debug更详细的信息
  String get debugVersionString =>
      versionText.connect($buildFlavor?.wph).connect($buildType?.wph);
}

//MARK: - share

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
        ),
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
  Future<bool> share({
    String? subject,
    String? text,
    String? mimeType,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async => path.shareFile(
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
  Future<bool> share({
    String? subject,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    final result = await Share.share(
      this,
      subject: subject,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
    return result.status == ShareResultStatus.success;
  }

  /// 分享文件
  /// [mimeType] 文件类型
  ///
  /// https://pub.dev/packages/share_plus
  ///
  /// - [PickerFileEx.saveAs]
  ///
  @PlatformFlag("Android iOS MacOS Web Windows")
  Future<bool> shareFile({
    List<String>? otherFiles,
    String? subject,
    String? text,
    String? mimeType,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    final result = await Share.shareXFiles(
      [
        XFile(this, mimeType: mimeType),
        ...?otherFiles?.map((e) => XFile(e, mimeType: mimeType)),
      ],
      subject: subject,
      text: text,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
    return result.status == ShareResultStatus.success;
  }
}

//MARK: - debug

/// App名称, 非包名
String? get $appName => $platformPackageInfoCache?.appName;

/// App的一些基础调试信息
String get $debugAppInfo => stringBuilder((builder) {
  final packageInfo = $platformPackageInfoCache;
  final deviceInfo = $platformDeviceInfoCache;
  final mediaData = platformMediaQueryData;
  final mediaSize = mediaData.size;
  builder
    ..write("${deviceInfo?.platformDeviceName} - $currentPlatformName") //设备名称
    ..writeln(
      " - ${Platform.operatingSystemVersion}/${Platform.numberOfProcessors}",
    ) //平台信息
    ..writeln(
      "${Platform.localHostname}/${Platform.version} - ${Platform.localeName}/$platformLocale",
    ) //平台信息
    ..write(packageInfo?.packageName.connect(" ")) //包名
    ..writeln(packageInfo?.debugVersionString) //版本信息
    ..writeln(
      "${mediaSize.width.toStringAsFixed(1)}x${mediaSize.height.toStringAsFixed(1)}/${mediaData.devicePixelRatio} - ${mediaData.platformBrightness}",
    ) //屏幕信息
    ..writeln($deviceUuid) //设备id
    ;
});
