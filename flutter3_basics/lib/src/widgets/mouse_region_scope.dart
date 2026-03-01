part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/24
///
/// 鼠标区域相关小部件
/// - 先使用[MouseHoverProvider]小部件创建一个鼠标区域状态提供者
/// - 在鼠标区域内使用[MouseHoverVisibility]控制鼠标悬停可见性

/// 鼠标区域悬停状态域
class MouseHoverScope extends InheritedWidget {
  /// 获取鼠标域内的数据
  static ValueNotifier<bool>? get(
    BuildContext? context, {
    bool depend = false,
  }) {
    if (depend) {
      return context
          ?.dependOnInheritedWidgetOfExactType<MouseHoverScope>()
          ?.hover;
    } else {
      return context?.getInheritedWidgetOfExactType<MouseHoverScope>()?.hover;
    }
  }

  /// 鼠标是否在区域内悬停
  final ValueNotifier<bool> hover;

  const MouseHoverScope({super.key, required this.hover, required super.child});

  @override
  bool updateShouldNotify(covariant MouseHoverScope oldWidget) =>
      hover.value != oldWidget.hover.value;
}

/// 鼠标区域悬停状态提供者
class MouseHoverProvider extends StatefulWidget {
  final Widget child;

  /// 鼠标样式
  final MouseCursor cursor;

  const MouseHoverProvider({
    super.key,
    required this.child,
    this.cursor = MouseCursor.defer,
  });

  @override
  State<MouseHoverProvider> createState() => _MouseHoverProviderState();
}

class _MouseHoverProviderState extends State<MouseHoverProvider> {
  final ValueNotifier<bool> hover = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return MouseHoverScope(
      hover: hover,
      child: MouseRegion(
        onEnter: (event) {
          hover.value = true;
        },
        onExit: (event) {
          hover.value = false;
        },
        cursor: widget.cursor,
        child: widget.child,
      ),
    );
  }
}

/// 悬停时可见的小部件
/// - [Visibility]
///
/// - [AnimatedOpacity]
/// - [AnimatedSwitcher]
/// - [AnimatedCrossFade]
class MouseHoverVisibility extends StatefulWidget {
  /// 悬停时显示的小部件
  final Widget child;

  /// 非悬停时显示的小部件
  final Widget? normalChild;

  /// 显示/隐藏的过渡时间
  final Duration duration;

  /// 显示/隐藏的过渡曲线
  final Curve curve;

  const MouseHoverVisibility({
    super.key,
    required this.child,
    this.normalChild,
    this.duration = kDefaultAnimationDuration,
    this.curve = Curves.linear,
  });

  @override
  State<MouseHoverVisibility> createState() => _MouseHoverVisibilityState();
}

class _MouseHoverVisibilityState extends State<MouseHoverVisibility> {
  /// 当前是否处于鼠标悬停, 悬停时可见, 非悬停时隐藏
  bool isHover = false;

  ValueNotifier<bool>? hover;

  @override
  void initState() {
    super.initState();
    hover = MouseHoverScope.get(buildContext);
    isHover = hover?.value ?? isHover;
    hover?.addListener(handleMouseHoverMixin);
  }

  @override
  void dispose() {
    hover?.removeListener(handleMouseHoverMixin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //l.d("${classHash()} build isHover:$isHover");
    final normalChild = widget.normalChild;
    if (normalChild != null) {
      return AnimatedSwitcher(
        duration: widget.duration,
        reverseDuration: widget.duration,
        switchInCurve: widget.curve,
        switchOutCurve: widget.curve,
        child: isHover ? widget.child : normalChild,
      );
    }
    return AnimatedOpacity(
      opacity: isHover ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );
  }

  @overridePoint
  void handleMouseHoverMixin() {
    final value = hover?.value ?? isHover;
    //l.i("${classHash()} handleMouseHoverMixin $value isHover:$isHover");
    if (value != isHover) {
      setState(() {
        isHover = value;
      });
    }
  }
}

extension MouseHoverScopeEx on Widget {
  /// 鼠标区域悬停状态提供者
  Widget mouseHoverProvider({
    Key? key,
    MouseCursor cursor = MouseCursor.defer,
    bool? enable,
  }) {
    return (enable ?? isMouseConnected)
        ? MouseHoverProvider(key: key, cursor: cursor, child: this)
        : this;
  }

  /// 悬停时可见的小部件
  /// - 需要在外层使用[MouseHoverProvider]
  Widget mouseHoverVisibility({
    Key? key,
    Duration duration = kDefaultAnimationDuration,
    Curve curve = Curves.linear,
    bool? enable,
    //--
    Widget? normalChild,
  }) {
    return (enable ?? isMouseConnected)
        ? MouseHoverVisibility(
            key: key,
            duration: duration,
            curve: curve,
            normalChild: normalChild,
            child: this,
          )
        : this;
  }
}
