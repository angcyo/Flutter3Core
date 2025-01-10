part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 在菜单路由中, 点击过后, 自动弹出菜单, 并且不影响child的事件响应
class PopMenuWidget extends StatefulWidget {
  final Widget child;
  final Object? result;
  final bool rootNavigator;

  const PopMenuWidget(
    this.child, {
    super.key,
    this.result,
    this.rootNavigator = false,
  });

  @override
  State<PopMenuWidget> createState() => _PopMenuWidgetState();
}

class _PopMenuWidgetState extends State<PopMenuWidget> {
  late final TapGestureRecognizer tapRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    tapRecognizer.onTap = () {
      //debugger();
      context.popMenu(widget.result, widget.rootNavigator, false);
    };
    super.initState();
  }

  @override
  void dispose() {
    tapRecognizer.dispose();
    super.dispose();
  }

  /// [GestureDetector]
  /// [RenderProxyBoxWithHitTestBehavior]
  ///
  /// [RawGestureDetector]
  @override
  Widget build(BuildContext context) {
    /*return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
    //点击后, 自动弹出菜单
    debugger();
    context.popMenu(result, rootNavigator, false);
    },
    child: child,
    );*/
    return Listener(
      onPointerDown: (event) {
        tapRecognizer.addPointer(event);
        tapRecognizer.acceptGesture(event.pointer);
        tapRecognizer.handleEvent(event);
      },
      onPointerUp: (event) {
        //debugger();
        tapRecognizer.handleEvent(event);
      },
      onPointerCancel: (event) {
        debugger();
        tapRecognizer.handleEvent(event);
      },
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}

extension PopMenuWidgetEx on Widget {
  /// [PopMenuWidget]
  Widget popMenu({
    Object? result,
    bool rootNavigator = false,
  }) {
    return PopMenuWidget(
      this,
      result: result,
      rootNavigator: rootNavigator,
    );
  }
}
