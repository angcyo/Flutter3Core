import 'dart:async';

import 'package:flutter3_basics/flutter3_basics.dart' as fb;
import 'package:flutter3_flame/flutter3_flame.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/05
///
/// - [BaseFlameGame]
/// - [BaseFlameWorld]
abstract class BaseFlameWorld extends World {
  BaseFlameWorld({super.children, super.priority = -0x7fffffff, super.key});

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
    _loadedWorldSize.setFrom(size);
    assert(() {
      fb.l.i("[${classHash()}]加载世界大小->$size");
      return true;
    }());
    //销毁之前的所有实体
    destroyAllChildren();
  }

  /// 销毁之前的所有实体
  @fb.api
  void destroyAllChildren() {
    //removeAllChildren();
  }

  //--

  /// 重新加载世界
  @fb.api
  void reloadWorld() {
    if (_loadedWorldSize.length > 0) {
      onReloadWorld(_loadedWorldSize);
    }
  }
}
