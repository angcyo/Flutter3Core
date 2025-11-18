import 'package:flutter3_app/flutter3_app.dart';
import 'package:flutter3_shelf/flutter3_shelf.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/11/13
///
/// Udp 对应的接口列表
final class UdpApis {
  /// 请求app本地服务地址
  /// - [DebugLogWebSocketServer]
  /// - [$debugLogWebSocketServer]
  @api
  static UdpApiBean requestLocalServer() =>
      UdpApiBean()..method = "requestLocalServer";

  /// 请求app分享日志
  /// - [shareAppLog]
  @api
  static UdpApiBean requestAppShareLog() =>
      UdpApiBean()..method = "requestAppShareLog";

  /// 请求app日志
  /// - [shareAppLog]
  @api
  static UdpApiBean requestAppLog() => UdpApiBean()..method = "requestAppLog";
}

extension UdpApiBeanEx on UdpApiBean {
  /// 响应app日志, 在[headers]的[downloadUrl]中返回一个可以下载的文件链接
  /// [UdpApis.requestAppLog]
  @api
  Future<UdpApiBean> responseAppLog() async {
    final zipPath = await shareAppLog(share: false, clearTempPath: false);
    //data = await zipPath.file().readAsBytes();
    headers = {
      ...?headers,
      "filePath": zipPath,
      "fileName": zipPath.fileName(),
      "downloadUrl": DebugLogWebSocketServer.debugLogServerAddressStream.value
          ?.connect("/files?path=$zipPath"),
    };
    //debugger();
    return this;
  }

  /// 响应app分享日志
  /// [UdpApis.requestAppShareLog]
  @api
  Future<UdpApiBean> responseAppShareLog() async {
    final zipPath = await shareAppLog(share: true, clearTempPath: false);
    data = "分享文件:$zipPath ${zipPath.file().fileSizeSync().toSizeStr()}".bytes;
    return this;
  }

  /// 响应 [UdpApis.requestLocalServer]
  @api
  Future<UdpApiBean> responseLocalServer() async {
    data = DebugLogWebSocketServer.debugLogServerAddressStream.value?.bytes;
    return this;
  }
}
