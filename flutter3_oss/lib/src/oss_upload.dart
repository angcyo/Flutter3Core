part of '../flutter3_oss.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/15
///
/// OSS 文件上传
///
/// https://pub.dev/packages/flutter_oss_aliyun
///
/// https://help.aliyun.com/zh/oss/developer-reference/object-operations
///
/// 需要先初始化授权[initAliyunOssSts]

//region file

/// 上传文件
/// - [bucketName] 不指定则使用默认的
/// - [prefixKey] 前缀, 会拼上文件名然后当做[key]
/// - [key] 上传文件的key, 不指定就是文件名
/// - [baseUrl] 下载拼接使用的地址
///
/// ```
/// DioException [connection error]: The connection errored: Failed host lookup: 'laserpecker-prod.https' This indicates an error which most likely cannot be solved by the library.
///
/// https://laserpecker-prod.oss-cn-hongkong.aliyuncs.com/6e44b305d1c94182a83fbf0846348fcd.lp2
/// ```
///
/// - @return 返回文件可以下载的url地址
///
/// - [uploadAliyunOssBytes]
/// - [uploadAliyunOssFile]
Future<String?> uploadAliyunOssFile(
  String filepath, {
  String? prefixKey,
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
  key ??= prefixKey == null
      ? filepath.fileName()
      : "$prefixKey/${filepath.fileName()}";
  baseUrl ??= OssClient.ossBaseUrl;
  await OssClient.aliyunOssClient!.putObjectFile(
    filepath,
    fileKey: key,
    cancelToken: cancelToken,
    option:
        option ??
        _putRequestOption(
          bucketName: bucketName,
          override: override,
          onSendAction: onSendAction,
          onReceiveAction: onReceiveAction,
        ),
  );
  return baseUrl?.connectUrl(key);
}

/// 上传一个文件列表
/// [uploadAliyunOssFile]
Future<List<String>> uploadAliyunOssFileList(
  List<String> pathList, {
  String? prefixKey,
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
  baseUrl ??= OssClient.ossBaseUrl;

  final List<AssetFileEntity> assetEntities = [];
  final List<String> result = [];

  final startTime = nowTime();

  int allSendTotal = 0;
  int allSendCount = 0;

  int allReceiveTotal = 0;
  int allReceiveCount = 0;

  pathList.forEachIndexed((index, filepath) {
    final key =
        keyList?[index] ??
        (prefixKey == null
            ? filepath.fileName()
            : "$prefixKey/${filepath.fileName()}");
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
            onSendAction?.call(
              DataChunkInfo(
                startTime: startTime,
                count: allSendCount,
                total: allSendTotal,
              ),
            );
          },
          onReceiveAction: (chunk) {
            allReceiveCount += chunk.count;
            allReceiveTotal += chunk.total;
            onReceiveAction?.call(
              DataChunkInfo(
                startTime: startTime,
                count: allReceiveCount,
                total: allReceiveTotal,
              ),
            );
          },
        ),
      ),
    );
  });

  await OssClient.aliyunOssClient?.putObjectFiles(
    assetEntities,
    cancelToken: cancelToken,
  );
  return result;
}

//endregion file

//region bytes

/// 直接上传字节数据
/// - [uploadAliyunOssFile]
/// - [uploadAliyunOssBytes]
Future<String?> uploadAliyunOssBytes(
  String key,
  List<int> bytes, {
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
  baseUrl ??= OssClient.ossBaseUrl;
  await OssClient.aliyunOssClient?.putObject(
    bytes,
    key,
    cancelToken: cancelToken,
    option:
        option ??
        _putRequestOption(
          bucketName: bucketName,
          override: override,
          onSendAction: onSendAction,
          onReceiveAction: onReceiveAction,
        ),
  );
  debugger();
  return baseUrl?.connectUrl(key);
}

//endregion bytes
