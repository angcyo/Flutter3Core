part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/04
///

/// 公共的请求头
const kAppInfoHeader = <String, dynamic>{};

/// App的一些信息拦截器
class AppInfoInterceptor extends Interceptor {
  PackageInfo? _packageInfo;

  AppInfoInterceptor() {
    $platformPackageInfo.get((info, error) {
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
    //一些运行的环境信息
    /*GlobalConfig.def.globalContext?.let((it) {
      options.headers["appDeviceId"] = ;
    });*/
    platformLocale.let<Locale>((it) {
      //platformLocale:zh_Hans_CN
      options.headers["platformLocale"] = it.toString();
      //zh
      options.headers["platformLanguageCode"] = it.languageCode;
      //CN
      options.headers["platformCountryCode"] = it.countryCode;
      //Hans
      options.headers["platformScriptCode"] = it.scriptCode;
      //zh_CN
      options.headers["language"] = "${it.languageCode}_${it.countryCode}";
      return it;
    });
    super.onRequest(options, handler);
  }
}
