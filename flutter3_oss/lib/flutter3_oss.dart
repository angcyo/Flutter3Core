library flutter3_oss;

import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

export 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024-12-6
///
/// oss sts document: https://help.aliyun.com/document_detail/100624.html
class OssClient {
  OssClient._();

  static Client? aliyunOssClient;
}

/// 使用sts授权的方式, 初始化阿里云oss
/// [ossEndpoint] 不需要使用 `https://` 开头
@initialize
void initAliyunOssSts(
  String stsUrl, {
  String? ossEndpoint,
  String? ossBucket,
}) {
  ossEndpoint ??= $buildConfig?["ossEndpoint"];
  ossBucket ??= $buildConfig?["ossBucket"];
  if (ossEndpoint != null) {
    ossEndpoint = ossEndpoint.replaceFirst(RegExp(r"^https?://"), "");
  }
  OssClient.aliyunOssClient = Client.init(
    stsUrl: stsUrl.transformUrl().toApi(),
    ossEndpoint: ossEndpoint ?? "",
    bucketName: ossBucket ?? "",
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

/// 上传文件
/// [bucketName] 不指定则使用默认的
/// [key]
/// [baseUrl] 下载拼接使用的地址
///
/// ```
/// DioException [connection error]: The connection errored: Failed host lookup: 'laserpecker-prod.https' This indicates an error which most likely cannot be solved by the library.
///
/// https://laserpecker-prod.oss-cn-hongkong.aliyuncs.com/6e44b305d1c94182a83fbf0846348fcd.lp2
/// ```
///
/// @return 返回文件可以下载的url地址
Future<String> uploadAliyunOssFile(
  String filepath, {
  String? key,
  CancelToken? cancelToken,
  //--
  String? baseUrl,
  //--
  String? bucketName,
  bool override = false,
  PutRequestOption? option,
  //--
  ProgressDataAction? onSendAction,
  ProgressDataAction? onReceiveAction,
}) async {
  //--
  key ??= filepath.fileName();
  baseUrl ??= $buildConfig?["ossBaseUrl"];
  await OssClient.aliyunOssClient!.putObjectFile(
    filepath,
    fileKey: key,
    cancelToken: cancelToken,
    option: option ??
        _putRequestOption(
          bucketName: bucketName,
          override: override,
          onSendAction: onSendAction,
          onReceiveAction: onReceiveAction,
        ),
  );
  return (baseUrl ?? "").connectUrl(key);
}

/// [uploadAliyunOssFile]
Future<List<String>> uploadAliyunOssFileList(
  List<String> pathList, {
  List<String>? keyList,
  CancelToken? cancelToken,
  //--
  String? baseUrl,
  //--
  String? bucketName,
  bool override = false,
  //--
  ProgressDataAction? onSendAction,
  ProgressDataAction? onReceiveAction,
}) async {
  baseUrl ??= $buildConfig?["ossBaseUrl"];

  final List<AssetFileEntity> assetEntities = [];
  final List<String> result = [];

  final startTime = nowTime();

  int allSendTotal = 0;
  int allSendCount = 0;

  int allReceiveTotal = 0;
  int allReceiveCount = 0;

  pathList.forEachIndexed((index, filepath) {
    final key = keyList?[index] ?? filepath.fileName();
    result.add((baseUrl ?? "").connectUrl(key));
    assetEntities.add(
      AssetFileEntity(
        filepath: filepath,
        filename: key,
        option: _putRequestOption(
          bucketName: bucketName,
          override: override,
          onSendAction: (chunk) {
            allSendCount += chunk.count;
            allSendTotal += chunk.total;
            onSendAction?.call(DataChunkInfo(
              startTime: startTime,
              count: allSendCount,
              total: allSendTotal,
            ));
          },
          onReceiveAction: (chunk) {
            allReceiveCount += chunk.count;
            allReceiveTotal += chunk.total;
            onReceiveAction?.call(DataChunkInfo(
              startTime: startTime,
              count: allReceiveCount,
              total: allReceiveTotal,
            ));
          },
        ),
      ),
    );
  });

  await OssClient.aliyunOssClient!.putObjectFiles(
    assetEntities,
    cancelToken: cancelToken,
  );
  return result;
}
