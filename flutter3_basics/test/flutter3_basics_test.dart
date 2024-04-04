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

  /*test("test basics", () {
    String hex = "#2febff";
    print(hex.toColor());
  });*/

  const maxInt = 0xFFFFFFFF;
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

  test("test", () {
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
}

/// This ID is independent of the time zone.
class TimeIdGen {
  /// See notes for [TimeIdType].
  const TimeIdGen([this.type = TimeIdType.microseconds]);

  /// Each call generate a new ID greater than previous.
  int get([dynamic source]) => next;

  int get next {
    int generate() => type == TimeIdType.milliseconds
        ? DateTime.now().millisecondsSinceEpoch
        : DateTime.now().microsecondsSinceEpoch;

    /// we need this for guarantee a next ID not equals to previous call [next]
    final prev = generate();
    for (;;) {
      final t = generate();
      if (t != prev) {
        return t;
      }
    }
  }

  final TimeIdType type;
}

enum TimeIdType {
  /// ID <= 8640000000000000
  milliseconds,

  /// ID <= 8640000000000000000
  /// ! This value does not fit into 53 bits (the size of a IEEE double).
  /// ! A JavaScript number is not able to hold this value.
  microseconds,
}
