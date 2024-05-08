import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/08
///

void main() {
  LiveStreamController controller = LiveStreamController(100, autoClearValue: true);
  controller.listen((data) => consoleLog(data));
  controller.listen((data) => consoleLog(data), allowBackward: false);

  controller.add(2);

  consoleLog('...end');
}
