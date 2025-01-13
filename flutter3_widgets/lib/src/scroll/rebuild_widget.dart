part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/30
///

/// 用来触发重构的Widget, 配合[RItemTile], 实现[findTile].[updateTile]功能
/// [AnimatedWidget]
/// [ListenableBuilder]
///
/// [ValueNotifier]
/// [UpdateValueNotifier]
/// [ValueListenableBuilder]
class RebuildWidget extends StatefulWidget {
  /// 用来触发重构的信号
  final Listenable? updateSignal;
  final Iterable<Listenable>? updateSignalList;
  final DynamicDataWidgetBuilder builder;

  const RebuildWidget({
    super.key,
    this.updateSignal,
    this.updateSignalList,
    required this.builder,
  });

  @override
  State<RebuildWidget> createState() => RebuildWidgetState();
}

class RebuildWidgetState extends State<RebuildWidget> {
  @override
  void initState() {
    widget.updateSignal?.addListener(_rebuild);
    widget.updateSignalList?.forEach((element) {
      element.addListener(_rebuild);
    });
    super.initState();
  }

  @override
  void dispose() {
    //debugger();
    widget.updateSignal?.removeListener(_rebuild);
    widget.updateSignalList?.forEach((element) {
      element.removeListener(_rebuild);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
            context,
            widget.updateSignal?.value ??
                widget.updateSignalList?.map((element) => element.value)) ??
        empty;
  }

  @override
  void didUpdateWidget(covariant RebuildWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    //debugger();
    oldWidget.updateSignal?.removeListener(_rebuild);
    widget.updateSignalList?.forEach((element) {
      element.removeListener(_rebuild);
    });

    widget.updateSignal?.removeListener(_rebuild);
    widget.updateSignal?.addListener(_rebuild);
    widget.updateSignalList?.forEach((element) {
      element.removeListener(_rebuild);
      element.addListener(_rebuild);
    });
  }

  void _rebuild() {
    //debugger();
    updateState();
  }
}

/// 用来触发重构的信号, 不管值相同与否, 都会触发通知
/// [ValueNotifier]↓
/// [UpdateValueNotifier]↓
/// [UpdateSignalNotifier]↓
///
@updateSignalMark
class UpdateValueNotifier<T> extends ValueNotifier<T> with NotifierMixin {
  /// 附加的额外数据
  /// [ValueNotifier.value] 才是真正的值
  dynamic data;

  UpdateValueNotifier(super.value, [this.data]);

  /// 获取数据, 并清空
  dynamic get dataOnce {
    final data = this.data;
    this.data = null;
    return data;
  }

  /// 获取数据
  @override
  T get value => super.value;

  /// 调用此方法, 当[value]不变时, 不会触发通知
  @override
  set value(T newValue) {
    super.value = newValue;
  }

  /// 更新值, 不管值相同与否, 都会触发通知
  @api
  void updateValue([dynamic newValue]) {
    newValue ??= value;
    if (newValue == value) {
      notifyListeners();
    } else {
      value = newValue;
    }
  }

  /// 直接通知改变回调
  @api
  void notify() {
    notifyListeners();
  }

  @api
  void update() => notify();

  /// 销毁
  @override
  void dispose() {
    super.dispose();
  }
}

/// 换个名字
class UpdateSignalNotifier<T> extends UpdateValueNotifier<T> {
  UpdateSignalNotifier(super.value, [super.data]);
}

/// [UpdateValueNotifier]的快速构建方法
@updateSignalMark
UpdateSignalNotifier<dynamic> get nullValueUpdateSignal =>
    UpdateSignalNotifier<dynamic>(null);

/// [UpdateValueNotifier]的快速构建方法
@updateSignalMark
UpdateSignalNotifier<T?> createUpdateSignal<T>() =>
    UpdateSignalNotifier<T?>(null);

@updateSignalMark
UpdateSignalNotifier<T?> $signal<T>([T? value]) =>
    UpdateSignalNotifier<T?>(value);

mixin RebuildStateEx<T extends StatefulWidget> on State<T> {
  /// 用来触发重构的信号
  late final List<Listenable> listenableList = [];

  /// 用来触发重构的信号
  @api
  @callPoint
  @autoDispose
  void hookRebuild(Listenable? value) {
    if (value == null) {
      return;
    }
    listenableList.remove(value);
    listenableList.add(value);
    value.removeListener(requestRebuild);
    value.addListener(requestRebuild);
  }

  @override
  void dispose() {
    for (final element in listenableList) {
      element.removeListener(requestRebuild);
    }
    listenableList.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// 重构界面
  @overridePoint
  void requestRebuild() {
    updateState();
  }
}

//--

/// [AnimatedWidget]
/// [ListenableBuilder]
extension RebuildEx<T> on ValueNotifier<T> {
  /// [rebuild]
  Widget build(DynamicDataWidgetBuilder builder) => rebuild(this, builder);

  /// [rebuild]
  Widget buildFn(Widget? Function() builder) =>
      rebuild(this, (_, __) => builder());
}

/// [AnimatedWidget]
/// [ListenableBuilder]
extension RebuildIterableEx<T extends Listenable> on Iterable<T> {
  /// [rebuildList]
  Widget build(DynamicDataWidgetBuilder builder) => rebuildList(this, builder);

  /// [rebuildList]
  Widget buildFn(Widget? Function() builder) =>
      rebuildList(this, (_, __) => builder());
}

extension RebuildFunctionEx on Function {
  /// 更新
  /// ```
  /// (){}.rebuild(signal);
  /// ```
  Widget rebuild(
    @updateSignalMark ValueNotifier updateSignal, {
    bool enable = true,
  }) {
    return enable ? rebuildSingle(updateSignal, () => this()) : this();
  }
}

//--

/// 当[updateSignal]改变时, 自动触发重构
/// [ValueNotifier]
/// [UpdateValueNotifier]
@dsl
Widget rebuild(
  @updateSignalMark ValueNotifier updateSignal,
  DynamicDataWidgetBuilder builder,
) {
  return RebuildWidget(
    updateSignal: updateSignal,
    builder: builder,
  );
}

/// [Iterable<dynamic>]
@dsl
Widget rebuildList(
  @updateSignalMark Iterable<Listenable> updateSignalList,
  DynamicDataWidgetBuilder builder,
) {
  return RebuildWidget(
    updateSignalList: updateSignalList,
    builder: builder,
  );
}

/// 简单的[rebuild]
@dsl
Widget rebuildSingle(
  @updateSignalMark ValueNotifier updateSignal,
  Widget Function() action,
) =>
    rebuild(updateSignal, (context, value) => action());

//--
