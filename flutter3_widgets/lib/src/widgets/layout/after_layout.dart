part of '../../../flutter3_widgets.dart';

/// https://github.com/flutterchina/flukit
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/05
///

/// [RenderBox.size]
typedef AfterLayoutCallback =
    void Function(BuildContext parentContext, RenderBox childRenderBox);

/// 在小部件布局完成之后第一时间触发回调
class AfterLayout extends SingleChildRenderObjectWidget {
  /// child布局之后的回调
  /// 在此回调中不能直接调用setState(), 否则会导致循环调用.
  /// `addPostFrameCallback`
  ///
  /// This might be because setState() was called from a layout or paint callback.
  /// If a change is needed to the widget tree, it should be applied as the tree is being built.
  /// Scheduling a change for the subsequent frame instead results in an interface that lags behind by one frame.
  /// If this was done to make your build dependent on a size measured at layout time, consider using a LayoutBuilder,
  /// CustomSingleChildLayout, or CustomMultiChildLayout.
  /// If, on the other hand, the one frame delay is the desired effect,
  /// for example because this is an animation,
  /// consider scheduling the frame in a post-frame callback using SchedulerBinding.addPostFrameCallback or using an AnimationController to trigger the animation.
  final AfterLayoutCallback? afterLayoutAction;
  final AfterLayoutCallback? postAfterLayoutAction;

  const AfterLayout({
    super.key,
    super.child,
    this.afterLayoutAction,
    this.postAfterLayoutAction,
  });

  @override
  AfterLayoutRenderObject createRenderObject(BuildContext context) =>
      AfterLayoutRenderObject(
        afterLayoutAction: afterLayoutAction,
        postAfterLayoutAction: postAfterLayoutAction,
        context: context,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    AfterLayoutRenderObject renderObject,
  ) {
    renderObject
      ..afterLayoutAction = afterLayoutAction
      ..postAfterLayoutAction = postAfterLayoutAction
      ..context = context;
  }
}

class AfterLayoutRenderObject extends RenderProxyBox {
  AfterLayoutCallback? afterLayoutAction;
  AfterLayoutCallback? postAfterLayoutAction;
  BuildContext context;

  AfterLayoutRenderObject({
    this.afterLayoutAction,
    this.postAfterLayoutAction,
    required this.context,
  });

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    //debugger();
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    //debugger();
    super.performLayout();
    afterLayoutAction?.call(context, this);
    if (postAfterLayoutAction != null) {
      postFrameCallback((timeStamp) {
        postAfterLayoutAction?.call(context, this);
      });
    }
  }
}

/// https://github.com/javaherisaber/widget_size
/// A widget to calculate it's size after being built and attached to a widget tree
/// [onChange] get changed [Size] of the Widget
/// [child] Widget to get size of it at runtime
class WidgetPostSize extends StatefulWidget {
  final Widget child;
  final Function(Size) onChange;

  const WidgetPostSize({Key? key, required this.onChange, required this.child})
    : super(key: key);

  @override
  _WidgetPostSizeState createState() => _WidgetPostSizeState();
}

class _WidgetPostSizeState extends State<WidgetPostSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(key: widgetKey, child: widget.child);
  }

  var widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    /*await Future.delayed(
        const Duration(milliseconds: 16)); // wait till the widget is drawn*/
    if (!mounted || context == null) return; // not yet attached to layout

    var newSize = context.size;
    if (oldSize == newSize || newSize == null) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
