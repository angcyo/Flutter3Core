part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/24
///
/// 鼠标区域相关小部件
/// - 先使用[MouseHoverProvider]小部件创建一个鼠标区域状态提供者
///   - [MouseHoverScopeEx.mouseHoverProvider]
/// - 在鼠标区域内使用[MouseHoverVisibility]控制鼠标悬停可见性
///   - [MouseHoverScopeEx.mouseHoverVisibility]

/// 鼠标区域悬停状态域
/// - 提供鼠标悬停状态监听
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
  void reassemble() {
    hover.value = false;
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return MouseHoverScope(
      hover: hover,
      child: MouseRegion(
        onEnter: (event) {
          /*assert(() {
            l.d("鼠标进入.");
            return true;
          }());*/
          hover.value = true;
        },
        onExit: (event) {
          /*assert(() {
            l.d("鼠标离开.");
            return true;
          }());*/
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

  /// 可见性的回调
  final KeyValueCallback<bool>? onVisibilityChanged;

  /// 自定义悬停时显示的小部件
  ///
  /// ```
  /// .mouseHoverVisibility(
  ///   hoverBuilder: (widget, isHover) {
  ///     final offsetX = 30.0;
  ///     return widget.child
  ///         .animate(
  ///           key: ValueKey(nowTime()) /*小部件变化了才有动画*/,
  ///         )
  ///         .fade(
  ///           begin: isHover ? 0.0 : 1.0,
  ///           end: isHover ? 1.0 : 0.0,
  ///         )
  ///         .moveX(
  ///           begin: isHover ? offsetX : 0,
  ///           end: isHover ? 0 : offsetX,
  ///           duration: widget.duration,
  ///           curve: isHover
  ///               ? Curves.easeIn
  ///               : Curves.easeOut,
  ///         );
  ///   },
  /// )
  /// ```
  final Widget Function(MouseHoverVisibility widget, bool isHover)?
  hoverBuilder;

  const MouseHoverVisibility({
    super.key,
    required this.child,
    this.normalChild,
    this.duration = kDefaultAnimationDuration,
    this.curve = Curves.linear,
    this.onVisibilityChanged,
    this.hoverBuilder,
  });

  @override
  State<MouseHoverVisibility> createState() => _MouseHoverVisibilityState();
}

class _MouseHoverVisibilityState extends State<MouseHoverVisibility> {
  /// 当前是否处于鼠标悬停, 悬停时可见, 非悬停时隐藏
  @tempFlag
  bool _isHover = false;

  @tempFlag
  ValueNotifier<bool>? _hover;

  @override
  void initState() {
    super.initState();
    _hover = MouseHoverScope.get(buildContext);
    _isHover = _hover?.value ?? _isHover;
    widget.onVisibilityChanged?.call(widget.key, _isHover);
    _hover?.addListener(handleMouseHoverMixin);
    debugger(when: _hover == null);
  }

  @override
  void dispose() {
    _hover?.removeListener(handleMouseHoverMixin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //l.d("${classHash()} build isHover:$_isHover");
    if (widget.hoverBuilder != null) {
      return widget.hoverBuilder!(widget, _isHover);
    }

    final normalChild = widget.normalChild;
    if (normalChild != null) {
      // 悬停时显示[this], 非悬停时显示[normalChild]
      return AnimatedSwitcher(
        duration: widget.duration,
        reverseDuration: widget.duration,
        switchInCurve: widget.curve,
        switchOutCurve: widget.curve,
        child: _isHover ? widget.child : normalChild,
      );
    }
    return AnimatedOpacity(
      opacity: _isHover ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );
  }

  @overridePoint
  void handleMouseHoverMixin() {
    final value = _hover?.value ?? _isHover;
    //l.i("${classHash()} handleMouseHoverMixin $value isHover:$isHover");
    if (value != _isHover) {
      widget.onVisibilityChanged?.call(widget.key, value);
      setState(() {
        _isHover = value;
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
    return (enable ?? (isDesktopOrWeb || isMouseConnected))
        ? MouseHoverProvider(key: key, cursor: cursor, child: this)
        : this;
  }

  /// 悬停时可见的小部件
  /// - [hoverBuilder] 自定义悬停时显示的小部件
  /// - [hoverProvider] 是否启用自身的鼠标悬停状态提供者
  ///
  /// - 需要在外层使用[MouseHoverProvider]
  Widget mouseHoverVisibility({
    Key? key,
    Duration duration = kDefaultAnimationDuration,
    Curve curve = Curves.linear,
    KeyValueCallback<bool>? onVisibilityChanged,
    Widget? normalChild,
    Widget Function(MouseHoverVisibility widget, bool isHover)? hoverBuilder,
    //--
    bool? enable,
    //--
    bool? hoverProvider,
  }) {
    return (enable ?? (isDesktopOrWeb || isMouseConnected))
        ? MouseHoverVisibility(
            key: key,
            duration: duration,
            curve: curve,
            normalChild: normalChild,
            onVisibilityChanged: onVisibilityChanged,
            hoverBuilder: hoverBuilder,
            child: this,
          ).mouseHoverProvider(enable: hoverProvider == true)
        : this;
  }
}
