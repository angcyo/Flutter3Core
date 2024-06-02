import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/02
///
void main() {
  test('test', () {
    double m_bucketx;
    double m_buckety;
    double m_bucketx2;
    double m_buckety2;

    // 点的行数
    int pointRows = 65;
    // 点的列数
    int pointCols = 65;

    // 起始坐标x
    double startPointX = -32768;
    double endPointX = 32767;
    double pointXStep = 1024;

    // 起始坐标y
    double startPointY = -32768;
    double endPointY = 32767;
    double pointYStep = 1024;

    // 1: 生成初始点的坐标
    List<Point> pointList = <Point>[];
    for (int i = 0; i < pointRows; i++) {
      for (int j = 0; j < pointCols; j++) {
        double x = startPointX + j * pointXStep;
        double y = startPointY + i * pointYStep;

        if (j == pointCols - 1) {
          //最后一列的x
          x = endPointX;
        }
        if (i == pointRows - 1) {
          //最后一行的y
          y = endPointY;
        }

        pointList.add(Point(x, y, null));
      }
    }

    // 2: 计算
    

    // 3: log
    StringBuffer buffer = StringBuffer();
    final list = pointList.splitByCount(pointCols);
    for (final pointList in list) {
      for (final point in pointList) {
        buffer.write("${point.x.toInt()},${point.y.toInt()}".padRight(15));
      }
      buffer.writeln();
    }
    outputFile('point_list.log').writeString(buffer.toString());
    return true;
  });
  consoleLog('...end2');
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  path.ensureParentDirectory();
  return File(path);
}
