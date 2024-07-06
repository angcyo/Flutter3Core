part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/30
///
mixin NumberMixin {
  /// 数值
  /// value
  num get numberValue;

  num? get numberMinValue;

  num? get numberMaxValue;

  /// 如果是小数, 则小数点应该保留多少位
  int get numberMaxDigits;

  /// [numberValue] 数字的类型, 小数还是整数
  NumType? get numberValueType;

  /// 并不需要在此方法中更新界面
  ValueChanged<num>? get onNumberValueChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  FutureValueCallback<num>? get onNumberValueConfirmChange;

  /// 数字的类型
  NumType get numberValueTypeMixin =>
      numberValueType ?? (numberValue is int ? NumType.i : NumType.d);
}

/// 数字状态的混入
/// [NumberMixin]
mixin NumberStateMixin<T extends StatefulWidget> on State<T> {
  NumberMixin get numberMixin => widget as NumberMixin;

  /// 当前数字对应的文本
  String get currentNumberValueText => formatNumber(
        currentNumberValue,
        numType: numberMixin.numberValueTypeMixin,
        digits: numberMixin.numberMaxDigits,
      );

  /// 数值是否发生了改变
  bool get isNumberValueChanged => initialNumberValue != currentNumberValue;

  num initialNumberValue = 0;
  num currentNumberValue = 0;

  @override
  void initState() {
    initialNumberValue = numberMixin.numberValue;
    currentNumberValue = initialNumberValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    initialNumberValue = numberMixin.numberValue;
    currentNumberValue = initialNumberValue;
    super.didUpdateWidget(oldWidget);
  }

  /// 数字改变回调
  void onNumberValueChanged(num toValue) async {
    toValue =
        clamp(toValue, numberMixin.numberMinValue, numberMixin.numberMaxValue);
    if (numberMixin.onNumberValueConfirmChange != null) {
      final result = await numberMixin.onNumberValueConfirmChange!(toValue);
      if (result is bool && result != true) {
        return;
      }
    }
    if (numberMixin.numberValueTypeMixin == NumType.i) {
      toValue = toValue.round();
    }
    currentNumberValue = toValue;
    numberMixin.onNumberValueChanged?.call(toValue);
    updateState();
  }

  /// 构建递减小部件
  /// [step] 步长, 默认-1
  /// [longStep] 长按时的补偿, 默认[step]*10
  Widget buildIncrementStepWidget(
    BuildContext context, {
    String? stepText,
    double width = 36,
    double height = 28,
    double fontSize = 18,
    required double step,
    double? longStep,
    bool enable = true,
  }) {
    //debugger();
    final globalTheme = GlobalTheme.of(context);
    return stepText
            ?.text(
              fontSize: fontSize,
              textAlign: ui.TextAlign.center,
              style: globalTheme.textGeneralStyle.copyWith(
                  color: enable ? null : globalTheme.disableTextColor),
            )
            .stateDecoration(
              enable
                  ? fillDecoration(
                      color: globalTheme.whiteColor,
                      borderRadius: kDefaultBorderRadiusL,
                    )
                  : fillDecoration(
                      color: globalTheme.whiteColor.withOpacity(0.9),
                      borderRadius: kDefaultBorderRadiusL,
                    ),
              pressedDecoration: fillDecoration(
                color: Colors.black12,
                borderRadius: kDefaultBorderRadiusL,
              ),
              enablePressedDecoration: enable,
            )
            .onTouchDetector(
              onClick: (_) {
                //debugger();
                final toValue = currentNumberValue + step;
                onNumberValueChanged(toValue);
              },
              onLongPress: (_) {
                debugger();
                final toValue = currentNumberValue + (longStep ?? step * 10);
                onNumberValueChanged(toValue);
              },
              enableClick: enable,
              enableLongPress: enable,
              enableLoopLongPress: enable,
            )
            .size(width: width, height: height) ??
        empty;
  }
}
