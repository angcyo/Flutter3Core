import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/04
///
void main() {
  final intList = [1, 2, 3, 4];
  print(intList.indexListOf([2, 3]));
  print(intList.indexListOf([3, 4]));
  print(intList.indexListOf([2, 3, 1]));

  final strList = ["1", "2", "3", "4"];
  print(strList.indexListOf(["2", "3"]));
  print(strList.indexListOf(["3", "4"]));
  print(strList.indexListOf(["2", "3", "1"]));
}
