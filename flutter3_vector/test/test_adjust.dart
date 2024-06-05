import 'dart:io';
import 'dart:math';

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
    await test2();
    return true;
  });
  consoleLog('...end2');
}

Future test2() async {
  //4个关键入参
  double m_bucketx = 0.875; //失真x值 (0.875-1.0)  左上 右上 横向
  double m_buckety = m_bucketx; //失真y值 (0.875-1.0)  纵向
  double m_bucketx2 = m_bucketx; //失真x值 (0.875-1.0) 左下 右下 横向
  double m_buckety2 = m_bucketx; //失真y值 (0.875-1.0) 纵向

  //
  int xCount = 65;
  int yCount = 65;

  int xCenter = (xCount / 2.0).ceil();
  int yCenter = (yCount / 2.0).ceil();

  //二维数组
  List<List<double>> Xtable =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));
  List<List<double>> Ytable =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));

  //分别初始化x/y坐标表
  for (var i = 0; i < xCount; i++) {
    for (var j = 0; j < yCount; j++) {
      Xtable[i][j] = (-32768 + j * 1024);
      Ytable[i][j] = (-32768 + i * 1024);

      //最后一列, x为最大值
      if (j >= 64) Xtable[i][j] = 32767;
      //最后一行, y为最大值
      if (i >= 64) Ytable[i][j] = 32767;
    }
  }

  //开始矫正
  double PI = 3.1415926535897932;
  //焦距(mm)
  double m_ScanHigh = 100;
  //振镜最大偏角(度)
  double m_ScanAngle = 20;
  //振镜X,Y旧距(nm);
  double m_ScanDis = 5;

  double Xmin, Xmax, Ymin, Ymax;
  Xmin = -(m_ScanHigh + m_ScanDis) * tan(m_ScanAngle * PI / 180.0);
  Ymin = -m_ScanHigh * tan(m_ScanAngle * PI / 180.0);
  Xmax = (m_ScanHigh + m_ScanDis) * tan(m_ScanAngle * PI / 180.0);
  Ymax = m_ScanHigh * tan(m_ScanAngle * PI / 180.0);

  int TabYmax = 32767;
  int TabYmin = -32768;
  int TabXmax = 32767;
  int TabXmin = -32768;
  double iScanK = 65535.0 / (Ymax - Ymin); //单位是bits/mm

  double angle = m_ScanAngle * PI / 180.0;

  //临时x/y坐标表
  double y;
  List<List<double>> CalCTFX =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));
  List<List<double>> CalCTFY =
      List.generate(xCount, (index) => List.generate(yCount, (index) => 0.0));

  double A = 0, B = 0, TopX, TopY, Px, Py;
  double oldy;

  //先矫正左半边
  for (var i = 0; i < xCenter; i++) {
    oldy = Ytable[i][0] / iScanK;

    if ((m_buckety != 1) && (oldy != 0)) {
      TopX =
          atan(Xmin / (sqrt(pow(m_ScanHigh, 2) + pow(oldy, 2)) + m_ScanDis)) *
              (32767 / angle) /
              iScanK;
      TopY = atan(oldy / m_ScanHigh) * (32767 / angle) / iScanK;
      Px = 0;
      Py = m_buckety * 0.99 * TopY;
      A = fabs(Py);
      B = fabs(A * TopX / sqrt(TopY * TopY - A * A));
    }

    //左半边, 一行一行
    for (var j = 0; j < yCount; j++) {
      CalCTFX[i][j] = (Xtable[i][j] / iScanK);
      CalCTFY[i][j] = (Ytable[i][j] / iScanK);

      if (j < yCenter) {
        //左上角
        if (m_bucketx != 1) {
          CalCTFX[i][j] = atan(CalCTFX[i][j] /
                  (sqrt(pow(m_ScanHigh, 2) +
                          pow(oldy, 2) * (1 - m_bucketx) * 32) +
                      m_ScanDis)) *
              (32767.0 / angle) /
              iScanK;
          CalCTFY[i][j] = atan(oldy / m_ScanHigh) * (32767.0 / angle) / iScanK;
        }
      } else {
        //左下角
        if (m_bucketx2 != 1) {
          CalCTFX[i][j] = atan(CalCTFX[i][j] /
                  (sqrt(pow(m_ScanHigh, 2) +
                          pow(oldy, 2) * (1 - m_bucketx2) * 32) +
                      m_ScanDis)) *
              (32767.0 / angle) /
              iScanK;
          CalCTFY[i][j] = atan(oldy / m_ScanHigh) * (32767.0 / angle) / iScanK;
        }
      }

      if ((m_buckety != 1) && (oldy != 0)) {
        CalCTFY[i][j] = A * sqrt(1 + pow(CalCTFX[i][j], 2) / pow(B, 2));
        if (oldy < 0) {
          CalCTFY[i][j] = -CalCTFY[i][j];
        }
      }
    }
  }

  //再矫正右半边
  for (var i = xCenter; i < xCount; i++) {
    oldy = y = Ytable[i][0] / iScanK;

    if ((m_buckety2 != 1) && (oldy != 0)) {
      TopX =
          atan(Xmin / (sqrt(pow(m_ScanHigh, 2) + pow(oldy, 2)) + m_ScanDis)) *
              (32767 / angle) /
              iScanK;
      TopY = atan(oldy / m_ScanHigh) * (32767 / angle) / iScanK;
      Px = 0;
      Py = m_buckety2 * 0.99 * TopY;
      A = fabs(Py);
      B = fabs(A * TopX / sqrt(TopY * TopY - A * A));
    }

    //右半边, 一行一行
    for (var j = 0; j < yCount; j++) {
      CalCTFX[i][j] = (Xtable[i][j] / iScanK);
      CalCTFY[i][j] = (Ytable[i][j] / iScanK);

      if (j < yCenter) {
        //右上角
        if (m_bucketx != 1) {
          CalCTFX[i][j] = atan(CalCTFX[i][j] /
                  (sqrt(pow(m_ScanHigh, 2) +
                          pow(oldy, 2) * (1 - m_bucketx) * 32) +
                      m_ScanDis)) *
              (32767.0 / angle) /
              iScanK;
          CalCTFY[i][j] = atan(oldy / m_ScanHigh) * (32767.0 / angle) / iScanK;
        }
      } else {
        //右下角
        if (m_bucketx2 != 1) {
          CalCTFX[i][j] = atan(CalCTFX[i][j] /
                  (sqrt(pow(m_ScanHigh, 2) +
                          pow(oldy, 2) * (1 - m_bucketx2) * 32) +
                      m_ScanDis)) *
              (32767.0 / angle) /
              iScanK;
          CalCTFY[i][j] = atan(oldy / m_ScanHigh) * (32767.0 / angle) / iScanK;
        }
      }

      if ((m_buckety2 != 1) && (oldy != 0)) {
        CalCTFY[i][j] = A * sqrt(1 + pow(CalCTFX[i][j], 2) / pow(B, 2));
        if (oldy < 0) {
          CalCTFY[i][j] = -CalCTFY[i][j];
        }
      }
    }
  }

  //将矫正数据作用到原始点坐标中
  for (var i = 0; i < xCount; i++) {
    for (var j = 0; j < yCount; j++) {
      Xtable[i][j] = max(-32768, min(32767, CalCTFX[j][i] * iScanK));
      Ytable[i][j] = max(-32768, min(32767, CalCTFY[j][i] * iScanK));
    }
  }

  // log
  StringBuffer buffer = StringBuffer();
  for (var i = 0; i < xCount; i++) {
    for (var j = 0; j < yCount; j++) {
      buffer.write(
          "${Xtable[i][j].toInt()},${Ytable[i][j].toInt()}".padRight(15));
    }
    buffer.writeln();
  }
  await outputFile('point_list_$m_bucketx.log').writeString(buffer.toString());
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
