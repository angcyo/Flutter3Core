import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/04/15
///
///
void main(){
  final path = r"D:\jadx\.output\Creative Space\app\src\main\assets\main\svg-shapes\shapes\1-basic\basic-1.svg";
  //0dfd0ae017d99a825f442cd2f9c2926f
  print("MD5->${path.fileMd5Sync}");

  final path2 = r"E:\temp\basic-1-2.svg";
  //0d329a6d043f50b54400b7a4edc0ecc7
  print("MD5->${path2.fileMd5Sync}");

  final path3 = r"E:\Downloads\basic-1.svg";
  //0d329a6d043f50b54400b7a4edc0ecc7
  print("MD5->${path3.fileMd5Sync}");
}