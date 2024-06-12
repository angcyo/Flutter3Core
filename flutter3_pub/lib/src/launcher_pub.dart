part of '../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

extension LauncherUriEx on Uri {
  /// 检查设备上安装的某个应用是否可以处理指定的 URL。
  Future<bool> canLaunch() async {
    return canLaunchUrl(this);
  }

  ///打开一个Url
  ///支持的Scheme
  ///```
  ///https://flutter.dev
  ///mailto:smith@example.org?subject=News&body=New%20plugin
  ///tel:+1-555-010-999
  ///sms:5550101234
  ///file:/home
  ///```
  ///https://pub.dev/packages/url_launcher#supported-url-schemes
  ///https://pub.dev/packages/url_launcher
  ///[mode] 启动模式
  ///[LaunchMode.platformDefault] 使用平台浏览器打开url,打开网页, 在高版本Edge浏览器中也会在App内打开网页, 但是不用手动控制导航栏.
  ///[LaunchMode.inAppWebView] 在app内打开, 需要手动控制导航栏, scheme拦截.
  ///[LaunchMode.inAppBrowserView]与[LaunchMode.platformDefault]一样
  ///[LaunchMode.externalApplication].[LaunchMode.externalNonBrowserApplication]与[LaunchMode.platformDefault]一样, 但是一定会启动外部应用.
  Future<bool> launch({
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
  }) async {
    return launchUrl(
      this,
      mode: mode,
      webViewConfiguration: webViewConfiguration,
      webOnlyWindowName: webOnlyWindowName,
    );
  }
}

extension LauncherStringEx on String {
  /// [LauncherUriEx.launch]
  Future<bool> launch({
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    String? webOnlyWindowName,
  }) async {
    return Uri.parse(this).launch(
      mode: mode,
      webViewConfiguration: webViewConfiguration,
      webOnlyWindowName: webOnlyWindowName,
    );
  }

  /// [LauncherUriEx.canLaunch]
  Future<bool> canLaunch() async {
    return Uri.parse(this).canLaunch();
  }
}
