part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/12
///
/// 分割按钮
/// [mainWidget]..[optionWidget]
///
/// - split_button: ^0.1.0
/// - split_button_m3e: ^0.2.1
class SplitButton extends StatefulWidget {
  //MARK: - main

  /// 主要的小部件
  final Widget? mainWidget;

  final GestureTapCallback? onMainTap;

  //MARK: - option

  /// 选项小部件, 默认是向下箭头
  @defInjectMark
  final Widget? optionWidget;

  /// 弹窗内容小部件
  /// - 设置之后才会显示[trailingWidget]
  /// - 弹出弹窗之后, 会自动进入选中状态
  final Widget? popupBodyWidget;

  //MARK: - part

  /// 填充的颜色, 默认样式
  @defInjectMark
  final Color? fillColor;

  /// 描边的颜色, 指定描边之后, 则优先使用描边样式
  final Color? strokeColor;

  /// 圆角大小
  final double radius;

  /// 高度
  final double height;

  /// 主轴大小
  final MainAxisSize mainAxisSize;

  const SplitButton({
    super.key,
    //MARK: - main
    this.mainWidget,
    this.onMainTap,
    //MARK: - option
    this.optionWidget,
    this.popupBodyWidget,
    //--
    this.mainAxisSize = .min,
    this.fillColor,
    this.strokeColor,
    this.height = 30,
    this.radius = 4,
  });

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> with DesktopPopupStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final optionWidget =
        widget.optionWidget ??
        Icon(Icons.arrow_drop_down, size: 16).box(width: widget.height);
    return [
      widget.mainWidget
          ?.center()
          .inkWell(
            () {},
            /*hoverColor: Colors.purpleAccent,*/
            /*highlightColor: Colors.blue,*/
            borderRadius: buildStartBorderRadius(),
          )
          .material()
          .size(height: widget.height)
          .animatedContainer(
            alignment: Alignment.center,
            decoration: buildStartFillDecoration(context, globalTheme),
          )
          .expanded(enable: widget.mainAxisSize == .max),
      optionWidget
          .center()
          .inkWell(
            () {},
            /*hoverColor: Colors.purpleAccent,*/
            /*highlightColor: Colors.blue,*/
            borderRadius: buildEndBorderRadius(),
          )
          .material()
          .size(height: widget.height)
          .animatedContainer(
            alignment: Alignment.center,
            decoration: buildEndFillDecoration(context, globalTheme),
          ),
    ].row(mainAxisSize: widget.mainAxisSize, crossAxisAlignment: .center)!;
  }

  //MARK: - decoration

  BorderRadius buildStartBorderRadius() => BorderRadius.only(
    topLeft: Radius.circular(widget.radius),
    bottomLeft: Radius.circular(widget.radius),
  );

  Decoration buildStartFillDecoration(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return BoxDecoration(
      borderRadius: buildStartBorderRadius(),
      color: widget.fillColor ?? globalTheme.accentColor,
    );
  }

  BorderRadius buildEndBorderRadius() => BorderRadius.only(
    topRight: Radius.circular(widget.radius),
    bottomRight: Radius.circular(widget.radius),
  );

  Decoration buildEndFillDecoration(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return BoxDecoration(
      borderRadius: buildEndBorderRadius(),
      color: widget.fillColor ?? globalTheme.accentColor,
    );
  }
}
