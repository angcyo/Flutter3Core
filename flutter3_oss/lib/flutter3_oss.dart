library flutter3_oss;

import 'dart:async';
import 'dart:developer';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

export 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

part 'src/oss_object.dart';
part 'src/oss_upload.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024-12-6
///
/// oss sts document: https://help.aliyun.com/document_detail/100624.html
///
/// # 初始化oss
///
/// - [initAliyunOssSts]
///
/// 可能还需要在[$buildConfig]中配置
/// - ossEndpoint
/// - ossBucket
/// - ossBaseUrl `可选`
///
/// ```script_build_config.json
/// {
///   ...
///   "json": {
///      ...
///     "ossEndpoint": "https://oss-cn-hongkong.aliyuncs.com",
///     "ossBucket": "xxx-prod",
///     "ossBaseUrl": "https://xxx-prod.oss-cn-hongkong.aliyuncs.com/",
///     ...
///   },
///   ...
/// }
/// ```
///
/// ## 查看阿里云OSS的Endpoint
///
/// `登录控制台`->`对象存储 OSS`->`Bucket 列表`->`Bucket 名称`->`概览`->`访问端口`.
///
/// `Bucket 域名` = `Bucket 名称`.`Endpoint`
///
/// # 上传单文件
///
/// - [uploadAliyunOssFile]
///
/// # 上传多文件
///
/// -[uploadAliyunOssFileList]
///
class OssClient {
  OssClient._();

  static Client? aliyunOssClient;

  //--

  /// 阿里云OSS的STS临时访问凭证地址
  @tempFlag
  static String? _stsUrl;

  /// 阿里云OSS的Endpoint
  @tempFlag
  static String? _ossEndpoint;

  /// 阿里云OSS的Bucket 名称
  @tempFlag
  static String? _ossBucket;

  //--

  /// 阿里云OSS的Bucket 域名
  static String? get ossBaseUrl {
    final String? url = $bc?["ossBaseUrl"];
    if (url != null) {
      return url;
    }
    String? ossBucket = $bc?["ossBucket"];
    String? ossEndpoint = $bc?["ossEndpoint"];
    if (ossBucket != null && ossEndpoint != null) {
      if (ossEndpoint.startsWith("^https?://")) {
        return "$ossBucket.$ossEndpoint";
      }
      return "https://$ossBucket.$ossEndpoint";
    }
    return null;
  }
}

/// 使用sts授权的方式, 初始化阿里云oss
///
/// sts默认应该返回以下结构: [Auth]
/// ```
/// {
///   "AccessKeyId": "xxx",
///   "AccessKeySecret": "xxx",
///   "SecurityToken": "xxx",
///   "Expiration": "xxx",
/// }
/// ```
/// 非以上结构, 都需要自定义解析授权
///
/// - [ossEndpoint] 不需要使用 `https://` 开头
@initialize
void initAliyunOssSts({
  String? stsUrl,
  String? ossEndpoint,
  String? ossBucket,
  //--
  FutureOr<Auth> Function()? authGetter,
  //--
}) {
  ossEndpoint ??= $bc?["ossEndpoint"];
  ossBucket ??= $bc?["ossBucket"];
  if (ossEndpoint != null && ossEndpoint.startsWith("^https?://")) {
    ossEndpoint = ossEndpoint.replaceFirst(RegExp(r"^https?://"), "");
  }
  stsUrl = stsUrl?.transformUrl().toApi();

  if (OssClient._stsUrl == stsUrl &&
      OssClient._ossBucket == ossBucket &&
      OssClient._ossEndpoint == ossEndpoint) {
    assert(() {
      l.w("[initAliyunOssSts]不需要重新初始化.");
      return true;
    }());
    return;
  }

  assert(!isNil(stsUrl) || authGetter != null, "[initAliyunOssSts]初始化参数错误.");
  assert(() {
    if (isNil(ossBucket) || isNil(ossEndpoint)) {
      l.w("[initAliyunOssSts]未指定[ossBucket][ossEndpoint]参数");
    }
    return true;
  }());

  OssClient._stsUrl = stsUrl;
  OssClient._ossBucket = ossBucket;
  OssClient._ossEndpoint = ossEndpoint;

  //init
  OssClient.aliyunOssClient = Client.init(
    stsUrl: stsUrl,
    ossEndpoint: ossEndpoint ?? "",
    bucketName: ossBucket ?? "",
    authGetter: authGetter,
    dio: rDio.dio,
  );
}

/// [PutRequestOption]
PutRequestOption _putRequestOption({
  //--
  String? bucketName,
  bool override = false,
  //--
  ProgressDataAction? onSendAction,
  ProgressDataAction? onReceiveAction,
}) {
  //--
  final startTime = nowTime();
  return PutRequestOption(
    bucketName: bucketName,
    onSendProgress: (count, total) {
      final chunk = DataChunkInfo(
        startTime: startTime,
        count: count,
        total: total,
      );
      assert(() {
        l.d("发送:$chunk");
        return true;
      }());
      onSendAction?.call(chunk);
    },
    onReceiveProgress: (count, total) {
      final chunk = DataChunkInfo(
        startTime: startTime,
        count: count,
        total: total,
      );
      assert(() {
        l.d("接收:$chunk");
        return true;
      }());
      onReceiveAction?.call(chunk);
    },
    override: override,
    aclModel: AclMode.publicRead,
    storageType: StorageType.ia,
    headers: {"cache-control": "no-cache"},
    /*callback: const Callback(
        callbackUrl: "callback url",
        callbackBody:
            "{\"mimeType\":\${mimeType}, \"filepath\":\${object},\"size\":\${size},\"bucket\":\${bucket},\"phone\":\${x:phone}}",
        callbackVar: {"x:phone": "android"},
        calbackBodyType: CalbackBodyType.json,
      ),*/
  );
}

extension OssStringEx on String {
  /// 将当前fileKey转换成可以下载的url链接
  String get ossUrl => OssClient.ossBaseUrl!.connectUrl(this);
}
