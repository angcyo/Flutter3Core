import 'dart:math' as math;

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:opencv_dart/opencv.dart' as cv;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/13
///

/// ============================================================
/// 纯 OpenCV 多物体背景分割
///
/// 算法：
///
/// BGR
///  ↓
/// Lab
///  ↓
/// 边缘背景统计
///  ↓
/// FloodFill 背景区域
///  ↓
/// Lab 自适应背景距离
///  ↓
/// 前景候选 Mask
///  ↓
/// Morphology
///  ↓
/// Distance Transform
///  ↓
/// Sure Foreground
///  ↓
/// Connected Components
///  ↓
/// Watershed
///  ↓
/// 多物体 Mask
///
/// 完全不使用：
///
/// ❌ ONNX
/// ❌ DNN
/// ❌ YOLO
/// ❌ GrabCut
/// ❌ AI
/// ============================================================
@implementation
class PureOpenCVSegmenter {
  /// 是否自动缩放
  final int maxProcessSize;

  /// FloodFill 的 Lab 允许变化范围
  ///
  /// 越小：
  ///     背景边界更严格
  ///
  /// 越大：
  ///     更容易吃进渐变背景
  final double floodL;

  final double floodA;
  final double floodB;

  /// Lab 背景距离的基础阈值
  final double baseDistanceThreshold;

  /// 使用背景标准差计算自适应阈值：
  ///
  /// threshold =
  ///     baseDistanceThreshold +
  ///     stdFactor * backgroundStd
  final double stdFactor;

  /// 形态学核
  final int morphologySize;

  /// 前景距离变换阈值比例
  ///
  /// 例如 0.35：
  ///
  /// 距离最大值 35% 以上的区域认为
  /// 是 Sure Foreground
  final double sureForegroundRatio;

  /// 小物体面积比例
  final double minObjectAreaRatio;

  PureOpenCVSegmenter({
    this.maxProcessSize = 1600,
    this.floodL = 10.0,
    this.floodA = 7.0,
    this.floodB = 7.0,
    this.baseDistanceThreshold = 15.0,
    this.stdFactor = 2.0,
    this.morphologySize = 5,
    this.sureForegroundRatio = 0.35,
    this.minObjectAreaRatio = 0.0005,
  });

  /// ==========================================================
  /// 主入口
  /// ==========================================================

  SegmentationResult segment(cv.Mat source) {
    if (source.isEmpty) {
      throw Exception('输入图片为空');
    }

    print('--------------------------------------');
    print('Pure OpenCV Background Segmentation');
    print('--------------------------------------');

    print(
      'source = '
      '${source.cols} x ${source.rows}',
    );

    //
    // ----------------------------------------------------------
    // 1. 缩放
    // ----------------------------------------------------------
    //

    final scale = _calculateScale(source.cols, source.rows, maxProcessSize);

    final image = scale < 1.0
        ? cv.resize(source, (
            (source.cols * scale).round(),
            (source.rows * scale).round(),
          ), interpolation: cv.INTER_AREA)
        : source.clone();

    print(
      'process = '
      '${image.cols} x ${image.rows}',
    );

    //
    // ----------------------------------------------------------
    // 2. BGR -> Lab
    // ----------------------------------------------------------
    //

    final lab = cv.cvtColor(image, cv.COLOR_BGR2Lab);

    //
    // ----------------------------------------------------------
    // 3. 建立背景模型
    // ----------------------------------------------------------
    //

    final backgroundModel = _estimateBackgroundModel(lab);

    print(
      'background mean = '
      '${backgroundModel.meanL.toStringAsFixed(2)}, '
      '${backgroundModel.meanA.toStringAsFixed(2)}, '
      '${backgroundModel.meanB.toStringAsFixed(2)}',
    );

    print(
      'background std = '
      '${backgroundModel.stdL.toStringAsFixed(2)}, '
      '${backgroundModel.stdA.toStringAsFixed(2)}, '
      '${backgroundModel.stdB.toStringAsFixed(2)}',
    );

    //
    // ----------------------------------------------------------
    // 4. FloodFill 从图片四周寻找背景
    // ----------------------------------------------------------
    //

    final floodBackground = _buildFloodFillBackground(lab);

    //
    // ----------------------------------------------------------
    // 5. Lab 背景距离
    // ----------------------------------------------------------
    //

    final candidate = _buildForegroundCandidate(
      lab,
      floodBackground,
      backgroundModel,
    );

    //
    // ----------------------------------------------------------
    // 6. Morphology
    // ----------------------------------------------------------
    //

    final cleaned = _cleanMask(candidate);

    //
    // ----------------------------------------------------------
    // 7. Watershed
    // ----------------------------------------------------------
    //

    final finalMask = _watershedSplit(image, cleaned);

    //
    // ----------------------------------------------------------
    // 8. 删除小物体
    // ----------------------------------------------------------
    //

    final filtered = _removeSmallObjects(finalMask);

    //
    // 9. 如果缩小过，恢复原尺寸
    // ----------------------------------------------------------
    //

    final restoredMask = scale < 1.0
        ? cv.resize(filtered, (
            source.cols,
            source.rows,
          ), interpolation: cv.INTER_NEAREST)
        : filtered.clone();

    //
    // 释放
    //

    backgroundModel.dispose();

    lab.dispose();
    image.dispose();

    floodBackground.dispose();
    candidate.dispose();
    cleaned.dispose();
    finalMask.dispose();
    filtered.dispose();

    return SegmentationResult(mask: restoredMask, scale: scale);
  }

  /// ==========================================================
  /// 计算缩放比例
  /// ==========================================================

  double _calculateScale(int width, int height, int maxSize) {
    final maxDimension = math.max(width, height);

    if (maxDimension <= maxSize) {
      return 1.0;
    }

    return maxSize / maxDimension;
  }

  /// ==========================================================
  /// 背景模型
  ///
  /// 从四周采样。
  ///
  /// 使用 mean + std 建立背景统计模型。
  /// ==========================================================

  _BackgroundModel _estimateBackgroundModel(cv.Mat lab) {
    final lValues = <double>[];

    final aValues = <double>[];

    final bValues = <double>[];

    final border = math.max(
      2,
      math.min(20, math.min(lab.cols, lab.rows) ~/ 20),
    );

    //
    // 上
    //

    _collectBorder(lab, 0, border, lValues, aValues, bValues);

    //
    // 下
    //

    _collectBorder(lab, lab.rows - border, lab.rows, lValues, aValues, bValues);

    //
    // 左
    //

    for (int y = border; y < lab.rows - border; y++) {
      for (int x = 0; x < border; x++) {
        _addPixel(lab, y, x, lValues, aValues, bValues);
      }
    }

    //
    // 右
    //

    for (int y = border; y < lab.rows - border; y++) {
      for (int x = lab.cols - border; x < lab.cols; x++) {
        _addPixel(lab, y, x, lValues, aValues, bValues);
      }
    }

    //
    // 限制采样数量
    //

    if (lValues.length > 30000) {
      final step = lValues.length / 30000.0;

      final newL = <double>[];

      final newA = <double>[];

      final newB = <double>[];

      double index = 0;

      while (index < lValues.length && newL.length < 30000) {
        final i = index.floor();

        newL.add(lValues[i]);

        newA.add(aValues[i]);

        newB.add(bValues[i]);

        index += step;
      }

      lValues
        ..clear()
        ..addAll(newL);

      aValues
        ..clear()
        ..addAll(newA);

      bValues
        ..clear()
        ..addAll(newB);
    }

    return _BackgroundModel(
      meanL: _mean(lValues),
      meanA: _mean(aValues),
      meanB: _mean(bValues),
      stdL: _std(lValues),
      stdA: _std(aValues),
      stdB: _std(bValues),
    );
  }

  void _collectBorder(
    cv.Mat image,
    int yStart,
    int yEnd,
    List<double> l,
    List<double> a,
    List<double> b,
  ) {
    for (int y = yStart; y < yEnd; y++) {
      for (int x = 0; x < image.cols; x++) {
        _addPixel(image, y, x, l, a, b);
      }
    }
  }

  void _addPixel(
    cv.Mat image,
    int y,
    int x,
    List<double> l,
    List<double> a,
    List<double> b,
  ) {
    final p = image.atPixel(y, x);

    l.add(p[0].toDouble());

    a.add(p[1].toDouble());

    b.add(p[2].toDouble());
  }

  double _mean(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }

    var sum = 0.0;

    for (final value in values) {
      sum += value;
    }

    return sum / values.length;
  }

  double _std(List<double> values) {
    if (values.length <= 1) {
      return 0;
    }

    final mean = _mean(values);

    var sum = 0.0;

    for (final value in values) {
      final d = value - mean;

      sum += d * d;
    }

    return math.sqrt(sum / values.length);
  }

  /// ==========================================================
  /// FloodFill
  ///
  /// 从图片四周多个种子点开始。
  ///
  /// 重要：
  ///
  /// 这里使用：
  ///
  /// FLOODFILL_MASK_ONLY
  ///
  /// 所以不会破坏 Lab 图像。
  /// ==========================================================

  cv.Mat _buildFloodFillBackground(cv.Mat lab) {
    //
    // FloodFill mask 必须：
    //
    // rows + 2
    // cols + 2
    //

    final floodMask = cv.Mat.zeros(
      lab.rows + 2,
      lab.cols + 2,
      cv.MatType.CV_8UC1,
    );

    //
    // 必须操作 clone
    //

    final work = lab.clone();

    //
    // 在四周设置多个种子点。
    //
    // 这样比只使用四个角鲁棒。
    //

    final seeds = <cv.Point>[
      cv.Point(0, 0),
      cv.Point(lab.cols ~/ 2, 0),
      cv.Point(lab.cols - 1, 0),

      cv.Point(0, lab.rows ~/ 2),
      cv.Point(lab.cols - 1, lab.rows ~/ 2),

      cv.Point(0, lab.rows - 1),

      cv.Point(lab.cols ~/ 2, lab.rows - 1),

      cv.Point(lab.cols - 1, lab.rows - 1),
    ];

    //
    // floating range：
    //
    // 不设置 FLOODFILL_FIXED_RANGE
    //
    // 这样比较的是邻接像素关系，
    // 对渐变背景比固定范围更友好。
    //

    final flags = 4 | cv.FLOODFILL_MASK_ONLY;

    for (final seed in seeds) {
      cv.floodFill(
        work,
        seed,
        cv.Scalar.all(0),
        mask: floodMask,
        loDiff: cv.Scalar(floodL, floodA, floodB),
        upDiff: cv.Scalar(floodL, floodA, floodB),
        flags: flags,
      );
    }

    //
    // 去掉 floodFill mask 的 1px padding
    //

    final background = cv.Mat.zeros(lab.rows, lab.cols, cv.MatType.CV_8UC1);

    for (int y = 0; y < lab.rows; y++) {
      for (int x = 0; x < lab.cols; x++) {
        final value = floodMask.at<int>(y + 1, x + 1);

        background.set(y, value > 0 ? 255 : 0, x);
      }
    }

    work.dispose();
    floodMask.dispose();

    return background;
  }

  /// ==========================================================
  /// Lab 背景距离
  ///
  /// 并结合 FloodFill：
  ///
  /// backgroundFloodFill = 背景
  ///
  /// 距离远 = 前景
  ///
  /// 最终：
  ///
  /// candidate =
  ///     距离明显不同
  ///     AND
  ///     不是可连通背景
  /// ==========================================================

  cv.Mat _buildForegroundCandidate(
    cv.Mat lab,
    cv.Mat floodBackground,
    _BackgroundModel model,
  ) {
    final result = cv.Mat.zeros(lab.rows, lab.cols, cv.MatType.CV_8UC1);

    //
    // 背景距离阈值
    //

    final adaptiveThreshold = math.max(
      baseDistanceThreshold,

      baseDistanceThreshold +
          stdFactor * (model.stdL + model.stdA + model.stdB) / 3.0,
    );

    print(
      'adaptive Lab threshold = '
      '${adaptiveThreshold.toStringAsFixed(2)}',
    );

    //
    // 权重
    //
    // L 对亮度差异稍微降低权重
    //

    const lWeight = 0.8;
    const aWeight = 1.0;
    const bWeight = 1.0;

    for (int y = 0; y < lab.rows; y++) {
      for (int x = 0; x < lab.cols; x++) {
        final pixel = lab.atPixel(y, x);

        final l = pixel[0].toDouble();

        final a = pixel[1].toDouble();

        final b = pixel[2].toDouble();

        final dl = (l - model.meanL) * lWeight;

        final da = (a - model.meanA) * aWeight;

        final db = (b - model.meanB) * bWeight;

        final distance = math.sqrt(dl * dl + da * da + db * db);

        final isBackgroundConnected = floodBackground.at<int>(y, x) > 0;

        //
        // 两个条件：
        //
        // 1. 与背景颜色明显不同
        // 2. 不是 floodfill 连通背景
        //

        if (distance > adaptiveThreshold && !isBackgroundConnected) {
          result.set(y, 255, x);
        }
      }
    }

    return result;
  }

  /// ==========================================================
  /// 形态学
  /// ==========================================================

  cv.Mat _cleanMask(cv.Mat mask) {
    final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (
      morphologySize,
      morphologySize,
    ));

    //
    // 开
    //

    final opened = cv.morphologyEx(mask, cv.MORPH_OPEN, kernel, iterations: 1);

    //
    // 闭
    //

    final closed = cv.morphologyEx(
      opened,
      cv.MORPH_CLOSE,
      kernel,
      iterations: 2,
    );

    kernel.dispose();
    opened.dispose();

    return closed;
  }

  /// ==========================================================
  /// Watershed
  ///
  /// 这里不是直接对原图盲目 Watershed。
  ///
  /// 先：
  ///
  /// binary mask
  ///      ↓
  /// distance transform
  ///      ↓
  /// sure foreground
  ///
  /// 再：
  ///
  /// connected components
  ///
  /// 最后：
  ///
  /// watershed
  ///
  /// 这样主要解决：
  ///
  /// 两个物体接触/粘连
  /// ==========================================================

  cv.Mat _watershedSplit(cv.Mat image, cv.Mat binary) {
    //
    // ----------------------------------------------------------
    // 1. Distance Transform
    // ----------------------------------------------------------
    //

    final distanceResult = cv.distanceTransform(
      binary,
      cv.DIST_L2,
      5,
      cv.DIST_LABEL_PIXEL,
    );

    final distance = distanceResult.$1;

    final distanceLabels = distanceResult.$2;

    //
    // ----------------------------------------------------------
    // 2. 找最大距离
    // ----------------------------------------------------------
    //

    final minMax = cv.minMaxLoc(distance);

    final maxDistance = minMax.$2;

    print(
      'distance max = '
      '${maxDistance.toStringAsFixed(2)}',
    );

    if (maxDistance <= 0) {
      distance.dispose();
      distanceLabels.dispose();

      return binary.clone();
    }

    //
    // ----------------------------------------------------------
    // 3. Sure Foreground
    // ----------------------------------------------------------
    //

    final sureForeground = cv.Mat.zeros(
      binary.rows,
      binary.cols,
      cv.MatType.CV_8UC1,
    );

    final fgThreshold = maxDistance * sureForegroundRatio;

    for (int y = 0; y < distance.rows; y++) {
      for (int x = 0; x < distance.cols; x++) {
        final d = distance.at<double>(y, x);

        if (d > fgThreshold) {
          sureForeground.set(y, 255, x);
        }
      }
    }

    //
    // ----------------------------------------------------------
    // 4. Connected Components
    // ----------------------------------------------------------
    //

    final markers = cv.Mat.empty();

    final stats = cv.Mat.empty();

    final centroids = cv.Mat.empty();

    final count = cv.connectedComponentsWithStats(
      sureForeground,
      markers,
      stats,
      centroids,
      8,
      cv.MatType.CV_32S,
      cv.CCL_DEFAULT,
    );

    print(
      'sure foreground objects = '
      '${count - 1}',
    );

    //
    // Connected Components：
    //
    // 0 = 背景
    // 1...N = object
    //
    // Watershed 要求：
    //
    // 背景 > 0
    // 前景 > 0
    // 未知区域 = 0
    //

    //
    // ----------------------------------------------------------
    // 5. 标记背景
    // ----------------------------------------------------------
    //

    for (int y = 0; y < markers.rows; y++) {
      for (int x = 0; x < markers.cols; x++) {
        final value = markers.at<int>(y, x);

        //
        // 原来 connected component：
        //
        // 0 = background
        //
        // 改成 1
        //

        if (value == 0) {
          //
          // 只有 binary 前景外才设置背景
          //

          if (binary.at<int>(y, x) == 0) {
            markers.set<int>(y, x, 1);
          } else {
            //
            // binary 前景但不属于 sure foreground
            //
            // 保持 0 = unknown
            //

            markers.set<int>(y, x, 0);
          }
        } else {
          //
          // 前景 label 全部 +1
          //

          markers.set<int>(y, x, value + 1);
        }
      }
    }

    //
    // ----------------------------------------------------------
    // 6. Watershed
    // ----------------------------------------------------------
    //

    cv.watershed(image, markers);

    //
    // Watershed：
    //
    // -1 = boundary
    // >=2 = object
    //
    // 构建最终 Mask
    //

    final result = cv.Mat.zeros(binary.rows, binary.cols, cv.MatType.CV_8UC1);

    for (int y = 0; y < markers.rows; y++) {
      for (int x = 0; x < markers.cols; x++) {
        final label = markers.at<int>(y, x);

        //
        // label >= 2
        //
        // 表示物体
        //

        if (label >= 2) {
          result.set(y, 255, x);
        }
      }
    }

    //
    // 最终再轻微闭运算
    //

    final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));

    final finalResult = cv.morphologyEx(
      result,
      cv.MORPH_CLOSE,
      kernel,
      iterations: 1,
    );

    //
    // dispose
    //

    kernel.dispose();

    distance.dispose();
    distanceLabels.dispose();
    sureForeground.dispose();

    markers.dispose();
    stats.dispose();
    centroids.dispose();

    result.dispose();

    return finalResult;
  }

  /// ==========================================================
  /// 删除小物体
  /// ==========================================================

  cv.Mat _removeSmallObjects(cv.Mat mask) {
    final labels = cv.Mat.empty();

    final stats = cv.Mat.empty();

    final centroids = cv.Mat.empty();

    final count = cv.connectedComponentsWithStats(
      mask,
      labels,
      stats,
      centroids,
      8,
      cv.MatType.CV_32S,
      cv.CCL_DEFAULT,
    );

    final output = cv.Mat.zeros(mask.rows, mask.cols, cv.MatType.CV_8UC1);

    final minArea = mask.rows * mask.cols * minObjectAreaRatio;

    print(
      'minimum object area = '
      '${minArea.toStringAsFixed(0)}',
    );

    var kept = 0;

    for (int label = 1; label < count; label++) {
      final area = stats.at<int>(label, cv.CC_STAT_AREA);

      if (area < minArea) {
        continue;
      }

      kept++;

      for (int y = 0; y < labels.rows; y++) {
        for (int x = 0; x < labels.cols; x++) {
          final current = labels.at<int>(y, x);

          if (current == label) {
            output.set(y, 255, x);
          }
        }
      }
    }

    print('kept objects = $kept');

    labels.dispose();
    stats.dispose();
    centroids.dispose();

    return output;
  }
}

/// ============================================================
/// 背景模型
/// ============================================================

class _BackgroundModel {
  final double meanL;
  final double meanA;
  final double meanB;

  final double stdL;
  final double stdA;
  final double stdB;

  _BackgroundModel({
    required this.meanL,
    required this.meanA,
    required this.meanB,
    required this.stdL,
    required this.stdA,
    required this.stdB,
  });

  void dispose() {}
}

/// ============================================================
/// 分割结果
/// ============================================================

class SegmentationResult {
  final cv.Mat mask;
  final double scale;

  SegmentationResult({required this.mask, required this.scale});
}

/// ============================================================
/// 根据 Mask 生成透明 PNG
///
/// BGR
/// ↓
/// BGRA
///
/// alpha = mask
/// ============================================================

cv.Mat createTransparentForeground(cv.Mat image, cv.Mat mask) {
  final foreground = cv.Mat.zeros(image.rows, image.cols, image.type);

  //
  // 保留前景
  //

  image.copyTo(foreground, mask: mask);

  //
  // BGR
  //

  final channels = cv.split(foreground);

  //
  // Alpha
  //

  channels.add(mask.clone());

  //
  // BGR -> BGRA
  //

  final result = cv.merge(channels);

  channels.dispose();
  foreground.dispose();

  return result;
}

/// ============================================================
/// 主程序
/// ============================================================

void _main() {
  const inputPath = 'input.jpg';

  const maskPath = 'output_mask.png';

  const foregroundPath = 'output_foreground.png';

  //
  // ----------------------------------------------------------
  // 读取
  // ----------------------------------------------------------
  //

  final image = cv.imread(inputPath, flags: cv.IMREAD_COLOR);

  if (image.isEmpty) {
    throw Exception('无法读取图片：$inputPath');
  }

  print(
    'input = '
    '${image.cols} x ${image.rows}',
  );

  //
  // ----------------------------------------------------------
  // 创建分割器
  // ----------------------------------------------------------
  //

  final segmenter = PureOpenCVSegmenter(
    //
    // 大图先缩放
    //
    maxProcessSize: 1600,

    //
    // FloodFill Lab 容差
    //
    floodL: 10,
    floodA: 7,
    floodB: 7,

    //
    // Lab 背景距离基础阈值
    //
    baseDistanceThreshold: 15,

    //
    // 背景统计标准差权重
    //
    stdFactor: 2.0,

    //
    // 形态学
    //
    morphologySize: 5,

    //
    // 物体中心区域
    //
    sureForegroundRatio: 0.35,

    //
    // 最小物体
    //
    minObjectAreaRatio: 0.0005,
  );

  //
  // ----------------------------------------------------------
  // 分割
  // ----------------------------------------------------------
  //

  final segmentation = segmenter.segment(image);

  final mask = segmentation.mask;

  //
  // ----------------------------------------------------------
  // 保存 Mask
  // ----------------------------------------------------------
  //

  cv.imwrite(maskPath, mask);

  //
  // ----------------------------------------------------------
  // 透明前景
  // ----------------------------------------------------------
  //

  final foreground = createTransparentForeground(image, mask);

  cv.imwrite(foregroundPath, foreground);

  print('');
  print('======================================');
  print('完成');
  print('======================================');

  print('Mask       : $maskPath');

  print('Foreground : $foregroundPath');

  //
  // ----------------------------------------------------------
  // 释放
  // ----------------------------------------------------------
  //

  foreground.dispose();
  mask.dispose();
  image.dispose();
}
