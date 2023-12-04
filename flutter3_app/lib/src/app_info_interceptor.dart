part of flutter3_app;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/04
///

/// 公共的请求头
const kAppInfoHeader = <String, dynamic>{};

class AppInfoInterceptor extends Interceptor {
  PackageInfo? _packageInfo;

  AppInfoInterceptor() {
    packageInfo.get((info, error) {
      _packageInfo = info;
    });
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_packageInfo != null) {
      options.headers["appVersionName"] = _packageInfo!.version;
      options.headers["appVersionCode"] = _packageInfo!.buildNumber;
      options.headers["appPackageName"] = _packageInfo!.packageName;
      options.headers["appSignature"] = _packageInfo!.buildSignature;
      options.headers.addAll(kAppInfoHeader);
    }
    super.onRequest(options, handler);
  }
}
