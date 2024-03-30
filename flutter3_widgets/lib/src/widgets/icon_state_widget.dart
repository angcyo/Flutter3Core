part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/16
///
/// 支持图标/文本/tip显示的小部件
/// 同时还支持按下时的状态装饰显示和选中时的状态装饰显示
///
class IconStateWidget extends StatelessWidget {
  //---

  /// 图标
  final Widget? icon;

  /// 文本
  final Widget? text;

  /// 提示信息, 请使用[Positioned]定位
  final Widget? tip;

  //---

  /// 是否启用
  final bool enable;

  /// 正常颜色
  final Color? color;

  /// 禁用的颜色
  final Color? disableColor;

  final EdgeInsetsGeometry? padding;

  /// 点击事件
  final GestureTapCallback? onTap;

  /// 长按提示文本
  final String? tooltip;

  //---

  /// 一直显示的背景装饰
  final Decoration? decoration;

  /// 按下时的背景装饰
  final Decoration? pressedDecoration;

  /// 选中时的背景装饰
  final Decoration? selectedDecoration;

  const IconStateWidget({
    super.key,
    this.icon,
    this.text,
    this.tip,
    this.tooltip,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    this.decoration,
    this.pressedDecoration,
    this.selectedDecoration,
    this.enable = true,
    this.color,
    this.disableColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StateDecorationWidget(
      decoration: decoration,
      pressedDecoration: pressedDecoration,
      enablePressedDecoration: enable,
      selectedDecoration: selectedDecoration,
      child: [
        icon,
        text,
      ]
          .column()!
          .paddingInsets(padding)
          .colorFiltered(
            color: enable ? color : disableColor,
            blendMode: BlendMode.srcIn,
          )
          //.click(onTap, enable)
          .stackOf(
            tip,
            alignment: AlignmentDirectional.center,
          )
          .onTouchDetector(onTap: onTap, enableClick: enable),
    ).tooltip(tooltip);
  }
}
