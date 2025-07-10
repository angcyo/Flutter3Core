part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/10
///
/// 数字输入tile
/// 上[label]     右[number].[value].(支持键盘输入)
/// 下[des]
/// [LabelNumberSliderTile]
class LabelNumberTile extends StatefulWidget {
  /// 标签
  final String? label;
  final TextStyle? labelTextStyle;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// 标签右边的小部件
  final WidgetNullList? labelActions;

  /// 描述
  final String? des;
  final EdgeInsets? desPadding;
  final Widget? desWidget;

  //--

  /// 数值
  /// value
  final num value;
  final num? minValue;
  final num? maxValue;
  final int maxDigits;
  final NumType? _numType;

  /// 并不需要在此方法中更新界面
  final ValueChanged<num>? onValueChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  final FutureValueCallback<num>? onConfirmChange;

  /// tile的填充
  /// [GlobalTheme.tilePadding]
  @defInjectMark
  final EdgeInsets? tilePadding;

  //--

  /// 点击数字小部件时的回调
  final GestureTapCallback? onNumberTap;

  const LabelNumberTile({
    super.key,
    this.label,
    this.labelTextStyle,
    this.labelWidget,
    this.labelPadding,
    this.labelActions,
    this.des,
    this.desWidget,
    this.desPadding = kDesPadding,
    this.value = 0,
    this.minValue,
    this.maxValue,
    this.maxDigits = 2,
    this.onValueChanged,
    this.onConfirmChange,
    this.tilePadding,
    this.onNumberTap,
    NumType? numType,
  }) : _numType = numType ?? (value is int ? NumType.i : NumType.d);

  @override
  State<LabelNumberTile> createState() => _LabelNumberTileState();
}

class _LabelNumberTileState extends State<LabelNumberTile> with TileMixin {
  num _initialValue = 0;
  num _currentValue = 0;

  @override
  void initState() {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberTile oldWidget) {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    // build label
    Widget? label = buildLabelWidget(
      context,
      labelWidget: widget.labelWidget,
      label: widget.label,
      labelStyle: widget.labelTextStyle,
      labelPadding: widget.labelPadding,
      constraints: null,
    );
    if (label != null && !isNil(widget.labelActions)) {
      label = [
        label,
        ...?widget.labelActions,
      ].row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center);
    }

    final numberStr = formatNumber(
      _currentValue,
      numType: widget._numType,
      digits: widget.maxDigits,
    );
    final number = isDesktopOrWeb
        ? buildNumberInputWidget(context, numberStr,
            minValue: widget.minValue,
            maxValue: widget.maxValue,
            maxDigits: widget.maxDigits,
            numType: widget._numType, onChanged: (value) {
            if (value != null) {
              _currentValue = value;
              widget.onValueChanged?.call(_currentValue);
              updateState();
            }
          })
        : buildNumberWidget(context, numberStr,
            onTap: widget.onNumberTap ??
                () async {
                  final value = await context.showWidgetDialog(
                    NumberKeyboardDialog(
                      number: _currentValue,
                      minValue: widget.minValue,
                      maxValue: widget.maxValue,
                      maxDigits: widget.maxDigits,
                      numType: widget._numType,
                    ),
                    maintainBottomViewPadding: true,
                  );
                  if (value != null) {
                    _changeValue(value);
                  }
                });
    return [
      [
        label,
        buildDesWidget(
          context,
          desWidget: widget.desWidget,
          des: widget.des,
          desPadding: widget.desPadding,
        )
      ].column(crossAxisAlignment: CrossAxisAlignment.start)?.expanded(),
      number,
    ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding ?? globalTheme.tilePadding)
        .material();
  }

  void _changeValue(num toValue) async {
    if (widget.onConfirmChange != null) {
      final result = await widget.onConfirmChange!(toValue);
      if (result is bool && result != true) {
        return;
      }
    }
    _currentValue = toValue;
    widget.onValueChanged?.call(toValue);
    updateState();
  }
}

/// 步长/增量数字输入小部件
/// 左[label] 右[-].[number].[+]增量输入
class SingleIncrementNumberWidget extends StatefulWidget
    with LabelMixin, NumberMixin {
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

  /// 数字/NumberMixin
  @override
  final int numberMaxDigits;
  @override
  final num? numberMaxValue;
  @override
  final num? numberMinValue;
  @override
  final num numberValue;
  @override
  final NumType? numberValueType;
  @override
  final ValueChanged<num>? onNumberValueChanged;
  @override
  final FutureValueCallback<num>? onNumberValueConfirmChange;

  //--

  final double numberMinWidth;

  const SingleIncrementNumberWidget({
    super.key,
    //LabelMixin
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints = kLabelConstraints,
    //NumberMixin
    this.numberValue = 0,
    this.numberMinValue,
    this.numberMaxValue,
    this.numberMaxDigits = 2,
    this.numberValueType,
    this.onNumberValueChanged,
    this.onNumberValueConfirmChange,
    //
    this.numberMinWidth = 88,
  });

  @override
  State<SingleIncrementNumberWidget> createState() =>
      _SingleIncrementNumberWidgetState();
}

class _SingleIncrementNumberWidgetState
    extends State<SingleIncrementNumberWidget> with NumberStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //label
    Widget? label = widget.buildLabelWidgetMixin(context);

    //num
    //debugger();
    Widget? numberLayout = [
      buildIncrementStepWidget(
        context,
        step: -1,
        stepText: "-",
        enable: greaterThan(currentNumberValue, widget.numberMinValue,
                than: false) &&
            lessThan(widget.numberMinValue, widget.numberMaxValue, than: false),
      ),
      currentNumberValueText
          .text(
            textAlign: TextAlign.center,
            style: globalTheme.textGeneralStyle,
          )
          .constrainedMin(minWidth: widget.numberMinWidth)
          .click(() async {
        final value = await context.showWidgetDialog(NumberKeyboardDialog(
          number: currentNumberValue,
          minValue: widget.numberMinValue,
          maxValue: widget.numberMaxValue,
          maxDigits: widget.numberMaxDigits,
          numType: widget.numberValueTypeMixin,
        ));
        if (value != null) {
          onNumberValueChanged(value);
        }
      }),
      buildIncrementStepWidget(
        context,
        step: 1,
        stepText: "+",
        enable:
            lessThan(currentNumberValue, widget.numberMaxValue, than: false) &&
                greaterThan(widget.numberMaxValue, widget.numberMinValue,
                    than: false),
      ),
    ].row();

    return [
      label,
      numberLayout
          ?.container(
            color: globalTheme.itemWhiteBgColor,
            padding: const EdgeInsets.all(kM),
            radius: kDefaultBorderRadiusX,
          )
          .wrapContentWidth()
          .paddingSymmetric(horizontal: kX, vertical: kL)
          .align(Alignment.centerRight)
          .expanded()
    ].row()!;
  }
}
