part of '../../../flutter3_basics.dart';

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

class ToastWidget extends StatefulWidget {
  /// 小部件
  final Widget? child;

  /// 背景颜色
  /// `#333333`
  @defInjectMark
  final Color? background;

  /// 背景模糊的伽马值
  final double? bgBlurSigma;

  /// 阴影高度
  final double? elevation;

  /// 整体的内边距, 距离屏幕的内边距
  final EdgeInsetsGeometry? margin;

  /// 内容内边距
  final EdgeInsetsGeometry? padding;

  /// 动态构建停止
  final LoadingValueNotifier? loadingInfoNotifier;

  const ToastWidget({
    super.key,
    this.child,
    this.background,
    this.bgBlurSigma,
    this.elevation,
    this.padding = const EdgeInsets.symmetric(horizontal: kXh, vertical: kX),
    this.margin = const EdgeInsets.all(kXh),
    this.loadingInfoNotifier,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> {
  @override
  Widget build(BuildContext context) {
    final loadingInfoNotifier = widget.loadingInfoNotifier;
    Widget result = loadingInfoNotifier == null
        ? widget.child ?? empty
        : ValueListenableBuilder(
            valueListenable: loadingInfoNotifier,
            builder: (context, value, child) {
              return value?.builder?.call(context) ?? child ?? empty;
            },
            child: widget.child,
          );
    final isLight = widget.background?.isLight ?? false;
    final textColor = isLight
        ? (GlobalConfig.def.globalThemeData?.textTheme.titleSmall?.color ??
            Colors.black87)
        : context.isThemeDark
            ? GlobalConfig.def.globalTheme.whiteColor
            : GlobalConfig.def.globalTheme.themeWhiteColor;
    //添加背景
    //debugger();
    result = Container(
      color: widget.background ?? "#333333".toColor().withOpacity(0.6),
      padding: widget.padding,
      child: result,
    )
        .constrainedMax(maxWidth: math.min(screenWidth, screenHeight))
        .blur(sigma: widget.bgBlurSigma);
    //添加圆角
    result = ClipRRect(
      borderRadius: BorderRadius.circular(kDefaultBorderRadiusXX),
      child: result,
    );
    if (widget.elevation != null) {
      result = result.elevation(
        widget.elevation!,
      );
    }
    //添加屏幕内边距
    result = Padding(
      padding: widget.margin ?? EdgeInsets.zero,
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
            bottom: platformMediaQueryData.viewInsets.bottom +
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

  final GlobalKey<OverlayAnimatedState> overlayAnimatedStateKey;

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
