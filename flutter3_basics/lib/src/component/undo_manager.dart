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
  FutureOr<bool> undo() async {
    assert(() {
      l.d('准备撤销,共[${undoList.length}]/${redoList.length}');
      return true;
    }());
    if (undoList.isNotEmpty) {
      final item = undoList.removeLast();
      final result = await item.doUndo();
      redoList.add(item);

      notifyChanged(UndoType.undo);
      return result;
    }
    return false;
  }

  /// 重做
  /// @return 是否执行成功
  @api
  FutureOr<bool> redo() async {
    assert(() {
      l.d('准备重做,共[${redoList.length}]/${undoList.length}');
      return true;
    }());

    if (redoList.isNotEmpty) {
      final item = redoList.removeLast();
      final result = await item.doRedo();
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
  /// - [runRedo] 是否立即执行重做
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
  final FutureOrAction? undo;
  final FutureOrAction? redo;

  const UndoActionItem([this.undo, this.redo]);

  /// 执行回退
  /// `throw UnimplementedError();`
  @overridePoint
  FutureOr<bool> doUndo() async {
    final result = await undo?.call();
    if (result is bool) {
      return result;
    }
    return true;
  }

  /// 执行重做
  @overridePoint
  FutureOr<bool> doRedo() async {
    final result = await redo?.call();
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

//--

///
/// ```
///   @override
///   final UndoActionManager undoActionManager;
///   @override
///   final Widget? undoWidget;
///   @override
///   final Widget? redoWidget;
///   @override
///   final VisualDensity? visualDensity;
/// ```
///
/// [UndoStateMixin]
mixin UndoWidgetMixin {
  UndoActionManager? get undoActionManager => null;

  //--

  Widget? get undoWidget => null;

  Widget? get redoWidget => null;

  //--

  VisualDensity? get visualDensity => null;

  Color? get enableColor => null;

  Color? get disableColor => null;
}

/// [UndoWidgetMixin]
mixin UndoStateMixin<T extends StatefulWidget> on State<T> {
  UndoActionManager? get undoManagerMixin => widget is UndoWidgetMixin
      ? (widget as UndoWidgetMixin).undoActionManager
      : null;

  Widget? get undoWidgetMixin =>
      widget is UndoWidgetMixin ? (widget as UndoWidgetMixin).undoWidget : null;

  Widget? get redoWidgetMixin =>
      widget is UndoWidgetMixin ? (widget as UndoWidgetMixin).redoWidget : null;

  VisualDensity? get visualDensityMixin => widget is UndoWidgetMixin
      ? (widget as UndoWidgetMixin).visualDensity
      : null;

  Color? get enableColorMixin => widget is UndoWidgetMixin
      ? (widget as UndoWidgetMixin).enableColor
      : null;

  Color? get disableColorMixin => widget is UndoWidgetMixin
      ? (widget as UndoWidgetMixin).disableColor
      : null;

  //--

  @override
  void initState() {
    undoManagerMixin?.addChangeListener(handleUndoActionChangeMixin);
    super.initState();
  }

  @override
  void dispose() {
    undoManagerMixin?.removeChangeListener(handleUndoActionChangeMixin);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    //undoManagerMixin?.removeChangeListener(handleUndoActionChangeMixin);
    //undoManagerMixin?.addChangeListener(handleUndoActionChangeMixin);
  }

  @override
  Widget build(BuildContext context) {
    return [
          buildUndoWidgetMixin(context),
          buildRedoWidgetMixin(context),
        ].row(mainAxisSize: MainAxisSize.min) ??
        empty;
  }

  //--

  /// 激活时小部件着色的颜色
  @overridePoint
  Color? getEnableColorMixin(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return enableColorMixin ??
        context.darkOr(globalTheme.icoNormalColor, globalTheme.icoNormalColor);
  }

  /// 非激活时小部件着色的颜色
  @overridePoint
  Color? getDisableColorMixin(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return disableColorMixin ??
        context.darkOr(globalTheme.disableColor, globalTheme.icoDisableColor);
  }

  /// 构建撤销回退小部件
  Widget? buildUndoWidgetMixin(
    BuildContext context, {
    Widget? undoWidget,
    Color? enableColor,
    Color? disableColor,
    VisualDensity? visualDensity,
  }) {
    final canUndo = undoManagerMixin?.canUndo() == true;
    Widget undo = IconButton(
      visualDensity: visualDensity ?? visualDensityMixin,
      onPressed: canUndo
          ? () {
              undoManagerMixin?.undo();
            }
          : null,
      icon: undoWidget ?? undoWidgetMixin ?? const Icon(Icons.undo),
    );
    if (isDebug) {
      undo = undo.stackOf(
        Text(
          "${undoManagerMixin?.undoList.length ?? 0}",
          style: const TextStyle(fontSize: 9),
        ),
        alignment: AlignmentDirectional.center,
      );
    }
    if (canUndo) {
      undo = undo.colorFiltered(
        color: enableColor ?? getEnableColorMixin(context),
      );
    } else {
      undo = undo.colorFiltered(
        color: disableColor ?? getDisableColorMixin(context),
      );
    }
    return undo;
  }

  /// 构建重做小部件
  Widget? buildRedoWidgetMixin(
    BuildContext context, {
    Widget? redoWidget,
    Color? enableColor,
    Color? disableColor,
    VisualDensity? visualDensity,
  }) {
    final canRedo = undoManagerMixin?.canRedo() == true;
    Widget redo = IconButton(
      visualDensity: visualDensity ?? visualDensityMixin,
      onPressed: canRedo
          ? () {
              undoManagerMixin?.redo();
            }
          : null,
      icon: redoWidget ?? redoWidgetMixin ?? const Icon(Icons.redo),
    );
    if (isDebug) {
      redo = redo.stackOf(
        Text(
          "${undoManagerMixin?.redoList.length ?? 0}",
          style: const TextStyle(fontSize: 9),
        ),
        alignment: AlignmentDirectional.center,
      );
    }

    if (canRedo) {
      redo = redo.colorFiltered(
        color: enableColor ?? getEnableColorMixin(context),
      );
    } else {
      redo = redo.colorFiltered(
        color: disableColor ?? getDisableColorMixin(context),
      );
    }
    return redo;
  }

  //--

  /// 改变监听, 默认会调用[updateState]
  @overridePoint
  void handleUndoActionChangeMixin() {
    updateState();
  }
}

//--

/// 撤销回退小部件
/// [UndoActionManager]
class UndoActionWidget extends StatefulWidget with UndoWidgetMixin {
  @override
  final UndoActionManager? undoActionManager;
  @override
  final Widget? undoWidget;
  @override
  final Widget? redoWidget;

  const UndoActionWidget(
    this.undoActionManager, {
    super.key,
    this.undoWidget,
    this.redoWidget,
  });

  @override
  State<UndoActionWidget> createState() => _UndoActionWidgetState();
}

class _UndoActionWidgetState extends State<UndoActionWidget>
    with UndoStateMixin {
  ///
  @override
  void didUpdateWidget(covariant UndoActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
