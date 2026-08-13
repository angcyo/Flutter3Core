part of "../flutter3_opencv.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/13
///
/// ONNX 相关工具函数
class OnnxHelper {
  OnnxHelper._();

  /// OpenCV DNN 加载 ONNX
  /// 从指定数据中加载onnx模型
  static Future<cv.Net> fromOnnx({
    String? filePath,
    String? assetPath,
    Uint8List? bufferModel,
  }) async {
    assert(filePath != null || assetPath != null || bufferModel != null);
    cv.Net net;
    if (filePath != null) {
      net = cv.Net.fromOnnx(filePath);
    } else if (bufferModel != null) {
      net = cv.Net.fromOnnxBytes(bufferModel);
    } else {
      final assetBytes = await loadAssetBytes(assetPath!);
      net = cv.Net.fromOnnxBytes(assetBytes);
    }
    // ----------------------------------------------------------
    // 3. CPU Backend
    // ----------------------------------------------------------
    //net.setPreferableBackend(cv.DNN_BACKEND_OPENCV);
    //net.setPreferableTarget(cv.DNN_TARGET_CPU);
    return net;
  }

  /// 异步运行图片遮罩推理模型
  /// ## BiRefNet
  ///
  /// https://huggingface.co/onnx-community/BiRefNet_lite-ONNX
  /// https://huggingface.co/ZhengPeng7/BiRefNet_lite
  ///
  /// ## RMBG-1.4
  ///
  /// https://huggingface.co/briaai/RMBG-1.4
  /// https://huggingface.co/mujibanget/rmbg-onnx
  ///
  static Future<cv.Mat?> runImageMaskAsync(
    cv.Net? net,
    UiImage? img,
    int inputSize, {
    int ddepth = cv.MatType.CV_32F,
    //Mean Centering（均值中心化）
    double meanR = 0,
    double meanG = 0,
    double meanB = 0,
    //Scale factor（缩放因子）
    double scaleFactor = 1.0 / 255.0,
  }) async {
    if (net == null || img == null) {
      return null;
    }
    final originalWidth = img.width;
    final originalHeight = img.height;
    assert(() {
      l.i('Input image: ${originalWidth}x$originalHeight');
      return true;
    }());
    //MARK: input
    final image = (await img.cvBGRMat);
    final cv.Mat resized;
    if (originalWidth != inputSize || originalHeight != inputSize) {
      resized = image.resize(width: inputSize, height: inputSize);
    } else {
      resized = image;
    }
    // --------------------------------------------------------
    // 1. BGR -> RGB
    // --------------------------------------------------------
    /*final rgb = cv.cvtColor(resized, cv.COLOR_BGR2RGB);*/
    // --------------------------------------------------------
    // 2. Resize 1024x1024
    // --------------------------------------------------------
    /*final resized = cv.resize(rgb, (
      inputSize,
      inputSize,
    ), interpolation: cv.INTER_LINEAR);*/
    // --------------------------------------------------------
    // 3. Float32
    //
    // RMBG:
    //
    // pixel / 255
    //      -
    // 0.5
    //
    // --------------------------------------------------------
    /*final normalized = cv.Mat.empty();
    final normalized = resized.convertTo(cv.MatType.CV_32FC3, alpha: 1.0 / 255.0, beta: -0.5);
    // 上面的写法不同版本 dartcv API 可能返回 dst，
    // 所以这里直接使用 convertTo 返回值更加安全。
    final floatImage = resized.convertTo(
      cv.MatType.CV_32FC3,
      alpha: 1.0 / 255.0,
      beta: -0.5,
    );*/
    // --------------------------------------------------------
    // 4. HWC -> NCHW
    //
    // blobFromImage 会负责：
    //
    // HWC -> NCHW
    //
    // 这里已经是 RGB，所以 swapRB=false
    // --------------------------------------------------------
    final blob = cvBlobFromImage(
      resized,
      size: (inputSize, inputSize),
      scaleFactor: scaleFactor,
      swapRB: true,
      mean: cv.Scalar(meanB, meanG, meanR),
      ddepth: ddepth,
    )!;
    assert(() {
      l.i('Blob shape: ${cv.getBlobSize(blob)}');
      return true;
    }());
    //MARK: output
    // --------------------------------------------------------
    // 5. OpenCV DNN inference
    // --------------------------------------------------------
    net.setInput(blob);
    final output = net.forward();
    // --------------------------------------------------------
    // 6. Output -> Mask
    // --------------------------------------------------------
    final mask = _extractMask(output);
    assert(() {
      l.d('Mask: ${mask.rows}x${mask.cols}');
      return true;
    }());
    // --------------------------------------------------------
    // 7. Normalize mask
    // --------------------------------------------------------
    final normalizedMask = _normalizeMask(mask);
    // --------------------------------------------------------
    // 8. Resize mask to original resized
    // --------------------------------------------------------
    final originalMask = cv.resize(normalizedMask, (
      originalWidth,
      originalHeight,
    ), interpolation: cv.INTER_LINEAR);
    // --------------------------------------------------------
    // 9. BGR + Alpha
    // --------------------------------------------------------
    final result = _mergeAlpha(image, originalMask);
    // --------------------------------------------------------
    // Dispose temporary Mats
    // --------------------------------------------------------
    //rgb.dispose();
    //floatImage.dispose();
    image.dispose();
    resized.dispose();
    blob.dispose();
    output.dispose();
    mask.dispose();
    normalizedMask.dispose();
    originalMask.dispose();
    return result;
  }

  //MARK: - assist

  ///  ==========================================================
  ///  Extract RMBG output
  ///  ==========================================================

  static cv.Mat _extractMask(cv.Mat output) {
    assert(() {
      l.d(
        'Output rows=${output.rows}, '
        'cols=${output.cols}, '
        'dims=${output.dims}',
      );
      return true;
    }());

    /*
     * RMBG-1.4 常见输出：
     *
     * [1, 1, 1024, 1024]
     *
     * dartcv Mat 对 4D Mat 的 rows / cols
     * 不能简单代表全部维度。
     *
     * imagesFromBlob() 可以把 4D blob
     * 转换为 2D Mat。
     */

    final images = cv.imagesFromBlob(output);

    if (images.isEmpty) {
      throw Exception('无法从 model output 提取 mask');
    }

    final mask = images.first;

    assert(() {
      l.d('Extracted mask: ${mask.rows}x${mask.cols}');
      return true;
    }());

    return mask;
  }

  ///  ==========================================================
  ///  Min-Max normalize
  ///  ==========================================================
  static cv.Mat _normalizeMask(cv.Mat mask) {
    final minMax = _minMaxLoc(mask);

    final minValue = minMax.$1;

    final maxValue = minMax.$2;

    assert(() {
      l.d(
        'Mask range: '
        '$minValue ~ $maxValue',
      );
      return true;
    }());

    if ((maxValue - minValue).abs() < 1e-8) {
      return cv.Mat.zeros(mask.rows, mask.cols, cv.MatType.CV_8UC1);
    }
    return mask.convertTo(
      cv.MatType.CV_8UC1,
      alpha: 255.0 / (maxValue - minValue),
      beta: -minValue * 255.0 / (maxValue - minValue),
    );
  }

  ///  ==========================================================
  ///  minMaxLoc
  ///  ==========================================================
  /// | 返回值      | 含义                |
  /// | -------- | ----------------- |
  /// | `minVal` | Mat 中的**最小像素/数值** |
  /// | `maxVal` | Mat 中的**最大像素/数值** |
  /// | `minLoc` | 最小值所在的**坐标**      |
  /// | `maxLoc` | 最大值所在的**坐标**      |
  static (double, double) _minMaxLoc(cv.Mat mat) {
    final (double minVal, double maxVal, cv.Point minLoc, cv.Point maxLoc) = cv
        .minMaxLoc(mat);
    return (minVal, maxVal);
  }

  ///  ==========================================================
  ///  BGR + Alpha -> BGRA
  ///  ==========================================================
  static cv.Mat _mergeAlpha(cv.Mat image, cv.Mat mask) {
    final channels = cv.split(image);
    channels.add(mask);
    final result = cv.merge(channels);
    return result;
  }

  ///  ==========================================================
  ///  Save PNG
  ///  ==========================================================
  static Future<void> savePng(cv.Mat image, String path) async {
    cv.imwrite(path, image);
  }

  /*  static Future<String> removeBackgroundToFile(cv.Mat image) async {
    final result = await removeBackground(image);

    final directory = await getApplicationDocumentsDirectory();

    final outputPath = '${directory.path}/rmbg_result.png';

    await savePng(result, outputPath);

    result.dispose();

    return outputPath;
  }*/
}
