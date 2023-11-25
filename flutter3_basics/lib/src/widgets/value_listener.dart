part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/24
///

typedef ValueWidgetBuilder = Widget Function(
    BuildContext context, dynamic data);

/// 监听[Listenable]并自动重建小部件
class ValueListener<T extends Listenable> extends StatefulWidget {
  final List<T>? listenableList;
  final ValueWidgetBuilder builder;

  const ValueListener({
    super.key,
    required this.builder,
    this.listenableList,
  });

  @override
  State<ValueListener> createState() => _ValueListenerState();
}

class _ValueListenerState extends State<ValueListener> {
  void _onValueChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ValueListener<Listenable> oldWidget) {
    if (widget.listenableList != oldWidget.listenableList) {
      oldWidget.listenableList?.forEach((element) {
        element.removeListener(_onValueChanged);
      });
      widget.listenableList?.forEach((element) {
        element.addListener(_onValueChanged);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    widget.listenableList?.forEach((element) {
      element.addListener(_onValueChanged);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.listenableList?.forEach((element) {
      element.removeListener(_onValueChanged);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.listenableList);
  }
}

extension ValueListenerEx on Listenable {
  /// 监听[Listenable]并自动重建小部件
  Widget listener(WidgetBuilder builder) => ValueListener(
        listenableList: [this],
        builder: (context, value) => builder(context),
      );

  /// 监听[Listenable]并自动重建小部件, 并把[value]回调出来
  Widget listenerValue(ValueWidgetBuilder builder) => ValueListener(
        listenableList: [this],
        builder: (context, value) => builder(context, value),
      );
}

extension ValueListListenerEx on List<Listenable> {
  /// 监听[Listenable]并自动重建小部件
  Widget listener(WidgetBuilder builder) => ValueListener(
        listenableList: this,
        builder: (context, value) => builder(context),
      );

  /// 监听[Listenable]并自动重建小部件, 并把[value]回调出来
  Widget listenerValue(ValueWidgetBuilder builder) => ValueListener(
        listenableList: this,
        builder: (context, value) => builder(context, value),
      );
}
