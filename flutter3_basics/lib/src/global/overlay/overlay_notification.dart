part of flutter3_basics;

///
/// 通知基础小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/13
///

/*class _NotificationWrapWidget extends StatelessWidget {
  const _NotificationWrapWidget({super.key});

  /// 滑动删除的执行对象
  final GlobalKey<_OverlayAnimatedState> overlayAnimatedStateKey;

  /// 是否要支持滑动, 支持的滑动方向
  final DismissDirection? slideDismissDirection;

  /// 内容
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}*/

class ToastWidget extends StatelessWidget {
  final Widget child;

  /// 背景颜色
  final Color? background;

  /// 阴影高度
  final double? elevation;

  const ToastWidget({
    super.key,
    required this.child,
    this.background,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    final isLight = background?.isLight ?? false;
    final textColor = isLight
        ? (GlobalConfig.def.themeData.textTheme.titleSmall?.color ??
            Colors.black87)
        : Colors.white;
    //添加背景
    result = Container(
      color: background ?? Colors.black.withAlpha(180),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: result,
    );
    //添加圆角
    result = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: result,
    );
    if (elevation != null) {
      result = result.elevation(
        elevation!,
      );
    }
    //添加屏幕内边距
    result = Padding(
      padding: const EdgeInsets.all(16),
      child: result,
    );
    //添加主题样式
    result = DefaultTextStyle(
      style: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      child: IconTheme(
        data: IconThemeData(color: textColor),
        child: result,
      ),
    );

    //添加安全区域
    result = SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: platformMediaQuery().viewInsets.bottom +
                kMinInteractiveDimension),
        child: result,
      ),
    );
    //忽略手势
    result = IgnorePointer(child: result);
    return result;
  }
}

/// 可以左右滑动删除的小部件
class _SlideDismissible extends StatelessWidget {
  final Widget child;

  final DismissDirection direction;

  final GlobalKey<_OverlayAnimatedState> overlayAnimatedStateKey;

  const _SlideDismissible({
    Key? key,
    required this.child,
    DismissDirection? direction,
    required this.overlayAnimatedStateKey,
  })  : direction = direction ?? DismissDirection.none,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: direction,
      onDismissed: (direction) {
        overlayAnimatedStateKey.currentState?.dismiss(animate: false);
      },
      child: child,
    );
  }
}
