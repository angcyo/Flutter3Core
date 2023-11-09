part of flutter3_pub;

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
