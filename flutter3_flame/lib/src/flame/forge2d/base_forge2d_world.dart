import 'dart:async';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/28
///
///  - [BaseForge2DGame]
///  - [BaseForge2DWorld]
abstract class BaseForge2DWorld extends Forge2DWorld {
  BaseForge2DWorld({
    super.gravity,
    super.definition,
    super.contactEventsDispatcher,
    super.children,
  });

  /// 加载世界时的大小
  @fb.tempFlag
  final Vector2 _loadedWorldSize = Vector2.zero();

  ///
  @override
  FutureOr<void> onLoad() {
    final canvasSize = findGame()?.canvasSize;
    if (canvasSize != null && _loadedWorldSize != canvasSize) {
      onReloadWorld(canvasSize);
    }
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_loadedWorldSize != size) {
      onReloadWorld(size);
    }
  }

  /// 重新加载世界
  @fb.overridePoint
  void onReloadWorld(Vector2 size) {
    assert(() {
      fb.l.d("[${classHash()}]加载世界大小->$size");
      return true;
    }());
    _loadedWorldSize.setFrom(size);
    //销毁之前的所有刚体
    destroyAllBodies();
  }

  /// 销毁之前的所有刚体
  @fb.api
  void destroyAllBodies() {
    for (final body in bodies.toList(growable: false)) {
      destroyBody(body);
    }
  }
}
