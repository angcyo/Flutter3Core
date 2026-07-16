part of '../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/16
///
/// 一些公开的Api
class PubApis {
  PubApis._();

  /// 获取ip对应的信息
  /// ```
  /// {
  ///     "country": "Singapore",
  ///     "organization": "Wap.ac",
  ///     "country_code": "SG",
  ///     "isp": "Wap.ac",
  ///     "asn_organization": "WAP.AC LLC",
  ///     "asn": 401443,
  ///     "offset": 28800,
  ///     "timezone": "Asia/Singapore",
  ///     "latitude": 1.3667,
  ///     "ip": "45.145.154.229",
  ///     "continent_code": "AS",
  ///     "longitude": 103.8
  /// }
  ///
  /// {
  ///   "country" : "China",
  ///   "organization" : "China Telecom",
  ///   "country_code" : "CN",
  ///   "isp" : "China Telecom",
  ///   "region" : "Guangdong",
  ///   "asn_organization" : "Chinanet",
  ///   "region_code" : "GD",
  ///   "asn" : 4134,
  ///   "city" : "Shenzhen",
  ///   "offset" : 28800,
  ///   "timezone" : "Asia/Shanghai",
  ///   "latitude" : 22.5455,
  ///   "ip" : "113.110.215.124",
  ///   "continent_code" : "AS",
  ///   "longitude" : 114.0683
  /// }
  /// ```
  static Future<Map<String, dynamic>?> getGeoIpInfo(
    String? ip, {
    bool? showErrorToast = true,
    bool? throwError = false,
  }) async {
    final url = "https://api.ip.sb/geoip/$ip";
    Map<String, dynamic>? result;
    await url
        .dioGetString(
          headers: {
            // 伪装成标准的 Chrome 浏览器 User-Agent
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/json',
          },
        )
        .http(
          (data, error) {
            if (data is String) {
              result = jsonDecode(data);
            }
          },
          showErrorToast: showErrorToast,
          throwError: throwError,
        );
    return result;
  }
}

extension PubApisStringEx on String {
  /// 极短的代码把任意的 country_code 动态转换为 Emoji 国旗
  String get countryCodeToEmoji {
    final countryCode = this;
    // 转换为大写并确保长度为 2
    final String code = countryCode.toUpperCase();
    if (code.length != 2) return "";

    // 0x1F1E6 - 0x41 = 0x1F1A5
    final int base = 0x1F1A5;

    final int firstChar = code.codeUnitAt(0) + base;
    final int secondChar = code.codeUnitAt(1) + base;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  /// 获取ip对应信息
  Future<Map<String, dynamic>?> get geoIpInfo async =>
      PubApis.getGeoIpInfo(this);
}
