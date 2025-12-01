part of '../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/02
///

/// 仅支持Android平台
@PlatformFlag("Android")
Future moveTaskToBack([bool nonRoot = true]) async {
  if (isAndroid) {
    FlutterMoveTaskBack.moveTaskToBack(nonRoot: nonRoot);
  }
}
