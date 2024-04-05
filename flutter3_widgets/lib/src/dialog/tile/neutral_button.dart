part of '../dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/05
///

class NeutralButton extends StatelessWidget {
  /// 强制指定小部件
  final Widget? widget;

  /// 是否使用图标, 否则使用[text]
  final bool useIcon;

  /// 对应的文本
  final String? text;

  /// 事件
  final GestureTapCallback? onTap;

  const NeutralButton({
    super.key,
    this.useIcon = false,
    this.widget,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    Widget? result = widget ??
        (useIcon
                ? const Icon(Icons.near_me)
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
