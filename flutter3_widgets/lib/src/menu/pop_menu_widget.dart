part of 'menu_mix.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/10
///
/// 在菜单路由中, 点击过后, 自动弹出菜单, 并且不影响child的事件响应
class PopMenuWidget extends StatefulWidget {
  final bool enable;

  //--
  final Widget child;
  final Object? result;
  final bool rootNavigator;

  const PopMenuWidget(
    this.child, {
    super.key,
    this.enable = true,
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
      if (widget.enable) {
        context.popMenu(
          result: widget.result,
          rootNavigator: widget.rootNavigator,
        );
      }
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
        if (tapRecognizer.state != GestureRecognizerState.ready) {
          tapRecognizer.handleEvent(event);
        }
      },
      onPointerCancel: (event) {
        //debugger();
        if (tapRecognizer.state != GestureRecognizerState.ready) {
          tapRecognizer.handleEvent(event);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}

extension PopMenuWidgetEx on Widget {
  /// 菜单样式item
  Widget menuStyleItem({
    //--
    double? all,
    double? vertical,
    double? horizontal,
    double left = kX,
    double top = kH,
    double right = kX,
    double bottom = kH,
    //--
    double? minWidth = kMenuMinWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
  }) =>
      paddingOnly(
        all: all,
        vertical: vertical,
        horizontal: horizontal,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ).constrainedMin(
        minWidth: minWidth,
        minHeight: minHeight,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

  /// [PopMenuWidget]
  Widget popMenu({
    //--
    bool enable = true,
    //--
    Object? result,
    bool rootNavigator = false,
  }) {
    return PopMenuWidget(
      this,
      enable: enable,
      result: result,
      rootNavigator: rootNavigator,
    );
  }
}
