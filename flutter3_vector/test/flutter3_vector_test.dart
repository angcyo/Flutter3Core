import 'dart:ui';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_vector/flutter3_vector.dart';

void main() {
  /*test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });*/
  //print(1.toDpFromMm());
  //print(0.25.toDpFromMm());

  //testPath();
  testCircle();
}

void testPath() {
  final path = Path()
    ..addOval(Rect.fromCircle(center: const Offset(100, 100), radius: 100));
  print(path.toSvgString());
}

void testCircle() {
  final a = Offset(0, 0);
  final b = Offset(100, 0);
  final c = Offset(50, 50);
  final cc = centerOfCircle(a, b, c);
  print(cc);
}
