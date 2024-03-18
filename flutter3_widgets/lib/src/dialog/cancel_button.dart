part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24
///

class CancelButton extends StatelessWidget {
  /// 是否使用图标
  final bool useIcon;

  /// 强制指定小部件
  final Widget? widget;

  /// 对应的文本
  final String? text;

  /// 事件
  final GestureTapCallback? onTap;

  const CancelButton({
    super.key,
    this.useIcon = false,
    this.widget,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    Widget? result = widget ??
        (useIcon
                ? const Icon(Icons.close)
                : text?.text(
                    style: globalTheme.textLabelStyle,
                    textAlign: TextAlign.center,
                  ))
            ?.paddingAll(kX);

    result = result?.ink(onTap: () {
      onTap?.call();
    }).material();
    return result!;
  }
}
