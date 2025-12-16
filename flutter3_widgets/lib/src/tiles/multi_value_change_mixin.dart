part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025-12-16

//MARK: - 多选

/// 多选混入
///
/// - [ValueMixin]
/// - [MultiValueConfigMixin]
///
/// - [ValueSegmentTile]
mixin MultiValueConfigMixin {
  //MARK: - config

  /// 值列表, 支持很多类型
  /// - [widgetOf]
  List? get values => null;

  /// 选中的值列表
  List? get selectedValues => null;

  /// 值列表对应的Widget
  List<Widget>? get valuesWidget => null;

  /// 在指定value上的点击事件回调
  ValueCallback? get onTapValue => null;

  /// 选中的值列表改变回调
  ValueCallback<List>? get onValuesSelected => null;

  /// 最多选中数量, 1表示单选
  int get maxSelectedCount => 1;

  /// 是否允许空选择
  bool get enableSelectedEmpty => true;
}

/// [MultiValueConfigMixin]的逻辑实现
mixin MultiValueMixin<T extends StatefulWidget> on State<T> {
  MultiValueConfigMixin? get multipleValueConfig {
    return widget as MultiValueConfigMixin?;
  }

  /// 当前选中的值
  late List selectedValuesMixin;

  /// 最多选中数量
  int get maxSelectedCountMixin => multipleValueConfig?.maxSelectedCount ?? 1;

  /// 是否是多选模式
  bool get isMultiSelectMixin => maxSelectedCountMixin > 1;

  bool get enableSelectedEmptyMixin =>
      multipleValueConfig?.enableSelectedEmpty ?? true;

  @override
  void initState() {
    selectedValuesMixin = [...?multipleValueConfig?.selectedValues];
    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    selectedValuesMixin = [...?multipleValueConfig?.selectedValues];
    super.didUpdateWidget(oldWidget);
  }

  //MARK: - method

  /// 指定的值[value]是否选中了
  bool isSelectedValueMixin(dynamic value) {
    return selectedValuesMixin.contains(value) ?? false;
  }

  /// 是否可以选中指定的值[value]
  bool canSelectedValueMixin(dynamic value) {
    if (isSelectedValueMixin(value)) {
      return false;
    }
    if (!isMultiSelectMixin) {
      return true;
    }
    final selectedCount = selectedValuesMixin.size();
    if (selectedCount >= maxSelectedCountMixin) {
      return false;
    }
    return true;
  }

  /// 是否可以取消指定的值[value]
  bool canCancelSelectedValueMixin(dynamic value) {
    if (isMultiSelectMixin) {
      return enableSelectedEmptyMixin || selectedValuesMixin.contains(value);
    }
    return enableSelectedEmptyMixin;
  }

  /// 将[values].[valuesWidget]转换成对应的小部件
  @api
  WidgetNullList? buildValuesWidgetList(
    BuildContext context,
    GlobalTheme globalTheme, {
    List? values,
    List<Widget>? valuesWidget,
    TransformDataWidgetBuilder? transformValueWidget,
    //--
    bool enable = true,
    bool enableSelectedDecoration = true /*激活选中背景装饰*/,
    double? radius = kDefaultBorderRadiusX,
    //--
    TextStyle? textStyle,
    TextStyle? textSelectedStyle,
    TextAlign? textAlign,
    Color? selectedBgColor,
  }) {
    values ??= multipleValueConfig?.values;
    valuesWidget ??= multipleValueConfig?.valuesWidget;

    final widgetList =
        valuesWidget ??
        values?.mapIndexed((index, value) {
          return widgetOf(
                context,
                value,
                tryTextWidget: true,
                textAlign: textAlign ?? TextAlign.center,
                textStyle: isSelectedValueMixin(value)
                    ? textSelectedStyle
                    : textStyle,
              )
              ?.paddingOnly(all: kL)
              .backgroundDecoration(
                !enable
                    ? fillDecoration(
                        color: globalTheme.disableColor,
                        radius: radius,
                      )
                    : isSelectedValueMixin(value) && enableSelectedDecoration
                    ? fillDecoration(
                        color: selectedBgColor ?? globalTheme.accentColor,
                        radius: radius,
                      )
                    : null,
              );
        });
    //map
    return widgetList?.mapIndexed((index, widget) {
      final value = values?[index];
      final child = widget?.click(
        () {
          clickChildItemValueWidget(index, value);
        },
        enable: enable /*&&
                !disableTap &&
                (selectedDisableTap ? !isSelected : true)*/,
      );
      return child != null
          ? transformValueWidget?.call(
                  context,
                  child,
                  index,
                  value,
                  isSelectedValueMixin(value),
                ) ??
                child
          : null;
    }).toList();
  }

  /// 点击执行的value
  /// @return 取消或者选中[value]成功
  @api
  bool clickChildItemValueWidget(int index, dynamic value) {
    //debugger();
    multipleValueConfig?.onTapValue?.call(value);
    if (isSelectedValueMixin(value)) {
      if (canCancelSelectedValueMixin(value)) {
        selectedValuesMixin.remove(value);
        multipleValueConfig?.onValuesSelected?.call(selectedValuesMixin);
        updateState();
        return true;
      }
    } else {
      if (canSelectedValueMixin(value)) {
        if (!isMultiSelectMixin) {
          selectedValuesMixin.clear();
        }
        selectedValuesMixin.add(value);
        multipleValueConfig?.onValuesSelected?.call(selectedValuesMixin);
        updateState();
        return true;
      }
    }
    return false;
  }
}
