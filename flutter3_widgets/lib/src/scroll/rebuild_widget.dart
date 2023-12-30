part of flutter3_widgets;

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

/// [ValueNotifier]
class UpdateValueNotifier<T> extends ValueNotifier<T> {
  UpdateValueNotifier(super.value);

  /// 更新值
  void updateValue([dynamic newValue]) {
    newValue ??= value;
    if (newValue == value) {
      notifyListeners();
    } else {
      value = newValue;
    }
  }
}

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
