part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/02
///

mixin StateLogMixin<T extends StatefulWidget> on State<T> {
  @protected
  late final String logTag;

  @override
  void initState() {
    l.d('[$widget]initState:$logTag');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    l.d('[$widget]didChangeDependencies:$logTag');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    l.d('[$widget]didUpdateWidget:$logTag');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    l.d('[$widget]deactivate:$logTag');
    super.deactivate();
  }

  @override
  void dispose() {
    l.d('[$widget]dispose:$logTag');
    super.dispose();
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    l.i('[$widget]build from:$context:${context.widget}:$logTag');

    //The class doesn't have a concrete implementation of the super-invoked member 'build'.
    //return super.build(context);
    return const Placeholder();
  }
}

/// [StateLogMixin]
class StateLogWidget extends StatefulWidget {
  const StateLogWidget({super.key, required this.child, String? logTag})
      : _logTag = logTag ?? "";

  final Widget child;
  final String _logTag;

  @override
  State<StateLogWidget> createState() => _StateLogWidgetState();
}

class _StateLogWidgetState extends State<StateLogWidget> with StateLogMixin {
  @override
  String get logTag => widget._logTag;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
