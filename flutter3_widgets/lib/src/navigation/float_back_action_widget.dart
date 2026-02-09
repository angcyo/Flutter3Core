part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/09
///
/// 浮动在左上角的导航back按钮小部件
class FloatBackActionWidget extends StatefulWidget {
  /// 是否要浮动, 否则一直显示. 在桌面端默认浮动显示
  /// - 浮动时: 鼠标悬停时, 显示; 鼠标离开时, 隐藏;
  @defInjectMark
  final bool? floatStyle;

  /// 返回结果
  final Object? result;

  const FloatBackActionWidget({super.key, this.floatStyle, this.result});

  @override
  State<FloatBackActionWidget> createState() => _FloatBackActionWidgetState();
}

class _FloatBackActionWidgetState extends State<FloatBackActionWidget> {
  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    Widget body =
        globalConfig.appBarDismissalBuilder(context, widget) ??
        Icon(
          Icons.arrow_back_ios_new,
          color: globalConfig.globalTheme.icoNormalColor,
        );
    body = body
        .insets(all: kX)
        .inkWellCircle(() {
          buildContext?.maybePop(result: widget.result);
        })
        .card(shape: CircleBorder());
    final isFloatStyle = widget.floatStyle ?? isDesktopOrWeb;
    if (isFloatStyle) {
      body = body.mouseHoverVisibility().mouseHoverProvider();
    }
    return body;
  }
}

/// 扩展方法
extension FloatBackActionWidgetEx on Widget {
  Widget floatBackActionWidget({Key? key, bool? floatStyle, Object? result}) =>
      [
        this,
        FloatBackActionWidget(key: key, floatStyle: floatStyle, result: result),
      ].stack()!;
}
