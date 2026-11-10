///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 游戏阶段控制器
abstract class BasePhaseController<T extends BaseGamePhase> {
  T? _currentPhase;

  T? get currentPhase => _currentPhase;

  bool get isInitialized => _currentPhase != null;

  /// 切换阶段
  void changePhase(T nextPhase) {
    if (_currentPhase == nextPhase) {
      return;
    }
    final prevPhase = _currentPhase;
    // 退出旧阶段
    _currentPhase?.onExit(nextPhase);
    // 更新当前阶段
    _currentPhase = nextPhase;
    // 进入新阶段
    _currentPhase?.onEnter(prevPhase);
  }

  /// 更新当前阶段
  void update(double dt) {
    _currentPhase?.update(dt);
  }

  /// 暂停当前阶段
  void pause() {
    _currentPhase?.onPause();
  }

  /// 恢复当前阶段
  void resume() {
    _currentPhase?.onResume();
  }

  /// 清理阶段
  void clear() {
    _currentPhase?.onExit(null);
    _currentPhase = null;
  }
}

/// 游戏阶段
abstract class BaseGamePhase {
  /// 阶段名称
  String get name;

  /// 进入阶段
  void onEnter(BaseGamePhase? prevPhase) {}

  /// 离开阶段
  void onExit(BaseGamePhase? nextPhase) {}

  /// 阶段更新
  void update(double dt) {}

  /// 暂停
  void onPause() {}

  /// 恢复
  void onResume() {}
}
