import 'dart:async';

import '../../../flutter3_flame.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 精灵动画状态混入
/// - 不同的状态, 不同的动画
mixin SpriteAnimationComponentStateMixin on SpriteAnimationComponent {
  String? _currentState;

  /// 当前状态
  String? get currentState => _currentState;

  set currentState(String? state) {
    if (_currentState != state) {
      _currentState = state;
      animation = spriteState[_currentState];
    }
  }

  /// 精灵动画状态
  Map<String, SpriteAnimation> spriteState = {};

  /// 切换到下一个状态
  void nextState() {
    if (currentState == null) {
      currentState = spriteState.keys.firstOrNull;
      return;
    }
    if (spriteState.isNotEmpty) {
      final keys = spriteState.keys.toList();
      final index = keys.indexOf(currentState!);
      if (index != -1) {
        if (index == keys.length - 1) {
          currentState = keys.firstOrNull;
        } else {
          final nextIndex = (index + 1) % keys.length;
          currentState = keys[nextIndex];
        }
      }
    }
  }

  @override
  FutureOr<void> onLoad() {
    _currentState ??= spriteState.keys.firstOrNull;
    animation = spriteState[_currentState];
    return super.onLoad();
  }
}

/// 精灵状态混入
/// - 不同的状态, 不同的精灵
mixin SpriteComponentStateMixin on SpriteComponent {
  String? _currentState;

  /// 当前状态
  String? get currentState => _currentState;

  set currentState(String? state) {
    if (_currentState != state) {
      _currentState = state;
      sprite = spriteState[_currentState];
    }
  }

  /// 精灵动画状态
  Map<String, Sprite> spriteState = {};

  /// 切换到下一个状态
  void nextState() {
    if (currentState == null) {
      currentState = spriteState.keys.firstOrNull;
      return;
    }
    if (spriteState.isNotEmpty) {
      final keys = spriteState.keys.toList();
      final index = keys.indexOf(currentState!);
      if (index != -1) {
        if (index == keys.length - 1) {
          currentState = keys.firstOrNull;
        } else {
          final nextIndex = (index + 1) % keys.length;
          currentState = keys[nextIndex];
        }
      }
    }
  }

  @override
  FutureOr<void> onLoad() {
    _currentState ??= spriteState.keys.firstOrNull;
    sprite = spriteState[_currentState];
    return super.onLoad();
  }
}
