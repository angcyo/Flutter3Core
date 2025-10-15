import 'dart:math';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/18
///
/// 一些算法的测试
void main() {
  testShuffleAlgorithm();
}

/// 洗牌算法
void testShuffleAlgorithm() {
  final arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  print('$arr 洗牌算法↓');

  for (var count = 0; count < 5; count++) {
    for (int i = 0; i < arr.length; i++) {
      final randomIndex = Random().nextInt(arr.length);
      final temp = arr[i];
      arr[i] = arr[randomIndex];
      arr[randomIndex] = temp;
    }
    colorLog(arr);
  }
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg\x1B[0m');
}
