

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/01
///
void main() {
  /*test('test', () {
    final list = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    consoleLog(list.splitByCount(2));

    const int = 1-000-000;
    consoleLog(int);

    return true;
  });*/

  /*print(lerpNum(-59, 10, 1, 5));
  print(lerpNum(-59, 10, 2, 5));

  print(lerpNum(10, 60, 1, 5));
  print(lerpNum(10, 59, 2, 5));*/

  final max = 10;
  final min = 59;
  final count = 5;

  final step = ((max - min) / (count - 1)).ceil();
  print(step);
  print("...");
  for (var i = 0; i < count; i++) {
    print(min + step * i);
  }

  final step2 = (max - min) / (count - 1);
  print(step2);
  print("...");
  for (var i = 0; i < count; i++) {
    print((min + step2 * i).round());
  }

  final maxBase36Value = int.parse("1z141z4", radix: 36); // 4294967296
  final maxBase36ValueStr = 65535.toRadixString(36); // 1ekf
  print("...");
  print(maxBase36Value);
  print(maxBase36ValueStr);

  //Radix 48 not in range 2..36
  final maxBase48Value = int.parse("11414", radix: 18); // 112126
  final maxBase48ValueStr = 65535.toRadixString(18); // b44f
  print("...");
  print(maxBase48Value);
  print(maxBase48ValueStr);

  final maxBase19Value = int.parse("11414", radix: 19); // 138647
  final maxBase19ValueStr = 65535.toRadixString(19); // 9aa4
  print("...");
  print(maxBase19Value);
  print(maxBase19ValueStr);
}
