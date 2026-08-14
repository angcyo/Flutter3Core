import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/11
///
/// https://huggingface.co/ZhengPeng7/BiRefNet_lite
///
/// https://github.com/ZhengPeng7/BiRefNet/releases/tag/v1
///
/// https://huggingface.co/onnx-community/BiRefNet_lite-ONNX
///
class BiRefNetHelper {
  BiRefNetHelper._();

  //MARK: - input

  /// RGB Image -> Float32 NCHW
  /// ```
  /// //Mean Centering（均值中心化）
  /// final meanR = 0.485;
  /// final meanG = 0.456;
  /// final meanB = 0.406;
  ///
  /// //Standardization（标准化）
  /// final stdR = 0.229;
  /// final stdG = 0.224;
  /// final stdB = 0.225;
  /// ```
  /// 1024*1024*3=3,145,728
  static Float32List imageToFloat32NCHW(
    img.Image image, {
    //Mean Centering（均值中心化）
    double meanR = 0.485,
    double meanG = 0.456,
    double meanB = 0.406,
    //Standardization（标准化）
    double stdR = 0.229,
    double stdG = 0.224,
    double stdB = 0.225,
  }) {
    final width = image.width;
    final height = image.height;

    final planeSize = width * height;

    final result = Float32List(3 * planeSize);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);

        final r = pixel.r.toDouble() / 255.0;
        final g = pixel.g.toDouble() / 255.0;
        final b = pixel.b.toDouble() / 255.0;

        final index = y * width + x;

        // NCHW
        //
        // R channel
        result[index] = (r - meanR) / stdR;

        // G channel
        result[planeSize + index] = (g - meanG) / stdG;

        // B channel
        result[planeSize * 2 + index] = (b - meanB) / stdB;
      }
    }

    return result;
  }

  //MARK: - output

  /// 从 ONNX output 中提取 Float32, 对应 logits 的值
  ///
  /// ```
  /// 输出的是前景/背景的置信度 logits
  ///  logit
  ///   ↓
  ///  sigmoid
  ///   ↓
  ///  0.0 ~ 1.0
  ///   ↓
  ///  ×255
  ///   ↓
  ///  Alpha
  /// ```
  static Float32List extractOutput(dynamic value, int inputSize) {
    /*
     * 不同版本的 onnxruntime Dart binding
     * 对 output.value 的包装方式可能不同。
     *
     * 常见情况：
     *
     * List<List<List<List<double>>>>
     *
     * 或：
     *
     * List<double>
     */

    final result = Float32List(inputSize * inputSize);

    int index = 0;

    void walk(dynamic data) {
      if (data is List) {
        for (final item in data) {
          walk(item);
        }
      } else if (data is num) {
        if (index < result.length) {
          result[index++] = data.toDouble();
        }
      }
    }

    walk(value);

    if (index != result.length) {
      throw Exception(
        'BiRefNet output size error: '
        'expected ${result.length}, got $index',
      );
    }

    return result;
  }

  /// 将 logits 转换成 Sigmoid
  /// logits -> 0~1
  static Float32List sigmoid(Float32List logits, int inputSize) {
    final mask = Float32List(inputSize * inputSize);
    for (int i = 0; i < mask.length; i++) {
      final x = logits[i];

      // sigmoid
      final value = 1.0 / (1.0 + math.exp(-x));

      mask[i] = value;
    }
    return mask;
  }

  /// Mask Float32 -> 灰度图片
  /// ```
  /// final resizedMask = img.copyResize(
  ///   maskImage,
  ///   width: originalWidth,
  ///   height: originalHeight,
  ///   interpolation: img.Interpolation.linear,
  /// );
  /// ```
  static img.Image maskToImage(Float32List mask, int width, int height) {
    final result = img.Image(width: width, height: height, numChannels: 1);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;

        double value = mask[index];

        // 有些 RMBG ONNX 导出版本已经输出 0~1。
        // 如果输出范围明显大于 1，则进行归一化。
        if (value > 1.0) {
          value /= 255.0;
        }
        value = value.clamp(0.0, 1.0);

        final gray = (value * 255.0).round();
        //final gray = value < 0.1 ? 0 : 255;

        result.setPixelRgb(x, y, gray, gray, gray);
      }
    }

    return result;
  }

  /// 将 mask 设置到原始图片 Alpha
  /// - [binary] 是否二值化图片, 只输出黑白颜色
  ///   - [alphaThreshold] 透明阈值
  static img.Image applyMask(
    img.Image original,
    img.Image mask, {
    bool? binary,
    int alphaThreshold = 128,
  }) {
    final result = original.convert(numChannels: 4);

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final maskPixel = mask.getPixel(x, y);

        final alpha = maskPixel.r.toDouble().round().clamp(0, 255);

        final pixel = result.getPixel(x, y);

        if (binary == true) {
          if (alpha <= alphaThreshold) {
            //透明用黑色
            result.setPixelRgba(x, y, 0, 0, 0, 255);
          } else {
            //非透明用白色
            result.setPixelRgba(x, y, 255, 255, 255, 255);
          }
        } else {
          result.setPixelRgba(
            x,
            y,
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            alpha,
          );
        }
      }
    }

    return result;
  }

  //MARK: - api

  /// 调整图片大小
  static img.Image resizeImage(
    img.Image original,
    int width,
    int height, {
    bool? maintainAspect,
    img.Interpolation interpolation = .linear,
  }) {
    return img.copyResize(
      original,
      width: width,
      height: height,
      maintainAspect: maintainAspect,
      interpolation: img.Interpolation.linear,
    );
  }

  //MARK: - run

  /// 执行推理
  /// - [inputImageBytes]输入的图片字节数据
  /// @return 输出图片字节数据
  static Future<Uint8List> runAsync({
    required OrtSession session,
    required bool binary,
    required Uint8List inputImageBytes,
  }) async {
    //MARK: - input
    final inputSize = 1024;
    final shape = [1, 3, inputSize, inputSize];
    final original = img.decodeImage(inputImageBytes)!;
    final rgbImage = original.convert(numChannels: 3);
    final resized = BiRefNetHelper.resizeImage(rgbImage, inputSize, inputSize);
    final inputData = BiRefNetHelper.imageToFloat32NCHW(resized);
    final inputValue = await OrtValue.fromList(inputData, shape);
    final inputs = {session.inputNames.first: inputValue};
    //MARK: - output
    // start the inference
    final outputs = await session.run(inputs);
    final outputValue = await outputs[session.outputNames.first]!.asList();
    final logits = BiRefNetHelper.extractOutput(outputValue, inputSize);
    final mask = BiRefNetHelper.sigmoid(logits, inputSize);
    final maskImage = BiRefNetHelper.maskToImage(mask, inputSize, inputSize);
    final resizedMask = BiRefNetHelper.resizeImage(
      maskImage,
      original.width,
      original.height,
    );
    final result = BiRefNetHelper.applyMask(
      original,
      resizedMask,
      binary: binary,
    );
    //MARK: - dispose
    inputValue.dispose();
    for (final element in outputs.values) {
      //print(element?.asList());
      element.dispose();
    }
    return img.encodePng(result);
  }
}
