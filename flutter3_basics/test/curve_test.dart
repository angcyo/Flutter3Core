import 'package:flutter/animation.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/18
///
/// 动画曲线测试
///
/// https://cubic-bezier.com/
void main() {
  final customCurve = Cubic(0, 0.89, 0.4, 1);
  final max = 100;
  for (var i = 0; i < max; i++) {
    final value = i / max;
    print("$value->${customCurve.transform(value)}");
  }
  print("...end");
}
