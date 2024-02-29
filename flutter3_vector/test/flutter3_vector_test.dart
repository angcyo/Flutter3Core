import 'dart:ui';

import 'package:flutter3_vector/flutter3_vector.dart';

void main() {
  /*test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });*/
  testPath();
}

void testPath() {
  final path = Path()
    ..addOval(Rect.fromCircle(center: const Offset(100, 100), radius: 100));
  print(path.toSvgString());
}
