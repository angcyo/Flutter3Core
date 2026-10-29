import 'package:flame/components.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/forge2d_viewfinder.dart';
import 'package:flutter3_basics/flutter3_basics.dart' as fb;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/28
///
///  - [BaseForge2DGame]
///  - [BaseForge2DWorld]
abstract class BaseForge2DGame extends Forge2DGame {
  BaseForge2DGame({
    super.world,
    super.camera,
    super.gravity,
    super.contactEventsDispatcher,
    super.metersToPixels = Forge2DViewfinder.defaultMetersToPixels, //100
    super.lengthUnitsPerMeter,
  });

  @override
  Future<void> onLoad() {
    //camera.viewfinder.anchor = .topLeft;
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isMounted) {
      onReloadGame(size);
    }
  }

  /// 重新加载游戏
  @fb.overridePoint
  void onReloadGame(Vector2 size) {
    /*clearGameChildren();
    //添加游戏墙体
    addBoundariesWall(
      this,
      */ /*marginLeft: visibleWorldRect.width * config.launchAreaRatio,*/ /*
    );
    add(ThrowBallHudComponent());*/
  }
}
