import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:opencv_dart/opencv.dart' as cv;

export 'package:opencv_dart/opencv.dart';

part 'src/camera_calibrate.dart';
part 'src/opencv.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/09
///
/// https://opencv-python-tutorials.readthedocs.io/zh/latest/
///
/// Opencv 默认的颜色通道排序是 BGR
/// - [cv.MatType.CV_8UC3] BGR
/// - [cv.MatType.CV_8UC4] BGRA

/// 测试Opencv的连通性
/// - [cv.getBuildInformation]
///
/// ```
/// Hello Opencv:4.12.0 / 16 / 974138714643000
/// ```
String testOpencv() {
  final log =
      'Hello Opencv:${cv.openCvVersion()} / ${cv.getNumThreads()} / ${cv.getTickCount()}'; /*/ ${cv.getBuildInformation()}*/
  assert(() {
    l.i(log);
    l.i(cv.getBuildInformation());
    //透视变化
    final mat = cvPerspectiveTransform2f(
      [
        cv.Point2f(13, 13),
        cv.Point2f(166.5, 18.5),
        cv.Point2f(163, 163.5),
        cv.Point2f(10.5, 160.5),
      ],
      [
        cv.Point2f(20, 20),
        cv.Point2f(160, 20),
        cv.Point2f(160, 160),
        cv.Point2f(20, 160),
      ],
    );
    //cv.normalize(mat);
    //[[0.8922067941243021, 0.014188208530941089, 8.176286297216732],
    // [-0.03583605628807173, 0.9391478601047357, 8.216367882118266],
    // [-0.00010755186200365007, -0.000048519939015975823, 1.0]]
    l.d("$mat");
    l.d("${mat.toList()}");
    l.d("${mat.matrix3List}");
    return true;
  }());
  return log;
}
