part of '../flutter3_onnx.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/14
///
/// 在主[Isolate]中执行
class BirefnetManager {
  /// 在这里初始化 ONNX Runtime
  @tempFlag
  OrtSession? _session;

  /// 使用模型, 移除图片背景
  /// - [modelPath] 模型所在的路径
  /// - [TransferableTypedData]
  ///
  /// # Windows
  /// ```
  /// 耗时->14s501ms
  /// 耗时->13s221ms
  /// 耗时->10s933ms
  /// 耗时->11s52ms
  /// ```
  @api
  Future<UiImage?> removeBackground(
    String? modelPath,
    UiImage? image,
    bool binary,
  ) async {
    if (modelPath == null || modelPath.isFileExistsSync() != true) {
      return image;
    }
    if (image == null) {
      return null;
    }
    final bytes = await image.toBytes();
    //执行算法
    final ort = _session ??= await OnnxRuntime().createSession(modelPath);
    final pngBytes = await BiRefNetHelper.runAsync(
      session: ort,
      binary: binary,
      inputImageBytes: bytes!,
    );
    return pngBytes.toImage();
  }

  /// 释放
  @api
  void dispose() {
    _session?.close();
    _session = null;
  }
}

/// [BirefnetManager]的实例
@globalInstance
final $birefnetManager = BirefnetManager();
