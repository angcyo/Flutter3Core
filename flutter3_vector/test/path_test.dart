import 'dart:developer';
import 'dart:ui';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/14
///
void main() {
  ensureInitialized();
  test('test path1', () {
    const rect = Rect.fromLTWH(0, 0, 100, 100);
    /*final path1 = Path()
      ..addArc(rect, 180.hd, 180.hd);*/
    final path1 = Path()..addRect(rect);

    /*final path2 = Path()
      ..moveTo(50, -1000)
      ..lineTo(50, 1000);*/

    final path2 = Path()
      ..addRect(Rect.fromLTWH(50, 0, 51, 100));

    final intersects = path1.intersects(path2);

    //op操作
    final opPath = Path.combine(PathOperation.intersect, path1, path2);
    final metrics = opPath.computeMetrics(forceClosed: true);
    debugger();
    consoleLog(opPath.toPointInfoList());

    consoleLog('${[path1].toGCodeString()}');

    consoleLog('...end1');
    expect(true, true);
  });
  test('test path2', () {
    // 创建第一个线
    Path path1 = Path();
    path1.moveTo(50, 50);
    path1.lineTo(150, 50);

    // 创建第二个线
    Path path2 = Path();
    path2.moveTo(100, 0);
    path2.lineTo(100, 100);

    // 求两个线的交集
    Path intersection = Path.combine(PathOperation.intersect, path1, path2);
    final isEmpty = intersection.isEmpty;
    debugger();

    consoleLog('...end2');
    expect(true, true);
  });
}
