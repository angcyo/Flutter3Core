import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });*/

  test("test basics", () {
    String hex = "#2febff";
    consoleLog(hex.toColor());

    consoleLog('${0.1.round()}');
    consoleLog('${-0.1.round()}');

    consoleLog('${0.1.ceil()}');
    consoleLog('${-0.1.ceil()}');

    consoleLog(intMaxValue);
    consoleLog(intMinValue);
    consoleLog(doubleMaxValue);
    consoleLog(doubleMinValue);
  });

  const maxInt = 0xFFFFFFFF;
  test('test 1', () {
    consoleLog('${maxInt}');
    consoleLog('${maxInt.toRadixString(2)}');
    consoleLog('${maxInt.toRadixString(4)}');
    consoleLog('${maxInt.toRadixString(6)}');
    consoleLog('${maxInt.toRadixString(8)}');
    consoleLog('${maxInt.toRadixString(16)}');
    consoleLog('${maxInt.toRadixString(2).length}');
    consoleLog('${UniqueKey().hashCode}');
    consoleLog('${UniqueKey().hashCode.toRadixString(2).length}');

    consoleLog(DateTime.now().millisecondsSinceEpoch);
    consoleLog(DateTime.now().millisecondsSinceEpoch.toRadixString(2).length);
    consoleLog(DateTime.now().microsecondsSinceEpoch);
    consoleLog(DateTime.now().microsecondsSinceEpoch.toRadixString(2).length);
  });

  test("test 2", () {
    const idGen = TimeIdGen();
    final list = <int>[];
    for (int i = 0; i < maxInt; i++) {
      final id = idGen.get() & 0xFFFFFFFF; //UniqueKey().hashCode;
      if (list.contains(id)) {
        consoleLog('重复id[$i]:$id ${id.toRadixString(2).length}');
      } else {
        list.add(id);
      }
    }
  });

  test('test 3', () {
    final bytes = [0, 1, 2];
    //bytes.removeRange(0, 100); //RangeError (end): Invalid value: Not in inclusive range 0..3: 100
    //consoleLog(bytes);
    bytes.removeRange(0, bytes.length - 1);
    consoleLog(bytes);
    consoleLog("...end");
  });
}
