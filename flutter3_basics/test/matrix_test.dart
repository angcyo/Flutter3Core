import 'dart:math';

import 'package:vector_math/vector_math.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/04/21
///
/// 在二维空间中，一个仿射变换矩阵（3 x 3）通常由以下顺序的变换组合而成：`M = T · R · K · S`
/// - T (Translation): 平移
/// - R (Rotation): 旋转
/// - K (Skew/Shear): 错切
/// - S (Scale): 缩放
void main() {
  //创建单位矩阵
  //Matrix3.identity↓
  //[0] [1.0,0.0,0.0]
  //[1] [0.0,1.0,0.0]
  //[2] [0.0,0.0,1.0]
  println("Matrix3.identity", Matrix3.identity());
  //Matrix4.identity↓
  //[0] [1.0,0.0,0.0,0.0]
  //[1] [0.0,1.0,0.0,0.0]
  //[2] [0.0,0.0,1.0,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println("Matrix4.identity", Matrix4.identity());

  testRotationMatrix();
}

/// 测试旋转的矩阵
void testRotationMatrix() {
  //旋转的角度, 弧度
  final radians = pi / 4;

  //使用欧拉角旋转90°
  //Matrix3.rotationZ↓
  //[0] [0.7071067690849304,-0.7071067690849304,0.0]
  //[1] [0.7071067690849304,0.7071067690849304,0.0]
  //[2] [0.0,0.0,1.0]
  println("Matrix3.rotationZ", Matrix3.rotationZ(radians));
  //Quaternion.fromRotation↓
  //[0] [0.7071067690849304,-0.7071067690849304,0.0]
  //[1] [0.7071067690849304,0.7071067690849304,0.0]
  //[2] [0.0,0.0,1.0]
  println(
    "Quaternion.fromRotation",
    Quaternion.fromRotation(Matrix3.rotationZ(radians)).asRotationMatrix(),
  );
  //Matrix4.rotationZ↓
  //[0] [0.7071067690849304,-0.7071067690849304,0.0,0.0]
  //[1] [0.7071067690849304,0.7071067690849304,0.0,0.0]
  //[2] [0.0,0.0,1.0,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println("Matrix4.rotationZ", Matrix4.rotationZ(radians));

  //使用4元数旋转90°
  //Quaternion.fromRotation↓
  //[0.0, 0.0, 0.3826834261417389, 0.9238795042037964]
  println(
    "Quaternion.fromRotation",
    Quaternion.fromRotation(Matrix3.rotationZ(radians)).storage,
  );
  //Quaternion.fromRotation↓
  //[0] [0.7071067690849304,-0.7071067690849304,0.0,0.0]
  //[1] [0.7071067690849304,0.7071067690849304,0.0,0.0]
  //[2] [0.0,0.0,1.0,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println(
    "Quaternion.fromRotation",
    Matrix4.compose(
      Vector3.all(0),
      Quaternion.fromRotation(Matrix3.rotationZ(radians)),
      Vector3.all(1),
    ),
  );

  //Quaternion.axisAngle↓
  //[0] [0.7071067690849304,-0.7071067690849304,0.0,0.0]
  //[1] [0.7071067690849304,0.7071067690849304,0.0,0.0]
  //[2] [0.0,0.0,1.0,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println(
    "Quaternion.axisAngle",
    Matrix4.compose(
      Vector3.all(0),
      Quaternion.axisAngle(Vector3(0, 0, 1), radians),
      Vector3.all(1),
    ),
  );

  //Quaternion.euler yaw 偏航(Z轴)↓
  //[0.0, 0.3826834261417389, 0.0, 0.9238795042037964]
  //[0] [0.7071067690849304,0.0,0.7071067690849304,0.0]
  //[1] [0.0,1.0,0.0,0.0]
  //[2] [-0.7071067690849304,0.0,0.7071067690849304,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println("Quaternion.yaw", Quaternion.euler(radians, 0, 0).storage);
  println(
    "Quaternion.euler yaw 偏航(Z轴)",
    Matrix4.compose(
      Vector3.all(0),
      Quaternion.euler(radians, 0, 0),
      Vector3.all(1),
    ),
  );

  //Quaternion.euler pitch 俯仰(Y轴)↓
  //[0.3826834261417389, 0.0, 0.0, 0.9238795042037964]
  //[0] [1.0,0.0,0.0,0.0]
  //[1] [0.0,0.7071067690849304,-0.7071067690849304,0.0]
  //[2] [0.0,0.7071067690849304,0.7071067690849304,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println("Quaternion.pitch", Quaternion.euler(0, radians, 0).storage);
  println(
    "Quaternion.euler pitch 俯仰(Y轴)",
    Matrix4.compose(
      Vector3.all(0),
      Quaternion.euler(0, radians, 0),
      Vector3.all(1),
    ),
  );

  //Quaternion.euler roll 翻滚(X轴)↓
  //[0.0, 0.0, 0.3826834261417389, 0.9238795042037964]
  //[0] [0.7071067690849304,-0.7071067690849304,0.0,0.0]
  //[1] [0.7071067690849304,0.7071067690849304,0.0,0.0]
  //[2] [0.0,0.0,1.0,0.0]
  //[3] [0.0,0.0,0.0,1.0]
  println("Quaternion.roll", Quaternion.euler(0, 0, radians).storage);
  println(
    "Quaternion.euler roll 翻滚(X轴)",
    Matrix4.compose(
      Vector3.all(0),
      Quaternion.euler(0, 0, radians),
      Vector3.all(1),
    ),
  );
}

void println(Object tag, Object obj) {
  print("$tag↓\n");
  print(obj);
  print("\n");
}
