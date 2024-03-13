part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/12
///
/// 回退栈管理
class UndoManager {
  final List<UndoItem> undoList = [];
  final List<UndoItem> redoList = [];

  /// 添加一个可以撤销的操作
  /// 每次添加一个撤销操作, 都会会清空重做列表
  void add(UndoItem item) {
    undoList.add(item);
    redoList.clear();

    notifyChange();
  }

  /// 回退
  void undo() {
    if (undoList.isNotEmpty) {
      final item = undoList.removeLast();
      item.doUndo();
      redoList.add(item);

      notifyChange();
    }
  }

  /// 重做
  void redo() {
    if (redoList.isNotEmpty) {
      final item = redoList.removeLast();
      item.doRedo();
      undoList.add(item);

      notifyChange();
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
  UndoItem? addRunRedo([
    Action? undo,
    Action? redo,
    bool runRedo = true,
    UndoType type = UndoType.normal,
  ]) {
    final item = UndoItem(undo, redo);
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

  void notifyChange() {
    for (var listener in _changeListeners) {
      listener();
    }
  }

//endregion ---改变通知---
}

@immutable
class UndoItem {
  final Action? undo;
  final Action? redo;

  const UndoItem([this.undo, this.redo]);

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
  none,

  /// 普通操作, 才会被添加到回退栈
  normal,
  undo,
  redo,
}

/// 表示当前的操作支持撤销/重做
class _SupportUndo {
  final String des;

  const _SupportUndo([this.des = "表示当前的操作支持撤销/重做"]);
}

const supportUndo = _SupportUndo();
