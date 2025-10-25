part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/25
///
/// 单纯的选项选择对话框
///
/// - 支持高亮选项
///
/// ```
/// await buildContext?.showWidgetDialog(OptionsDialog());
/// ```
///
/// @return pop 返回选中的value
class OptionsDialog extends StatefulWidget
    with DialogMixin, TitleMixin, ValueMixin {
  /// 标题/TitleMixin
  @override
  final String? title;
  @override
  final Widget? titleWidget;
  @override
  final TextStyle? titleTextStyle;
  @override
  final TextAlign? titleTextAlign;
  @override
  final EdgeInsets? titlePadding;
  @override
  final BoxConstraints? titleConstraints;

  /// 值/ValueMixin
  @override
  final dynamic initValue;
  @override
  final List? values;
  @override
  final List<Widget>? valuesWidget;
  @override
  final TransformDataWidgetBuilder? transformValueWidget;
  @override
  final ValueChanged<dynamic>? onValueChanged;

  const OptionsDialog({
    super.key,
    //TitleMixin
    this.title,
    this.titleWidget,
    this.titleTextStyle,
    this.titleTextAlign,
    this.titlePadding,
    this.titleConstraints,
    //ValueMixin
    this.initValue,
    this.values,
    this.valuesWidget,
    this.transformValueWidget,
    this.onValueChanged,
  });

  @override
  State<OptionsDialog> createState() => _OptionsDialogState();
}

class _OptionsDialogState extends State<OptionsDialog>
    with ValueChangeMixin<OptionsDialog, int> {
  /// 走索引数据处理模式
  @override
  int getInitialValueMixin() => widget.valueIndexMixin;

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final globalTheme = globalConfig.globalTheme;
    final lRes = libRes(context);

    // 高亮的颜色
    final highlightColor = globalTheme.accentColor;

    //构建[values]对应的小部件
    //debugger();
    WidgetList? children = widget.buildValuesWidgetListMixin(
      context,
      transformValueWidget:
          widget.transformValueWidget ??
          (ctx, child, index, data) {
            //debugger();
            return [
                  (isSelectedValueMixin(index)
                          ? Icon(Icons.navigate_next)
                          : empty)
                      .size(size: 30),
                  child,
                ]
                .row()!
                .paddingOnly(vertical: kL)
                .colorFiltered(
                  color: isSelectedValueMixin(index) ? highlightColor : null,
                )
                .inkWell(() {
                  changeValueMixin(indexOfValuesMixin(data));
                }, enable: !isSelectedValueMixin(index));
          },
      textAlign: TextAlign.start,
    );

    final title = CoreDialogTitle(
      title: widget.title,
      titleWidget: widget.titleWidget,
      invisibleLeading: true,
      invisibleTrailing: true,
      enableLine: false,
      trailingUseThemeColor: true,
      useCloseIcon: false,
      onPop: () {
        final value = widget.values?.getOrNull(currentValueMixin!);
        widget.onValueChanged?.call(value);
        return value;
      },
    );

    final control = [
      GradientButton(
        radius: kMaxBorderRadius,
        color: globalTheme.borderColor,
        child: lRes?.libCancel.text(
          textColor: globalTheme.textGeneralStyle.color,
        ),
        onTap: () {
          buildContext?.popDialog();
        },
      ).expanded(),
      GradientButton(
        enable: isValueSelectedMixin,
        radius: kMaxBorderRadius,
        onTap: () {
          final value = widget.values?.getOrNull(currentValueMixin!);
          widget.onValueChanged?.call(value);
          buildContext?.popDialog(value);
        },
        child: lRes?.libConfirm.text(),
      ).expanded(),
    ].row(gap: kX)?.paddingOnly(all: kX);

    if (globalConfig.isInTabletLandscapeModel) {
      return widget.buildCenterDialog(
        context,
        [
          title,
          children?.column(gapWidget: hLine(context)) ??
              globalConfig.emptyPlaceholderBuilder(context, null),
          control,
        ].column()!.desktopConstrained(),
      );
    }

    return widget.buildBottomChildrenDialog(
      context,
      [
        title,
        children?.column(gapWidget: hLine(context)) ??
            globalConfig.emptyPlaceholderBuilder(context, null),
      ],
      bottomWidget: control,
      clipTopRadius: kDefaultBorderRadiusXXX,
    );
  }
}
