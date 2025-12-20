part of flutter3_widgets;

/// https://github.com/flutterchina/flukit
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///
/// [AutomaticKeepAlive] 保持小部件的状态
/// [AutomaticKeepAliveClientMixin] 混入保活客户端
/// [KeepAliveNotification] 通知上层保活事件
///

/// KeepAliveWrapper can keep the item(s) of scrollview alive, **Not dispose**.
class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });

  final bool keepAlive;
  final Widget child;

  @override
  KeepAliveWrapperState createState() => KeepAliveWrapperState();
}

class KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    //print("KeepAliveWrapper dispose");
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

extension KeepAliveWrapperExtension on Widget {
  /// 自动保活
  KeepAliveWrapper keepAlive({bool keepAlive = true}) {
    return KeepAliveWrapper(keepAlive: keepAlive, child: this);
  }
}
