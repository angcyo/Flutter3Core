part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/21
///

/// 设置屏幕方向
///
/// [OrientationBuilder]
///
/// ```
/// MediaQuery.of(context).orientation;
/// '屏幕方向: ${orientation == Orientation.portrait ? "纵向" : "横向"}',
/// ```
///
/// [DeviceOrientation.landscapeRight] // 横屏模式，向右旋转
/// [DeviceOrientation.landscapeLeft] // 横屏模式 向左旋转
Future<void> setScreenOrientation([DeviceOrientation? orientation]) =>
    SystemChrome.setPreferredOrientations(
        orientation == null ? [] : [orientation]);

Future<void> setScreenOrientations([List<DeviceOrientation>? orientations]) =>
  SystemChrome.setPreferredOrientations(orientations ?? []);

/// 设置横屏
Future<void> setScreenLandscape([List<DeviceOrientation> orientations = const [
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight
]]) =>
  setScreenOrientations(orientations);


/// 设置竖屏
Future<void> setScreenPortrait([List<DeviceOrientation> orientations = const [
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown
]]) =>
  setScreenOrientations(orientations);


/// 设置ui模式
/// [SystemChrome.setEnabledSystemUIMode]
/// void

//设置状态栏样式
//SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

//震动反馈
//Feedback.forLongPress(context);

//声音反馈
//HapticFeedback.lightImpact();
//SystemSound.play();
