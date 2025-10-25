part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///
/// 开关tile
/// [text]     ...[Switch]
class SwitchTile extends StatefulWidget {
  /// 文本
  final String? text;
  final TextStyle? textStyle;
  final EdgeInsets? textPadding;
  final Widget? textWidget;

  //--

  /// 开关
  final bool value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<bool>? onValueChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  final FutureValueCallback<bool>? onValueConfirmChange;

  /// [Switch]的高度
  final double switchHeight;

  /// [Switch]未激活时圆圈的颜色
  final Color? switchInactiveThumbColor;

  /// [Switch]的轮廓颜色
  final WidgetStateProperty<Color?>? trackOutlineColor;

  //

  /// tile的填充
  final EdgeInsets? tilePadding;

  //--

  /// 布局方向
  final Axis axis;

  const SwitchTile({
    super.key,
    //--
    this.text,
    this.textStyle,
    this.textWidget,
    this.textPadding = const EdgeInsets.only(right: kH),
    //--
    this.value = false,
    this.onValueChanged,
    this.onValueConfirmChange,
    this.switchHeight = kMinHeight,
    this.switchInactiveThumbColor,
    this.trackOutlineColor,
    //--
    this.tilePadding = kTilePadding,
    //--
    this.axis = Axis.horizontal,
  });

  @override
  State<SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<SwitchTile>
    with TileMixin, ValueChangeMixin<SwitchTile, bool> {
  @override
  bool getInitialValueMixin() => widget.value;

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.axis == Axis.vertical;
    // build text
    Widget? text = buildTextWidget(
      context,
      textWidget: widget.textWidget,
      text: widget.text,
      textAlign: isVertical ? TextAlign.center : null,
      textStyle: widget.textStyle,
      textPadding: isVertical ? null : widget.textPadding,
      constraints: null,
    );

    if (isVertical) {
      return [
            text,
            buildSwitchWidget(
              context,
              currentValueMixin!,
              height: widget.switchHeight,
              inactiveThumbColor: widget.switchInactiveThumbColor,
              trackOutlineColor: widget.trackOutlineColor,
              onChanged: (value) {
                _changeValue(value);
              },
            ),
          ]
          .column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          )!
          .ink(() {
            //debugger();
            _changeValue(!currentValueMixin!);
          })
          .material();
    }

    return [
          text?.expanded(),
          buildSwitchWidget(
            context,
            currentValueMixin!,
            height: widget.switchHeight,
            inactiveThumbColor: widget.switchInactiveThumbColor,
            trackOutlineColor: widget.trackOutlineColor,
            onChanged: (value) {
              _changeValue(value);
            },
          ),
        ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding)
        .ink(() {
          //debugger();
          _changeValue(!currentValueMixin!);
        })
        .material();
  }

  void _changeValue(bool toValue) async {
    if (widget.onValueConfirmChange != null) {
      final result = await widget.onValueConfirmChange!(toValue);
      if (result != true) {
        return;
      }
    }
    currentValueMixin = toValue;
    widget.onValueChanged?.call(toValue);
    updateState();
  }
}

/// [label].[actions]     ...[Switch]
/// [des]                 ...
///
/// [CheckboxTile]
/// [LabelSwitchTile]
class LabelSwitchTile extends StatefulWidget {
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

  /// 开关
  final bool value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<bool>? onValueChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  final FutureValueCallback<bool>? onValueConfirmChange;

  /// [Switch]的高度
  final double switchHeight;

  /// [Switch]未激活时圆圈的颜色
  final Color? switchInactiveThumbColor;

  /// [Switch]的轮廓颜色
  final WidgetStateProperty<Color?>? trackOutlineColor;

  //

  /// tile的填充
  final EdgeInsets? tilePadding;

  const LabelSwitchTile({
    super.key,
    //--
    this.label,
    this.labelTextStyle,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.labelActions,
    this.des,
    this.desWidget,
    this.desPadding = kDesPadding,
    //--
    this.value = false,
    this.onValueChanged,
    this.onValueConfirmChange,
    this.switchHeight = kMinHeight,
    this.switchInactiveThumbColor,
    this.trackOutlineColor,
    //--
    this.tilePadding = kTilePadding,
  });

  @override
  State<LabelSwitchTile> createState() => _LabelSwitchTileState();
}

class _LabelSwitchTileState extends State<LabelSwitchTile>
    with TileMixin, ValueChangeMixin<LabelSwitchTile, bool> {
  @override
  bool getInitialValueMixin() => widget.value;

  @override
  Widget build(BuildContext context) {
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
      label = [label, ...?widget.labelActions].row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
      );
    }
    return [
          [
            label,
            buildDesWidget(
              context,
              desWidget: widget.desWidget,
              des: widget.des,
              desPadding: widget.desPadding,
            ),
          ].column(crossAxisAlignment: CrossAxisAlignment.start)?.expanded(),
          buildSwitchWidget(
            context,
            currentValueMixin!,
            height: widget.switchHeight,
            inactiveThumbColor: widget.switchInactiveThumbColor,
            trackOutlineColor: widget.trackOutlineColor,
            onChanged: (value) {
              _changeValue(value);
            },
          ),
        ]
        .row(crossAxisAlignment: CrossAxisAlignment.center)!
        .paddingInsets(widget.tilePadding)
        .ink(() {
          //debugger();
          _changeValue(!currentValueMixin!);
        }, splashColor: Colors.transparent)
        .material();
  }

  void _changeValue(bool toValue) async {
    if (widget.onValueConfirmChange != null) {
      final result = await widget.onValueConfirmChange!(toValue);
      if (result != true) {
        return;
      }
    }
    currentValueMixin = toValue;
    widget.onValueChanged?.call(toValue);
    updateState();
  }
}
