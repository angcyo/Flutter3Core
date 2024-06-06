import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/02
///
void main() {
  test('test', () async {
    //await test1();
    //await test2();
    await test2Rotate();
    return true;
  });
  consoleLog('...end2');
}

Future test2() async {
  //4个关键入参
  const double xFactor = 0.9; //失真x值 (0.875-1.0)  左上 右上 横向
  const double yFactor = xFactor; //失真y值 (0.875-1.0)  纵向
  const double x2Factor = xFactor; //失真x值 (0.875-1.0) 左下 右下 横向
  const double y2Factor = xFactor; //失真y值 (0.875-1.0) 纵向

  //
  const double pXMin = -32768;
  const double pXMax = 32767;
  const double pXCenter = 0;
  const double pYMin = -32768;
  const double pYMax = 32767;
  const double pYCenter = 0;
  const double pXStep = 1024;
  const double pYStep = 1024;

  const double pi = 3.1415926535897932;
  //焦距(mm)
  const double scanHigh = 100;
  //振镜最大偏角(度)
  const double scanAngle = 20;
  //振镜X,Y间距(mm);
  const double scanDis = 5;

  const int xCount = 65;
  const int yCount = 65;

  final int xCenter = (xCount / 2.0).ceil();
  final int yCenter = (yCount / 2.0).ceil();

  //二维数组
  List<List<double>> xPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));
  List<List<double>> yPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));

  //分别初始化x/y坐标表
  for (var i = 0; i < xCount; i++) {
    for (var j = 0; j < yCount; j++) {
      xPointList[i][j] = (pXMin + j * pXStep);
      yPointList[i][j] = (pYMin + i * pYStep);

      //最后一列, x为最大值
      if (j >= xCount - 1) xPointList[i][j] = pXMax;
      //最后一行, y为最大值
      if (i >= yCount - 1) yPointList[i][j] = pYMax;
    }
  }

  //开始矫正

  final xMin, xMax, yMin, yMax;
  xMin = -(scanHigh + scanDis) * tan(scanAngle * pi / 180.0);
  yMin = -scanHigh * tan(scanAngle * pi / 180.0);
  xMax = (scanHigh + scanDis) * tan(scanAngle * pi / 180.0);
  yMax = scanHigh * tan(scanAngle * pi / 180.0);

  double scanKY = (pYMax - pYMin) / (yMax - yMin); //单位是bits/mm
  double scanKX = scanKY; //强制=y, 否则结果不对

  double angle = scanAngle * pi / 180.0;

  //临时x/y坐标表
  double y;
  List<List<double>> tempXPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));
  List<List<double>> tempYPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));

  double A = 0, B = 0, topX, topY, pX, pY;
  double oldY;

  //先矫正左半边
  for (var i = 0; i < xCenter; i++) {
    oldY = yPointList[i][0] / scanKY;

    if ((yFactor != 1) && (oldY != 0)) {
      topX = atan(xMin / (sqrt(pow(scanHigh, 2) + pow(oldY, 2)) + scanDis)) *
          (pXMax / angle) /
          scanKX;
      topY = atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
      pX = 0;
      pY = yFactor * 0.99 * topY;
      A = fabs(pY);
      B = fabs(A * topX / sqrt(topY * topY - A * A));
    }

    //左半边, 一行一行
    for (var j = 0; j < yCount; j++) {
      tempXPointList[i][j] = (xPointList[i][j] / scanKX);
      tempYPointList[i][j] = (yPointList[i][j] / scanKY);

      if (j < yCenter) {
        //左上角
        if (xFactor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - xFactor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKX;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      } else {
        //左下角
        if (x2Factor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - x2Factor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKX;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      }

      if ((yFactor != 1) && (oldY != 0)) {
        tempYPointList[i][j] =
            A * sqrt(1 + pow(tempXPointList[i][j], 2) / pow(B, 2));
        if (oldY < 0) {
          tempYPointList[i][j] = -tempYPointList[i][j];
        }
      }
    }
  }

  //再矫正右半边
  for (var i = xCenter; i < xCount; i++) {
    oldY = y = yPointList[i][0] / scanKY;

    if ((y2Factor != 1) && (oldY != 0)) {
      topX = atan(xMin / (sqrt(pow(scanHigh, 2) + pow(oldY, 2)) + scanDis)) *
          (pXMax / angle) /
          scanKX;
      topY = atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
      pX = 0;
      pY = y2Factor * 0.99 * topY;
      A = fabs(pY);
      B = fabs(A * topX / sqrt(topY * topY - A * A));
    }

    //右半边, 一行一行
    for (var j = 0; j < yCount; j++) {
      tempXPointList[i][j] = (xPointList[i][j] / scanKY);
      tempYPointList[i][j] = (yPointList[i][j] / scanKY);

      if (j < yCenter) {
        //右上角
        if (xFactor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - xFactor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKY;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      } else {
        //右下角
        if (x2Factor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - x2Factor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKX;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      }

      if ((y2Factor != 1) && (oldY != 0)) {
        tempYPointList[i][j] =
            A * sqrt(1 + pow(tempXPointList[i][j], 2) / pow(B, 2));
        if (oldY < 0) {
          tempYPointList[i][j] = -tempYPointList[i][j];
        }
      }
    }
  }

  // log
  const radius = 10.0;
  const scale = 0.025;
  const offsetWidth = 100.0; //宽度额外增加的量
  const offsetHeight = 100.0; //高度额外增加的量
  const offsetX = offsetWidth / 2; //宽度偏移后x绘制的偏移量
  const offsetY = offsetHeight / 2; //高度偏移后y绘制的偏移量
  final image = drawImageSync(
      const Size((pXMax - pXMin) * scale + offsetWidth,
          (pYMax - pYMin) * scale + offsetHeight), (canvas) async {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    //debugger();
    //--原始数据
    for (var i = 0; i < xCount; i++) {
      for (var j = 0; j < yCount; j++) {
        canvas.drawCircle(
          Offset((xPointList[i][j] - pXMin) * scale + offsetX,
              (yPointList[i][j] - pYMin) * scale + offsetY),
          radius,
          paint,
        );
      }
    }
    //将矫正数据作用到原始点坐标中
    for (var i = 0; i < xCount; i++) {
      for (var j = 0; j < yCount; j++) {
        xPointList[i][j] =
            max(pXMin, min(pXMax, tempXPointList[j][i] * scanKX));
        yPointList[i][j] =
            max(pYMin, min(pYMax, tempYPointList[j][i] * scanKY));
      }
    }
    //--矫正后的数据
    paint.color = Colors.redAccent;
    StringBuffer buffer = StringBuffer();
    for (var i = 0; i < xCount; i++) {
      for (var j = 0; j < yCount; j++) {
        canvas.drawCircle(
          Offset((xPointList[i][j] - pXMin) * scale + offsetX,
              (yPointList[i][j] - pYMin) * scale + offsetY),
          radius,
          paint,
        );

        buffer.write("${xPointList[i][j].toInt()},${yPointList[i][j].toInt()}"
            .padRight(15));
      }
      buffer.writeln();
    }
    await outputFile('point_list_$xFactor.log').writeString(buffer.toString());
  });
  await image.saveToFile(outputFile('point_list_$xFactor.png'));
}

Future test2Rotate() async {
  //4个关键入参
  const double xFactor = 0.9; //失真x值 (0.875-1.0)  左上 右上 横向
  const double yFactor = xFactor; //失真y值 (0.875-1.0)  纵向
  const double x2Factor = xFactor; //失真x值 (0.875-1.0) 左下 右下 横向
  const double y2Factor = xFactor; //失真y值 (0.875-1.0) 纵向

  //
  const double pXMin = -32768;
  const double pXMax = 32767;
  const double pXCenter = 0;
  const double pYMin = -32768;
  const double pYMax = 32767;
  const double pYCenter = 0;
  const double pXStep = 1024;
  const double pYStep = 1024;

  const double pi = 3.1415926535897932;
  //焦距(mm)
  const double scanHigh = 100;
  //振镜最大偏角(度)
  const double scanAngle = 20;
  //振镜X,Y间距(mm);
  const double scanDis = 5;

  const int xCount = 65;
  const int yCount = 65;

  final int xCenter = (xCount / 2.0).ceil();
  final int yCenter = (yCount / 2.0).ceil();

  //二维数组
  List<List<double>> xPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));
  List<List<double>> yPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));

  //分别初始化x/y坐标表
  for (var i = 0; i < xCount; i++) {
    for (var j = 0; j < yCount; j++) {
      xPointList[i][j] = (pXMin + j * pXStep);
      yPointList[i][j] = (pYMin + i * pYStep);

      //最后一列, x为最大值
      if (j >= xCount - 1) xPointList[i][j] = pXMax;
      //最后一行, y为最大值
      if (i >= yCount - 1) yPointList[i][j] = pYMax;
    }
  }

  //开始矫正

  final xMin, xMax, yMin, yMax;
  xMin = -(scanHigh + scanDis) * tan(scanAngle * pi / 180.0);
  xMax = (scanHigh + scanDis) * tan(scanAngle * pi / 180.0);

  yMin = -scanHigh * tan(scanAngle * pi / 180.0);
  yMax = scanHigh * tan(scanAngle * pi / 180.0);

  double scanKY = (pYMax - pYMin) / (yMax - yMin); //单位是bits/mm
  double scanKX = scanKY; //强制=y, 否则结果不对

  /*double scanKX = (pXMax - pXMin) / (xMax - xMin); //单位是bits/mm
  double scanKY = scanKX; //强制=x, 否则结果不对*/

  double angle = scanAngle * pi / 180.0;

  //临时x/y坐标表
  double y;
  List<List<double>> tempXPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));
  List<List<double>> tempYPointList =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));

  double A = 0, B = 0, topX, topY, pX, pY;
  double oldY;

  //先矫正左半边
  for (var i = 0; i < xCenter; i++) {
    oldY = yPointList[i][0] / scanKY;

    if ((yFactor != 1) && (oldY != 0)) {
      topX = atan(xMin / (sqrt(pow(scanHigh, 2) + pow(oldY, 2)) + scanDis)) *
          (pXMax / angle) /
          scanKX;
      topY = atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
      pX = 0;
      pY = yFactor * 0.99 * topY;
      A = fabs(pY);
      B = fabs(A * topX / sqrt(topY * topY - A * A));
    }

    //左半边, 一行一行
    for (var j = 0; j < yCount; j++) {
      tempXPointList[i][j] = (xPointList[i][j] / scanKX);
      tempYPointList[i][j] = (yPointList[i][j] / scanKY);

      if (j < yCenter) {
        //左上角
        if (xFactor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - xFactor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKX;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      } else {
        //左下角
        if (x2Factor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - x2Factor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKX;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      }

      if ((yFactor != 1) && (oldY != 0)) {
        tempYPointList[i][j] =
            A * sqrt(1 + pow(tempXPointList[i][j], 2) / pow(B, 2));
        if (oldY < 0) {
          tempYPointList[i][j] = -tempYPointList[i][j];
        }
      }
    }
  }

  //再矫正右半边
  for (var i = xCenter; i < xCount; i++) {
    oldY = y = yPointList[i][0] / scanKY;

    if ((y2Factor != 1) && (oldY != 0)) {
      topX = atan(xMin / (sqrt(pow(scanHigh, 2) + pow(oldY, 2)) + scanDis)) *
          (pXMax / angle) /
          scanKX;
      topY = atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
      pX = 0;
      pY = y2Factor * 0.99 * topY;
      A = fabs(pY);
      B = fabs(A * topX / sqrt(topY * topY - A * A));
    }

    //右半边, 一行一行
    for (var j = 0; j < yCount; j++) {
      tempXPointList[i][j] = (xPointList[i][j] / scanKY);
      tempYPointList[i][j] = (yPointList[i][j] / scanKY);

      if (j < yCenter) {
        //右上角
        if (xFactor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - xFactor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKY;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      } else {
        //右下角
        if (x2Factor != 1) {
          tempXPointList[i][j] = atan(tempXPointList[i][j] /
                  (sqrt(pow(scanHigh, 2) + pow(oldY, 2) * (1 - x2Factor) * 32) +
                      scanDis)) *
              (pXMax / angle) /
              scanKX;
          tempYPointList[i][j] =
              atan(oldY / scanHigh) * (pYMax / angle) / scanKY;
        }
      }

      if ((y2Factor != 1) && (oldY != 0)) {
        tempYPointList[i][j] =
            A * sqrt(1 + pow(tempXPointList[i][j], 2) / pow(B, 2));
        if (oldY < 0) {
          tempYPointList[i][j] = -tempYPointList[i][j];
        }
      }
    }
  }

  // log
  const radius = 10.0;
  const scale = 0.025;
  const offsetWidth = 100.0; //宽度额外增加的量
  const offsetHeight = 100.0; //高度额外增加的量
  const offsetX = offsetWidth / 2; //宽度偏移后x绘制的偏移量
  const offsetY = offsetHeight / 2; //高度偏移后y绘制的偏移量
  final image = drawImageSync(
      const Size((pXMax - pXMin) * scale + offsetWidth,
          (pYMax - pYMin) * scale + offsetHeight), (canvas) async {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    //debugger();
    //--原始数据
    for (var i = 0; i < xCount; i++) {
      for (var j = 0; j < yCount; j++) {
        canvas.drawCircle(
          Offset((xPointList[i][j] - pXMin) * scale + offsetX,
              (yPointList[i][j] - pYMin) * scale + offsetY),
          radius,
          paint,
        );
      }
    }
    //将矫正数据作用到原始点坐标中
    for (var i = 0; i < xCount; i++) {
      for (var j = 0; j < yCount; j++) {
        xPointList[i][j] =
            max(pXMin, min(pXMax, tempXPointList[j][i] * scanKX));
        yPointList[i][j] =
            max(pYMin, min(pYMax, tempYPointList[j][i] * scanKY));

        //旋转的角度
        final a = 90.hd;
        const anchor = Offset(pXCenter, pYCenter);
        final dx = xPointList[i][j] - anchor.dx;
        final dy = yPointList[i][j] - anchor.dy;
        final rotateX = anchor.dx + dx * cos(a) - dy * sin(a);
        final rotateY = anchor.dy + dx * sin(a) + dy * cos(a);

        xPointList[i][j] = rotateX;
        yPointList[i][j] = rotateY;
      }
    }
    //--矫正后的数据
    paint.color = Colors.redAccent;
    StringBuffer buffer = StringBuffer();
    for (var i = 0; i < xCount; i++) {
      for (var j = 0; j < yCount; j++) {
        canvas.drawCircle(
          Offset((xPointList[i][j] - pXMin) * scale + offsetX,
              (yPointList[i][j] - pYMin) * scale + offsetY),
          radius,
          paint,
        );

        buffer.write("${xPointList[i][j].toInt()},${yPointList[i][j].toInt()}"
            .padRight(15));
      }
      buffer.writeln();
    }
    await outputFile('point_list_rotate_$xFactor.log')
        .writeString(buffer.toString());
  });
  await image.saveToFile(outputFile('point_list_rotate_$xFactor.png'));
}

Future test1() async {
  double m_bucketx = 1;
  double m_buckety = 1;
  double m_bucketx2 = 1;
  double m_buckety2 = 1;

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
  @mm
  double m_ScanHigh = 100;
  double m_ScanAngle = 20;
  @mm
  double m_ScanDis = 5;

  double Xmin, Xmax, Ymin, Ymax;
  double PI = 3.1415926535897932;
  Xmin = -(m_ScanHigh + m_ScanDis) * tan(m_ScanAngle * PI / 180.0);
  Ymin = -m_ScanHigh * tan(m_ScanAngle * PI / 180.0);
  Xmax = (m_ScanHigh + m_ScanDis) * tan(m_ScanAngle * PI / 180.0);
  Ymax = m_ScanHigh * tan(m_ScanAngle * PI / 180.0);

  double TabYmax = endPointY,
      TabYmin = startPointY,
      TabXmax = endPointX,
      TabXmin = startPointX;
  double iScanK = 1; //单位是bits/mm

  int Gx = pointRows - 1;
  int Gy = pointCols - 1;
  int RcpGx = ((1.0 / Gx) * (1 << 15) + 0.5).toInt();
  int RcpGy = ((1.0 / Gy) * (1 << 15) + 0.5).toInt();
  int TabXLen = pointRows;
  int TabYLen = pointCols;

  double angle = m_ScanAngle * PI / 180.0;

  double A, B, TopX, TopY, Px, Py;
  double y;
  double oldy;
  for (var i = 0; i < (pointCols / 2.0).ceil(); i++) {
    //左边, 所有列
    int index = i;
    oldy = y = pointList[index].y / iScanK;

    if ((m_buckety != 1) && (oldy != 0)) {
      TopX =
          atan(Xmin / (sqrt(pow(m_ScanHigh, 2) + pow(oldy, 2)) + m_ScanDis)) *
              (endPointX / angle) /
              iScanK;
      TopY = atan(oldy / m_ScanHigh) * (32767 / angle) / iScanK;
      Px = 0;
      Py = m_buckety * 0.99 * TopY;
      A = Py.abs();
      B = (A * TopX / sqrt(TopY * TopY - A * A)).abs();
    }
  }

  // 3: log
  StringBuffer buffer = StringBuffer();
  final list = pointList.splitByCount(pointCols);
  for (final pointList in list) {
    for (final point in pointList) {
      buffer.write("${point.x.toInt()},${point.y.toInt()}".padRight(15));
    }
    buffer.writeln();
  }
  await outputFile('point_list.log').writeString(buffer.toString());
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  path.ensureParentDirectory();
  consoleLog('path:$path');
  return File(path);
}
