part of '../dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24
///

class ConfirmButton extends StatelessWidget {
  /// 是否启用
  final bool enable;

  /// 强制指定小部件
  final Widget? widget;

  /// 是否使用图标, 否则使用[text]
  final bool useIcon;

  /// 对应的文本
  final String? text;

  /// 事件
  final GestureTapCallback? onTap;

  const ConfirmButton({
    super.key,
    this.enable = true,
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
                ? Icon(
                    Icons.done,
                    color: enable ? null : globalTheme.disableColor,
                  )
                : text?.text(
                    style: globalTheme.textLabelStyle.copyWith(
                      color: globalTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ))
            ?.paddingAll(kX);

    result = result
        ?.ink(
          enable
              ? () {
                  onTap?.call();
                }
              : null,
          shape: useIcon ? BoxShape.circle : BoxShape.rectangle,
        )
        .material();
    return result!;
  }
}
