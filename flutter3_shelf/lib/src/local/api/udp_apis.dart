import 'package:flutter3_app/flutter3_app.dart';
import 'package:flutter3_shelf/src/local/api/udp_api_bean.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/11/13
///
/// Udp 对应的接口列表
final class UdpApis {
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
  /// 响应app日志
  /// [UdpApis.requestAppLog]
  @api
  Future<UdpApiBean> responseAppLog() async {
    final zipPath = await shareAppLog(share: false, clearTempPath: false);
    data = await zipPath.file().readAsBytes();
    headers = {
      ...?headers,
      "filePath": zipPath,
      "fileName": zipPath.fileName(),
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
}
