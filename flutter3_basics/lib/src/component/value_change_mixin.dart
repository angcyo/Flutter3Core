part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/01
///
/// 在[State]中, 保持监听[Widget]中的初始化值和当前值
/// 并计算当前值和初始化是否发生了改变
/// 并保持只刷新自身的情况下保持ui
mixin ValueChangeMixin<T extends StatefulWidget, V> on State<T> {
  /// 初始化的值
  late V initialValueMixin;

  /// 当前的值
  late V currentValueMixin;

  /// 是否发生了改变
  bool get isValueChangedMixin => initialValueMixin != currentValueMixin;

  @override
  void initState() {
    updateInitialValueMixin();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    updateInitialValueMixin();
    super.didUpdateWidget(oldWidget);
  }

  /// 重写此方法, 初始化[initialValueMixin].[currentValueMixin]
  @overridePoint
  void updateInitialValueMixin() {
    try {
      initialValueMixin = getInitialValueMixin();
      currentValueMixin = initialValueMixin;
    } catch (e) {
      assert(() {
        print(e);
        return true;
      }());
    }
  }

  /// 重写此方法, 获取初始化的[initialValueMixin].值
  @initialize
  @overridePoint
  V getInitialValueMixin() {
    final widget = this.widget;
    if (widget is ValueMixin) {
      final mixin = widget as ValueMixin;
      return mixin.initValue;
    }
    return null as dynamic;
  }

  //--
  @api
  void updateValueMixin(dynamic toValue) async => changeValueMixin(toValue);

  /// 改变[currentValueMixin]的值
  @api
  void changeValueMixin(dynamic toValue) async {
    final widget = this.widget;
    if (widget is ValueMixin) {
      final mixin = widget as ValueMixin;
      if (mixin.onValueConfirmChange != null) {
        final result = await mixin.onValueConfirmChange!(toValue);
        if (result != true) {
          return;
        }
      }
      currentValueMixin = toValue;
      mixin.onValueChanged?.call(toValue);
      updateState();
    }
  }
}

///
///
///  /// 值/ValueMixin
///  @override
///  final dynamic initValue;
///  @override
///  final List? values;
///  @override
///  final List<Widget>? valuesWidget;
///  @override
///  final TransformDataWidgetBuilder? transformValueWidget;
///
mixin ValueMixin {
  //--ValueMixin
  /// 初始化的值
  dynamic get initValue => null;

  /// 值列表
  List? get values => null;

  /// 当[initValue]为空时, 使用此部件占位
  @defInjectMark
  Widget? get valueNullWidget => null;

  /// 值对应的小部件列表 没有使用[Text]小部件自动生成对应的小部件
  List<Widget>? get valuesWidget => null;

  /// 将一个[value]转换成[Widget], 不指定则使用[Text]小部件
  TransformDataWidgetBuilder? get transformValueWidget => null;

  //--

  /// 并不需要在此方法中更新界面
  ValueChanged<dynamic>? get onValueChanged => null;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  FutureValueCallback<dynamic>? get onValueConfirmChange => null;

  //--

  int get valueIndexMixin {
    int index = values?.indexOf(initValue) ?? 0;
    index = max(index, 0);
    return index;
  }

  //--

  /// 根据[values].[children]创建[WidgetList]
  /// [selectedIndex] 选中的索引, 选中的颜色会不一样
  ///
  /// [TileMixin.buildChildrenFromValues]
  @api
  WidgetList? buildValuesWidgetListMixin(
    BuildContext context, {
    List? values,
    List<Widget>? valuesWidget,
    TransformDataWidgetBuilder? transformValueWidget,
    //--
    int? selectedIndex,
    bool selectedBold = true,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
  }) {
    valuesWidget ??= this.valuesWidget;
    transformValueWidget ??= this.transformValueWidget;
    values ??= this.values ?? (valuesWidget == null ? [initValue] : null);

    WidgetList? result;

    if (valuesWidget == null) {
      final globalTheme = GlobalTheme.of(context);
      result = values?.mapIndex((data, index) {
        //widget
        final widget = widgetOf(context, data, tryTextWidget: false);
        if (widget != null) {
          return transformValueWidget?.call(context, widget, data) ?? widget;
        }
        //debugger();
        final style = textStyle ??
            globalTheme.textGeneralStyle.copyWith(
              color: index == selectedIndex
                  ? context.darkOr(
                      globalTheme.textPrimaryStyle.color,
                      globalTheme.themeBlackColor,
                    )
                  : context.darkOr(
                      globalTheme.textPrimaryStyle.color,
                      null,
                    ),
              fontWeight: (index == selectedIndex && selectedBold)
                  ? ui.FontWeight.bold
                  : null,
              /*fontSize: 14,*/
            );
        //尝试text小部件
        final textWidget = textOf(data)!.text(
          style: index == selectedIndex
              ? selectedTextStyle ?? style
              : textStyle ?? style,
        );
        return transformValueWidget?.call(context, textWidget, data) ??
            textWidget.min();
      }).toList();
    } else {
      result = valuesWidget;
    }
    return result;
  }
}
