import 'dart:math' as math;

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:opencv_dart/opencv.dart' as cv;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/13
///
@implementation
class OpenCVBackgroundRemover {
  /// 边缘采样宽度
  final int border;

  /// 最小物体面积比例
  final double minAreaRatio;

  /// Lab 距离阈值
  ///
  /// 数值越小：
  ///     越容易识别前景
  ///
  /// 数值越大：
  ///     越严格
  final double threshold;

  final int morphologySize;

  OpenCVBackgroundRemover({
    this.border = 8,
    this.minAreaRatio = 0.001,
    this.threshold = 18.0,
    this.morphologySize = 5,
  });

  cv.Mat removeBackground(cv.Mat image) {
    if (image.isEmpty) {
      throw Exception('输入图片为空');
    }

    print('image = ${image.cols} x ${image.rows}');

    //
    // =========================================================
    // 1. BGR -> Lab
    // =========================================================
    //

    final lab = cv.cvtColor(image, cv.COLOR_BGR2Lab);

    //
    // =========================================================
    // 2. 计算背景颜色
    // =========================================================
    //

    final backgroundColor = _estimateBackgroundColor(lab);

    print(
      'background Lab = '
      '${backgroundColor.l.toStringAsFixed(2)}, '
      '${backgroundColor.a.toStringAsFixed(2)}, '
      '${backgroundColor.b.toStringAsFixed(2)}',
    );

    //
    // =========================================================
    // 3. 计算每个像素与背景的 Lab 距离
    // =========================================================
    //

    final distanceMask = _calculateBackgroundDistance(lab, backgroundColor);

    //
    // =========================================================
    // 4. 自适应阈值
    // =========================================================
    //

    final binary = _threshold(distanceMask);

    //
    // =========================================================
    // 5. 形态学去噪
    // =========================================================
    //

    final cleaned = _morphology(binary);

    //
    // =========================================================
    // 6. 删除非常小的连通区域
    // =========================================================
    //

    final finalMask = _removeSmallComponents(cleaned);

    lab.dispose();
    distanceMask.dispose();
    binary.dispose();
    cleaned.dispose();

    return finalMask;
  }

  /// ============================================================
  /// 估计背景颜色
  ///
  /// 从图片四个边缘采样。
  /// ============================================================
  _LabColor _estimateBackgroundColor(cv.Mat lab) {
    final valuesL = <double>[];
    final valuesA = <double>[];
    final valuesB = <double>[];

    final b = math.min(border, math.min(lab.cols ~/ 4, lab.rows ~/ 4));

    //
    // 上边
    //
    for (int y = 0; y < b; y++) {
      for (int x = 0; x < lab.cols; x++) {
        final p = lab.atVec<cv.Vec3b>(y, x).val;

        valuesL.add(p[0].toDouble());
        valuesA.add(p[1].toDouble());
        valuesB.add(p[2].toDouble());
      }
    }

    //
    // 下边
    //
    for (int y = lab.rows - b; y < lab.rows; y++) {
      for (int x = 0; x < lab.cols; x++) {
        final p = lab.atVec<cv.Vec3b>(y, x).val;

        valuesL.add(p[0].toDouble());
        valuesA.add(p[1].toDouble());
        valuesB.add(p[2].toDouble());
      }
    }

    //
    // 左边
    //
    for (int y = b; y < lab.rows - b; y++) {
      for (int x = 0; x < b; x++) {
        final p = lab.atVec<cv.Vec3b>(y, x).val;

        valuesL.add(p[0].toDouble());
        valuesA.add(p[1].toDouble());
        valuesB.add(p[2].toDouble());
      }
    }

    //
    // 右边
    //
    for (int y = b; y < lab.rows - b; y++) {
      for (int x = lab.cols - b; x < lab.cols; x++) {
        final p = lab.atVec<cv.Vec3b>(y, x).val;

        valuesL.add(p[0].toDouble());
        valuesA.add(p[1].toDouble());
        valuesB.add(p[2].toDouble());
      }
    }

    return _LabColor(_median(valuesL), _median(valuesA), _median(valuesB));
  }

  /// ============================================================
  /// 计算 Lab 欧氏距离
  /// ============================================================
  cv.Mat _calculateBackgroundDistance(cv.Mat lab, _LabColor background) {
    final distance = cv.Mat.zeros(lab.rows, lab.cols, cv.MatType.CV_32FC1);

    for (int y = 0; y < lab.rows; y++) {
      for (int x = 0; x < lab.cols; x++) {
        final p = lab.atVec<cv.Vec3b>(y, x).val;

        final l = p[0].toDouble();
        final a = p[1].toDouble();
        final b = p[2].toDouble();

        final dl = l - background.l;

        final da = a - background.a;

        final db = b - background.b;

        final d = math.sqrt(dl * dl + da * da + db * db);

        distance.setF32(y, d.toDouble(), i1: x);
      }
    }

    return distance;
  }

  /// ============================================================
  /// 阈值
  ///
  /// 距离背景 > threshold
  ///     => 前景
  ///
  /// 距离背景 <= threshold
  ///     => 背景
  /// ============================================================
  cv.Mat _threshold(cv.Mat distance) {
    final result = cv.Mat.zeros(
      distance.rows,
      distance.cols,
      cv.MatType.CV_8UC1,
    );

    for (int y = 0; y < distance.rows; y++) {
      for (int x = 0; x < distance.cols; x++) {
        final value = distance.atF32(y, i1: x);

        result.setU8(y, value > threshold ? 255 : 0, i1: x);
      }
    }

    return result;
  }

  /// ============================================================
  /// 形态学
  /// ============================================================
  cv.Mat _morphology(cv.Mat mask) {
    final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (
      morphologySize,
      morphologySize,
    ));

    //
    // 开运算
    //
    final opened = cv.morphologyEx(mask, cv.MORPH_OPEN, kernel, iterations: 1);

    //
    // 闭运算
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

  /// ============================================================
  /// Connected Components
  ///
  /// 删除面积太小的区域。
  /// ============================================================
  cv.Mat _removeSmallComponents(cv.Mat mask) {
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

    final result = cv.Mat.zeros(mask.rows, mask.cols, cv.MatType.CV_8UC1);

    final imageArea = mask.rows * mask.cols;

    final minArea = imageArea * minAreaRatio;

    print('connected components = $count');

    //
    // label 0 = background
    //
    for (int label = 1; label < count; label++) {
      final area = stats.atI8(label, i1: cv.CC_STAT_AREA);

      if (area >= minArea) {
        for (int y = 0; y < labels.rows; y++) {
          for (int x = 0; x < labels.cols; x++) {
            final value = labels.atI8(y, i1: x);

            if (value == label) {
              result.setU8(y, 255, i1: x);
            }
          }
        }
      }
    }

    labels.dispose();
    stats.dispose();
    centroids.dispose();

    return result;
  }

  double _median(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }

    values.sort();

    final n = values.length;

    if (n.isOdd) {
      return values[n ~/ 2];
    }

    return (values[n ~/ 2 - 1] + values[n ~/ 2]) / 2.0;
  }
}

class _LabColor {
  final double l;
  final double a;
  final double b;

  const _LabColor(this.l, this.a, this.b);
}

/// ============================================================
/// 生成透明前景
/// ============================================================
cv.Mat makeTransparentForeground(cv.Mat image, cv.Mat mask) {
  final foreground = cv.Mat.zeros(image.rows, image.cols, image.type);

  image.copyTo(foreground, mask: mask);

  final channels = cv.split(foreground);

  //
  // Alpha
  //
  channels.add(mask.clone());

  final result = cv.merge(channels);

  channels.dispose();
  foreground.dispose();

  return result;
}

void _main() {
  const inputPath = 'input.jpg';

  const maskPath = 'output_mask.png';

  const foregroundPath = 'output_foreground.png';

  //
  // =========================================================
  // 读取
  // =========================================================
  //

  final image = cv.imread(inputPath, flags: cv.IMREAD_COLOR);

  if (image.isEmpty) {
    throw Exception('图片读取失败：$inputPath');
  }

  //
  // =========================================================
  // 创建分割器
  // =========================================================
  //

  final remover = OpenCVBackgroundRemover(
    //
    // 图片边缘采样宽度
    //
    border: 10,

    //
    // 小于图片面积 0.1% 的区域删除
    //
    minAreaRatio: 0.001,

    //
    // Lab 背景差异阈值
    //
    threshold: 18,

    //
    // 形态学核
    //
    morphologySize: 5,
  );

  //
  // =========================================================
  // 分割
  // =========================================================
  //

  final mask = remover.removeBackground(image);

  //
  // 输出 Mask
  //
  cv.imwrite(maskPath, mask);

  //
  // =========================================================
  // 输出透明 PNG
  // =========================================================
  //

  final foreground = makeTransparentForeground(image, mask);

  cv.imwrite(foregroundPath, foreground);

  print('');
  print('================================');
  print('完成');
  print('Mask       : $maskPath');
  print('Foreground : $foregroundPath');
  print('================================');

  foreground.dispose();
  mask.dispose();
  image.dispose();
}
