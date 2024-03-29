part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///

/// https://pub.dev/packages/package_info_plus
/// ...
/// //Be sure to add this line if `PackageInfo.fromPlatform()` is called before runApp()
/// WidgetsFlutterBinding.ensureInitialized();
/// ...
/// String appName = packageInfo.appName;
/// String packageName = packageInfo.packageName;
/// String version = packageInfo.version;
/// String buildNumber = packageInfo.buildNumber;
Future<PackageInfo> get packageInfo async => await PackageInfo.fromPlatform();

/// https://pub.dev/packages/device_info_plus
/// 获取对应平台的设备信息
Future<BaseDeviceInfo> get deviceInfo async => Platform.isAndroid
    ? await DeviceInfoPlugin().androidInfo
    : Platform.isIOS
        ? await DeviceInfoPlugin().iosInfo
        : Platform.isLinux
            ? await DeviceInfoPlugin().linuxInfo
            : Platform.isMacOS
                ? await DeviceInfoPlugin().macOsInfo
                : Platform.isWindows
                    ? await DeviceInfoPlugin().windowsInfo
                    : await DeviceInfoPlugin().webBrowserInfo;

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

extension ShareStringEx on String {
  /// 分享文本
  Future<void> share({
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

  /// 分享文本
  Future<ShareResult> shareWithResult({
    String? subject,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    return Share.shareWithResult(
      this,
      subject: subject,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
  }

  /// 分享文件
  Future<ShareResult> shareFile({
    List<String>? otherFiles,
    String? subject,
    String? text,
    BuildContext? shareContext,
    Rect? sharePositionOrigin,
  }) async {
    return Share.shareXFiles(
      [XFile(this), ...?otherFiles?.map((e) => XFile(e))],
      subject: subject,
      text: text,
      sharePositionOrigin:
          sharePositionOrigin ?? shareContext?.findRenderObject()?.paintBounds,
    );
  }
}
