import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';

export 'package:flame/flame.dart';
export 'package:flame/game.dart';
export 'package:flame/components.dart';
export 'package:flame/components.dart';
export 'package:flame/events.dart';
export 'package:flame/palette.dart';
export 'src/debug/child_counter_component.dart';
export 'src/debug/time_track_component.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/22
///

//#region sample

/// 创建一个游戏世界
Widget createGameWorld<W extends World>(W? world, {bool debugMode = false}) {
  //ChildCounterComponent();
  //TimeTrackComponent();
  return GameWidget(game: FlameGame(world: world)..debugMode = debugMode);
}

//#endregion
