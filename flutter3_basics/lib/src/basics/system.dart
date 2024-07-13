part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/21
///

/// 设置屏幕方向
/// [DeviceOrientation.landscapeRight] // 横屏模式，向右旋转
/// [DeviceOrientation.landscapeLeft] // 横屏模式 向左旋转
void setScreenOrientation(DeviceOrientation orientation) {
  SystemChrome.setPreferredOrientations([orientation]);
}

/// 设置横屏
void setScreenLandscape(
    [DeviceOrientation orientation = DeviceOrientation.landscapeLeft]) {
  setScreenOrientation(orientation);
}

//设置状态栏样式
//SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

//震动反馈
//Feedback.forLongPress(context);

//声音反馈
//HapticFeedback.lightImpact();
//SystemSound.play();
