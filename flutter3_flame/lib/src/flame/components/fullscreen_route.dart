import 'dart:async';

import '../../../flutter3_flame.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/22
///
/// 全屏路由组件
class FullscreenRoute extends Route {
  FullscreenRoute(
    super.builder, {
    super.loadingBuilder,
    super.transparent = false,
    super.maintainState = true,
  });

  @override
  FutureOr<void> onLoad() {
    final gameSize = findGame()?.size;
    if (gameSize != null) {
      size = gameSize;
    }
    return super.onLoad();
  }
}
