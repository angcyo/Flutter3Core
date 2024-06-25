part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/12
///
/// 回退栈管理
class UndoActionManager with Diagnosticable {
  final List<UndoActionItem> undoList = [];
  final List<UndoActionItem> redoList = [];

  /// 添加一个可以撤销的操作
  /// 每次添加一个撤销操作, 都会会清空重做列表
  void add(UndoActionItem item) {
    undoList.add(item);
    redoList.clear();

    notifyChange(UndoType.normal);
  }

  /// 回退
  void undo() {
    assert(() {
      l.d('准备撤销:[${undoList.length}]');
      return true;
    }());
    if (undoList.isNotEmpty) {
      final item = undoList.removeLast();
      item.doUndo();
      redoList.add(item);

      notifyChange(UndoType.undo);
    }
  }

  /// 重做
  void redo() {
    assert(() {
      l.d('准备重做:[${redoList.length}]');
      return true;
    }());

    if (redoList.isNotEmpty) {
      final item = redoList.removeLast();
      item.doRedo();
      undoList.add(item);

      notifyChange(UndoType.redo);
    }
  }

  /// 是否可以回退
  bool canUndo() {
    return undoList.isNotEmpty;
  }

  /// 是否可以重做
  bool canRedo() {
    return redoList.isNotEmpty;
  }

  /// 添加一个可以撤销的操作, 并且立即执行
  @supportUndo
  UndoActionItem? addRunRedo([
    Action? undo,
    Action? redo,
    bool runRedo = true,
    UndoType type = UndoType.normal,
  ]) {
    final item = UndoActionItem(undo, redo);
    if (runRedo) {
      item.doRedo();
    }
    if (type == UndoType.normal) {
      add(item);
      return item;
    }
    return null;
  }

  //region ---改变通知---

  final Set<VoidCallback> _changeListeners = {};

  /// 添加回退栈改变监听
  void addChangeListener(VoidCallback listener) {
    _changeListeners.add(listener);
  }

  /// 移除回退栈改变监听
  void removeChangeListener(VoidCallback listener) {
    _changeListeners.remove(listener);
  }

  void notifyChange(UndoType fromType) {
    for (var listener in _changeListeners) {
      listener();
    }
  }

  //endregion ---改变通知---

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty("可回退数量", undoList.size()));
    properties.add(IntProperty("可恢复数量", redoList.size()));
  }
}

@immutable
class UndoActionItem {
  final Action? undo;
  final Action? redo;

  const UndoActionItem([this.undo, this.redo]);

  /// 执行回退
  /// `throw UnimplementedError();`
  @overridePoint
  void doUndo() {
    undo?.call();
  }

  /// 执行重做
  @overridePoint
  void doRedo() {
    redo?.call();
  }
}

/// 操作类型
enum UndoType {
  /// 无撤销/回调操作
  none,

  /// 普通操作, 才会被添加到回退栈
  normal,

  /// 撤销操作
  undo,

  /// 重做操作
  redo,
}

/// 表示当前的操作支持撤销/重做
/// [Target]
class _UndoAnnotation {
  final String des;

  const _UndoAnnotation([this.des = "表示当前的操作支持撤销/重做"]);
}

const supportUndo = _UndoAnnotation();
