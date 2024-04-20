part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/30
///

/// 用来触发重构的Widget, 配合[RItemTile], 实现[findTile].[updateTile]功能
class RebuildWidget extends StatefulWidget {
  /// 用来触发重构的信号
  final ValueNotifier updateSignal;
  final DataWidgetBuilder builder;

  const RebuildWidget({
    super.key,
    required this.updateSignal,
    required this.builder,
  });

  @override
  State<RebuildWidget> createState() => RebuildWidgetState();
}

class RebuildWidgetState extends State<RebuildWidget> {
  @override
  void initState() {
    widget.updateSignal.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() {
    //debugger();
    widget.updateSignal.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.updateSignal.value);
  }

  @override
  void didUpdateWidget(covariant RebuildWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    //debugger();
    oldWidget.updateSignal.removeListener(_rebuild);
    widget.updateSignal.removeListener(_rebuild);
    widget.updateSignal.addListener(_rebuild);
  }

  void _rebuild() {
    //debugger();
    updateState();
  }
}

/// 用来触发重构的信号, 不管值相同与否, 都会触发通知
/// [ValueNotifier]
class UpdateValueNotifier<T> extends ValueNotifier<T> {
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

  /// 更新值
  @api
  void updateValue([dynamic newValue]) {
    newValue ??= value;
    if (newValue == value) {
      notifyListeners();
    } else {
      value = newValue;
    }
  }
}

/// [UpdateValueNotifier]的快速构建方法
get nullValueUpdateSignal => UpdateValueNotifier<dynamic>(null);

mixin RebuildStateEx<T extends StatefulWidget> on State<T> {
  /// 用来触发重构的信号
  late final List<Listenable> listenableList = [];

  /// 用来触发重构的信号
  @callPoint
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
    for (var element in listenableList) {
      element.removeListener(requestRebuild);
    }
    listenableList.clear();
    super.dispose();
  }

  /// 重构界面
  @overridePoint
  void requestRebuild() {
    updateState();
  }
}

/// 当[updateSignal]改变时, 自动触发重构
/// [ValueNotifier]
/// [UpdateValueNotifier]
@dsl
Widget rebuild(
  ValueNotifier updateSignal,
  DataWidgetBuilder builder,
) {
  return RebuildWidget(
    updateSignal: updateSignal,
    builder: builder,
  );
}
