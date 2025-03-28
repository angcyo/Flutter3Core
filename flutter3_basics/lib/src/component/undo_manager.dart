part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/12
///
/// 回退栈管理
/// [UndoActionWidget]
class UndoActionManager with Diagnosticable {
  /// 撤销栈
  List<UndoActionItem> undoList = [];
  List<UndoActionItem> redoList = [];

  /// 是否操作过, 回退列表不为空, 则表示操作过
  bool get isChanged => undoList.isNotEmpty;

  /// 添加一个可以撤销的操作
  /// 每次添加一个撤销操作, 都会会清空重做列表
  void add(UndoActionItem item) {
    undoList.add(item);
    redoList.clear();

    notifyChanged(UndoType.normal);
  }

  /// 回退
  /// @return 是否执行成功
  @api
  bool undo() {
    assert(() {
      l.d('准备撤销,共[${undoList.length}]/${redoList.length}');
      return true;
    }());
    if (undoList.isNotEmpty) {
      final item = undoList.removeLast();
      final result = item.doUndo();
      redoList.add(item);

      notifyChanged(UndoType.undo);
      return result;
    }
    return false;
  }

  /// 重做
  /// @return 是否执行成功
  @api
  bool redo() {
    assert(() {
      l.d('准备重做,共[${redoList.length}]/${undoList.length}');
      return true;
    }());

    if (redoList.isNotEmpty) {
      final item = redoList.removeLast();
      final result = item.doRedo();
      undoList.add(item);

      notifyChanged(UndoType.redo);
      return result;
    }
    return false;
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

  /// 销毁
  void dispose() {
    undoList.clear();
    redoList.clear();
    _changeListeners.clear();
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

  void notifyChanged(UndoType fromType) {
    for (final listener in _changeListeners) {
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
  /// 核心撤销回退回调
  final ResultDynamicAction? undo;
  final ResultDynamicAction? redo;

  const UndoActionItem([
    this.undo,
    this.redo,
  ]);

  /// 执行回退
  /// `throw UnimplementedError();`
  @overridePoint
  bool doUndo() {
    final result = undo?.call();
    if (result is bool) {
      return result;
    }
    return true;
  }

  /// 执行重做
  @overridePoint
  bool doRedo() {
    final result = redo?.call();
    if (result is bool) {
      return result;
    }
    return true;
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

  /// 重置操作, 在切换画布时触发
  reset;

  /// 是否是撤销/重做操作
  bool get isUndoRedo => this == UndoType.undo || this == UndoType.redo;
}

/// 表示当前的操作支持撤销/重做
/// [Target]
class _UndoAnnotation {
  final String des;

  const _UndoAnnotation([this.des = "表示当前的操作支持撤销/重做"]);
}

const supportUndo = _UndoAnnotation();

/// 撤销回退小部件
/// [UndoActionManager]
class UndoActionWidget extends StatefulWidget {
  final UndoActionManager undoActionManager;
  final Widget? undoWidget;
  final Widget? redoWidget;

  const UndoActionWidget(this.undoActionManager, {
    super.key,
    this.undoWidget,
    this.redoWidget,
  });

  @override
  State<UndoActionWidget> createState() => _UndoActionWidgetState();
}

class _UndoActionWidgetState extends State<UndoActionWidget> {
  UndoActionManager get undoManager => widget.undoActionManager;

  @override
  void initState() {
    widget.undoActionManager.addChangeListener(_handleUndoActionChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.undoActionManager.removeChangeListener(_handleUndoActionChange);
    super.dispose();
  }

  ///
  @override
  void didUpdateWidget(covariant UndoActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final enableColor =
    context.darkOr(globalTheme.icoNormalColor, globalTheme.icoNormalColor);
    final disableColor =
    context.darkOr(globalTheme.disableColor, globalTheme.icoDisableColor);

    //撤销
    final canUndo = undoManager.canUndo();
    Widget undo = IconButton(
        onPressed: canUndo
            ? () {
          undoManager.undo();
        }
            : null,
        icon: widget.undoWidget ?? const Icon(Icons.undo));
    if (isDebug) {
      undo = undo.stackOf(
        Text(
          "${undoManager.undoList.length}",
          style: const TextStyle(fontSize: 9),
        ),
        alignment: AlignmentDirectional.center,
      );
    }
    if (canUndo) {
      undo = undo.colorFiltered(color: enableColor);
    } else {
      undo = undo.colorFiltered(color: disableColor);
    }

    //重做
    final canRedo = undoManager.canRedo();
    Widget redo = IconButton(
        onPressed: canRedo
            ? () {
          undoManager.redo();
        }
            : null,
        icon: widget.redoWidget ?? const Icon(Icons.redo));
    if (isDebug) {
      redo = redo.stackOf(
        Text(
          "${undoManager.redoList.length}",
          style: const TextStyle(fontSize: 9),
        ),
        alignment: AlignmentDirectional.center,
      );
    }

    if (canRedo) {
      redo = redo.colorFiltered(color: enableColor);
    } else {
      redo = redo.colorFiltered(color: disableColor);
    }

    return [
      undo,
      redo,
    ].row(mainAxisSize: MainAxisSize.min) ??
        empty;
  }

  void _handleUndoActionChange() {
    updateState();
  }
}
