import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/05
///
/// - [BaseFlameGame]
/// - [BaseFlameWorld]
abstract class BaseFlameGame<W extends World> extends FlameGame<W> {
  BaseFlameGame({super.children, super.world, super.camera});

  /// 加载游戏时的大小
  @fb.tempFlag
  final Vector2 _loadedGameSize = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    //camera.viewfinder.anchor = .topLeft;
    if (hasLayout) {
      if (_loadedGameSize != canvasSize) {
        onReloadGame(canvasSize);
      }
    }
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_loadedGameSize != canvasSize) {
      onReloadGame(size);
    }
  }

  /// 重新加载游戏
  @fb.overridePoint
  void onReloadGame(Vector2 size) {
    _loadedGameSize.setFrom(size);
    /*clearGameChildren();*/
    assert(() {
      fb.l.i("[${classHash()}]加载游戏大小->$size");
      return true;
    }());
  }
}
