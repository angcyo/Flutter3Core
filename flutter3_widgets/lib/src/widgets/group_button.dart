part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/12
///
/// 分割按钮
/// [child]..[optionWidget]
///
/// - split_button: ^0.1.0
/// - split_button_m3e: ^0.2.1
class SplitButton extends StatefulWidget {
  //MARK: - main

  /// 主要的小部件
  final Widget? child;

  final GestureTapCallback? onTap;

  //MARK: - option

  /// 选项小部件, 默认是向下箭头
  @defInjectMark
  final Widget? optionWidget;

  /// 指定箭头的颜色
  final Color? optionColor;

  /// 弹窗内容小部件
  /// - 设置之后才会显示[trailingWidget]
  /// - 弹出弹窗之后, 会自动进入选中状态
  final Widget? popupBodyWidget;

  /// 弹窗对齐锚点的位置
  final Alignment? popupAlignment;

  //MARK: - part

  /// 填充的颜色, 默认样式
  @defInjectMark
  final Color? fillColor;

  /// 描边的颜色, 指定描边之后, 则优先使用描边样式
  final Color? strokeColor;

  /// 描边的宽度
  final double strokeWidth;

  /// 圆角大小
  final double radius;

  /// 高度
  final double height;

  /// 主轴大小
  final MainAxisSize mainAxisSize;

  const SplitButton({
    super.key,
    //MARK: - main
    this.child,
    this.onTap,
    //MARK: - option
    this.optionWidget,
    this.optionColor,
    this.popupBodyWidget,
    this.popupAlignment,
    //--
    this.mainAxisSize = .min,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth = 1,
    this.height = 30,
    this.radius = 4,
  });

  @override
  State<SplitButton> createState() => _SplitButtonState();
}

class _SplitButtonState extends State<SplitButton> with DesktopPopupStateMixin {
  /// 显示选项按钮
  bool get showOptionWidget => widget.popupBodyWidget != null;

  bool get isStrokeStyle => widget.strokeColor != null;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final optionWidget = !showOptionWidget
        ? null
        : (widget.optionWidget ??
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: widget.optionColor,
              ).box(width: widget.height));
    return [
      widget.child
          ?.center()
          .inkWell(
            widget.onTap,
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
          ?.animatedRotation(isShowPopupMixin ? 180 : 0)
          .center()
          .inkWell(
            showOptionWidget
                ? () {
                    showPopup(context);
                  }
                : null,
            /*hoverColor: Colors.purpleAccent,*/
            /*highlightColor: Colors.blue,*/
            borderRadius: buildEndBorderRadius(),
          )
          .material()
          .localLocation(
            key: ValueKey("option"),
            locationNotifier: locationNotifierMixin,
          )
          .size(height: widget.height)
          .animatedContainer(
            alignment: Alignment.center,
            decoration: buildEndFillDecoration(context, globalTheme),
          ),
    ].row(mainAxisSize: widget.mainAxisSize, crossAxisAlignment: .center)!;
  }

  //MARK: - decoration

  /// 圆角
  BorderRadius buildStartBorderRadius() => BorderRadius.only(
    topLeft: Radius.circular(widget.radius),
    bottomLeft: Radius.circular(widget.radius),
    topRight: showOptionWidget ? Radius.zero : Radius.circular(widget.radius),
    bottomRight: showOptionWidget
        ? Radius.zero
        : Radius.circular(widget.radius),
  );

  /// 边框
  BorderSide buildStartBorderSide() => BorderSide(
    color: widget.strokeColor ?? Colors.transparent,
    width: widget.strokeWidth,
  );

  /// 主要的按钮装饰
  Decoration buildStartFillDecoration(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return BoxDecoration(
      borderRadius: buildStartBorderRadius(),
      border: widget.strokeColor != null
          ? Border(
              top: buildStartBorderSide(),
              left: buildStartBorderSide(),
              bottom: buildStartBorderSide(),
              right: buildStartBorderSide(),
            )
          : null,
      color: widget.strokeColor != null
          ? null
          : widget.fillColor ?? globalTheme.accentColor,
    );
  }

  BorderRadius buildEndBorderRadius() => BorderRadius.only(
    topRight: Radius.circular(widget.radius),
    bottomRight: Radius.circular(widget.radius),
  );

  /// 结束按钮的装饰
  Decoration buildEndFillDecoration(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return BoxDecoration(
      borderRadius: buildEndBorderRadius(),
      border: widget.strokeColor != null
          ? Border(
              top: buildStartBorderSide(),
              right: buildStartBorderSide(),
              bottom: buildStartBorderSide(),
            )
          : null,
      color: widget.strokeColor != null
          ? null
          : widget.fillColor ?? globalTheme.accentColor,
    );
  }

  /// 显示弹窗
  @api
  void showPopup(BuildContext? context) {
    final popupBodyWidget = widget.popupBodyWidget;
    if (popupBodyWidget != null) {
      wrapShowPopupMixin(() async {
        await context?.showPopupDialog(
          popupBodyWidget,
          alignment: widget.popupAlignment ?? Alignment.topCenter,
        );
      });
    }
  }
}
