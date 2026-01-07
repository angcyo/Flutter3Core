part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/07
///
/// 颜色选择的tile
/// 左[label] ... 右[color]色块.[ico]
class LabelColorPickTile extends StatefulWidget with LabelMixin {
  //MARK: - LabelMixin
  /// 标签/LabelMixin
  @override
  final String? label;
  @override
  final Widget? labelWidget;
  @override
  final TextStyle? labelTextStyle;
  @override
  final EdgeInsets? labelPadding;
  @override
  final BoxConstraints? labelConstraints;

  //MARK: - Value

  /// 强制控制尾随小部件的显示状态
  final bool? showTrailingWidget;

  /// 尾随的小部件
  final Widget? trailingWidget;

  /// 点击事件, 会覆盖默认的实现, 并自动显示箭头
  final GestureTapCallback? onTap;

  /// Wheel
  /// content
  final Color initValue;

  /// [values]改变回调, 如果有
  final ValueCallback<Color>? onValueChanged;

  //MARK: - pick

  /// 选择颜色弹窗的标题
  final Widget? pickTitleWidget;

  const LabelColorPickTile({
    super.key,
    //LabelMixin
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints = kLabelConstraints,
    //Value
    this.showTrailingWidget,
    this.onTap,
    this.trailingWidget,
    //--
    required this.initValue,
    this.onValueChanged,
    //--
    this.pickTitleWidget,
  });

  @override
  State<LabelColorPickTile> createState() => _LabelColorPickTileState();
}

class _LabelColorPickTileState extends State<LabelColorPickTile>
    with TileMixin, ValueChangeMixin<LabelColorPickTile, Color> {
  @override
  getInitialValueMixin() => widget.initValue;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final labelWidget = widget.buildLabelWidgetMixin(context);

    //是否显示箭头
    final showTrailingWidget = widget.showTrailingWidget ?? true;

    final trailingWidget =
        widget.trailingWidget ??
        (showTrailingWidget
            ? const Icon(
                Icons.navigate_next,
              ).paddingOnly(horizontal: kL).rotate(false ? 90.hd : null)
            : null);

    return [
              labelWidget,
              (widgetOf(context, currentValueMixin, tryTextWidget: false) ??
                      Empty.size(20).decoration(
                        fillDecoration(
                          color: currentValueMixin,
                          radius: kDefaultBorderRadiusL,
                        ),
                      ))
                  .align(.centerRight)
                  .expanded(),
              trailingWidget,
            ]
            .row()
            ?.min(minHeight: kMinInteractiveHeight, margin: null)
            .inkWell(
              widget.onTap ??
                  (showTrailingWidget
                      ? () async {
                          final result = await context.pickColor(
                            currentValueMixin!,
                            titleWidget: widget.pickTitleWidget,
                          );
                          if (result != null) {
                            updateValueMixin(result);
                            widget.onValueChanged?.call(result);
                          }
                        }
                      : null),
            )
            .material() ??
        empty;
  }
}
