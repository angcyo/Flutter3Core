part of '../dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24
///
/// 对话框上的确认按钮
class ConfirmButton extends StatelessWidget {
  /// 是否启用
  final bool enable;

  /// 强制指定小部件
  final Widget? widget;

  /// 是否使用图标, 否则使用[text]
  final bool useIcon;

  /// 是否使用主题颜色
  final bool? useThemeColor;

  /// 对应的文本
  final String? text;

  /// 事件
  final GestureTapCallback? onTap;

  //--

  final double radius;

  const ConfirmButton({
    super.key,
    this.enable = true,
    this.useThemeColor,
    this.useIcon = false,
    this.widget,
    this.text,
    this.onTap,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final enableColor = useThemeColor == true ? globalTheme.accentColor : null;

    Widget? result = widget?.colorFiltered(
          color: enable ? enableColor : globalTheme.disableColor,
        ) ??
        (useIcon
                ? Icon(
                    Icons.done,
                    color: enable ? enableColor : globalTheme.disableColor,
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
          radius: radius,
          shape: useIcon ? BoxShape.circle : BoxShape.rectangle,
        )
        .material();
    return result!;
  }
}
