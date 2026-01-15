part of '../flutter3_oss.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/15
///
///
/// OSS 对象信息

//MARK: - meta

/// 获取文件元信息
@api
@implementation
Future getOssObjectMeta(
  String fileKey, {
  CancelToken? cancelToken,
  String? bucketName,
}) async {
  final response = await OssClient.aliyunOssClient?.getObjectMeta(
    fileKey,
    cancelToken: cancelToken,
    bucketName: bucketName,
  );
  debugger();
}
