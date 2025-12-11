part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// 网络诊断模型, 需要诊断的信息
/// - 诊断的信息
/// - 诊断的结果
class NetworkDiagnosisModel {
  /// 诊断的动作列表
  final List<NetworkDiagnosisAction> actions;

  NetworkDiagnosisModel({required this.actions});
}

/// 诊断的动作
///
/// # 域名解析
/// ```
/// import 'dart:io';
///
/// Future<String> checkLocalDns(String host) async {
///   try {
///     // 默认使用本地/系统 DNS 解析
///     final result = await InternetAddress.lookup(host)
///         .timeout(Duration(seconds: 5));
///
///     if (result.isNotEmpty) {
///       // 成功解析出 IP 地址
///       return "本地 DNS 解析成功: ${result.first.address}";
///     } else {
///       return "本地 DNS 解析失败：未返回 IP 地址";
///     }
///   } on SocketException catch (e) {
///     return "本地 DNS 解析失败: ${e.message}";
///   } catch (e) {
///     return "DNS 解析错误: $e";
///   }
/// }
/// ```
///
/// # WIFI是否要登录
/// 访问一个不会重定向的网站`example.com`
/// 如果被重定向到一个登录页面（返回状态码可能是 302/307）则说明需要登录
///
/// ```
/// import 'package:http/http.dart' as http;
///
/// // 推荐使用知名的无重定向检测地址
/// const captivePortalUrl = 'http://connectivitycheck.gstatic.com/generate_204';
///
/// Future<String> checkCaptivePortal() async {
///   try {
///     final response = await http.get(Uri.parse(captivePortalUrl))
///         .timeout(Duration(seconds: 10));
///
///     // Captive Portal 成功（无登录需求）通常返回 204 No Content
///     if (response.statusCode == 204) {
///       return "Wi-Fi 连接正常，无需登录（无强制门户）";
///     }
///     // Captive Portal 失败（可能需要登录）可能会返回 200 或其他状态码，且内容为 HTML 登录页
///     else if (response.statusCode == 200 && response.body.length > 50) {
///        return "Wi-Fi 可能需要登录（强制门户）";
///     }
///     // 其他情况
///     else {
///       return "Wi-Fi 状态异常 (Status: ${response.statusCode})";
///     }
///   } catch (e) {
///     // 请求失败，可能是网络完全不通，或者连接超时
///     return "强制门户检测失败：网络完全不通或超时";
///   }
/// }
/// ```
class NetworkDiagnosisAction {
  //MARK: - Config

  /// 诊断标签
  @configProperty
  final String label;

  /// 诊断动作回调
  final Future Function(NetworkDiagnosisAction action)? action;

  //MARK: - Result

  /// 诊断开始的时间
  DateTime? startTime;

  /// 诊断耗时
  Duration? duration;

  /// 诊断结果
  Object? result;

  /// 诊断错误
  Object? error;

  //MARK: - Get

  /// 诊断是否开始
  bool get isStarted => startTime != null;

  /// 诊断是否失败了
  bool get isError => error != null;

  /// 诊断是否结束
  bool get isDone => duration != null;

  NetworkDiagnosisAction({required this.label, this.action});

  @api
  void reset() {
    startTime = null;
    duration = null;
    result = null;
    error = null;
  }

  /// 执行诊断动作
  @api
  Future call() async {
    startTime = DateTime.now();
    final stopwatch = Stopwatch()..start();
    try {
      result = await doAction();
    } catch (e) {
      error = e;
    } finally {
      stopwatch.stop();
      duration = stopwatch.elapsed;
    }
  }

  @overridePoint
  Future doAction() async {
    if (action != null) {
      return await action!(this);
    }
  }
}

/// 本地dns解析诊断
class LocalDnsDiagnosisAction extends NetworkDiagnosisAction {
  /// 待解析的域名
  final String host;

  LocalDnsDiagnosisAction({
    super.label = "获取本地 DNS 解析的 IP",
    super.action,
    this.host = "example.com",
  });

  @override
  Future<dynamic> doAction() => InternetAddress.lookup(host);
}

/// 通用dns解析诊断
class UniversalDnsDiagnosisAction extends NetworkDiagnosisAction {
  /// 待解析的域名
  final String host;

  /// DNS查询服务器
  @defInjectMark
  final List<Uri>? providers;

  UniversalDnsDiagnosisAction({
    super.label = "获取通用 DNS 解析的 IP",
    super.action,
    this.host = "example.com",
    this.providers,
  });

  @override
  Future<dynamic> doAction() => DoH(
    providers: List.unmodifiable(
      providers ??
          [/*DoHProvider.google1,*/ DoHProvider.alidns, DoHProvider.alidns2],
    ),
  ).lookup(host, cache: false, DohRequestType.A);
}

/// 检查 Wi-Fi 是否要登录
class WifiLoginDiagnosisAction extends NetworkDiagnosisAction {
  /// 待检查的网页
  final String url;

  WifiLoginDiagnosisAction({
    super.label = "检查 Wi-Fi 是否需要登录",
    super.action,
    this.url = "https://example.com",
  });

  @override
  Future<dynamic> doAction() async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: 10));

      // Captive Portal 成功（无登录需求）通常返回 204 No Content
      if (response.statusCode == 204) {
        return "Wi-Fi 连接正常，无需登录（无强制门户）";
      }
      // Captive Portal 失败（可能需要登录）可能会返回 200 或其他状态码，且内容为 HTML 登录页
      else if (response.statusCode == 200 && response.body.length > 50) {
        return "Wi-Fi 可能需要登录（强制门户）";
      }
      // 其他情况
      else {
        throw "Wi-Fi 状态异常 (Status: ${response.statusCode})";
      }
    } catch (e) {
      // 请求失败，可能是网络完全不通，或者连接超时
      throw "强制门户检测失败：网络完全不通或超时: $e";
    }
  }
}

/// 测试下载速度
class DownloadSpeedTestDiagnosisAction extends NetworkDiagnosisAction {
  DownloadSpeedTestDiagnosisAction({super.label = "测试下载速度", super.action});

  @override
  Future<dynamic> doAction() async {
    try {
      // Create a tester instance
      final tester = SpeedTestDart();

      // And a variable to store the best servers
      List<Server> bestServersList = [];

      // Example function to set the best servers, could be called
      // in an initState()

      final settings = await tester.getSettings();
      final servers = settings.servers;

      bestServersList = await tester.getBestServers(servers: servers);

      //Test download speed in MB/s
      final downloadRate = await tester.testDownloadSpeed(
        servers: bestServersList,
      );

      return "${downloadRate.toStringAsFixed(2)} MB/s";
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
      rethrow;
    }
  }
}

/// 测试上传速度
class UploadSpeedTestDiagnosisAction extends NetworkDiagnosisAction {
  UploadSpeedTestDiagnosisAction({super.label = "测试上传速度", super.action});

  @override
  Future<dynamic> doAction() async {
    try {
      // Create a tester instance
      final tester = SpeedTestDart();

      // And a variable to store the best servers
      List<Server> bestServersList = [];

      // Example function to set the best servers, could be called
      // in an initState()

      final settings = await tester.getSettings();
      final servers = settings.servers;

      bestServersList = await tester.getBestServers(servers: servers);

      //Test upload speed in MB/s
      final uploadRate = await tester.testUploadSpeed(servers: bestServersList);
      return "${uploadRate.toStringAsFixed(2)} MB/s";
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
      rethrow;
    }
  }
}
