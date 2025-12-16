part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/16
///
/// 桌面端, 弹出的选项选择弹窗[PopupRoute]
/// - [WheelDialog]
///
/// - 支持单选
/// - 支持多选
/// @return 选中的值列表
@desktopLayout
class DesktopOptionsPopup extends StatefulWidget with MultiValueConfigMixin {
  //MARK: - MultipleValue

  /// 值列表, 支持很多类型
  /// - [widgetOf]
  @override
  final List? values;

  /// 选中的值列表
  @override
  final List? selectedValues;

  /// 值列表对应的Widget
  @override
  final List<Widget>? valuesWidget;

  /// 点击事件回调
  @override
  final ValueCallback? onTapValue;

  /// 选中的值列表改变回调
  @override
  final ValueCallback<List>? onValuesSelected;

  /// 最多选中数量
  @override
  final int maxSelectedCount;

  /// 是否允许空选择
  @override
  final bool enableSelectedEmpty;

  //MARK: - style

  /// 圆角
  final double? radius;

  /// 弹窗最大高度
  @defInjectMark
  final double? maxHeight;

  const DesktopOptionsPopup({
    super.key,
    //--
    this.values,
    this.selectedValues,
    this.valuesWidget,
    this.onTapValue,
    this.onValuesSelected,
    this.maxSelectedCount = 1,
    this.enableSelectedEmpty = false,
    //--
    this.radius = kDefaultBorderRadius,
    this.maxHeight,
  });

  @override
  State<DesktopOptionsPopup> createState() => _DesktopOptionsPopupState();
}

class _DesktopOptionsPopupState extends State<DesktopOptionsPopup>
    with MultiValueMixin {
  @override
  Widget build(BuildContext context) {
    double? radius = widget.radius;
    final globalTheme = GlobalTheme.of(context);
    final segmentList = buildValuesWidgetList(
      context,
      globalTheme,
      enableSelectedDecoration: false,
      textAlign: .start,
      transformValueWidget: (ctx, child, index, value, isSelected) {
        return [
                  Icon(
                    Icons.check_sharp,
                    color: globalTheme.successColor,
                  ).invisible(enable: !(isSelected == true)).insets(h: kL),
                  child.ignorePointer().expanded(),
                ]
                .row()
                ?.inkWell(() {
                  if (clickChildItemValueWidget(index, value)) {
                    if (!isMultiSelectMixin) {
                      buildContext?.popMenu(result: selectedValuesMixin);
                    }
                  }
                }, borderRadius: radius?.borderRadius)
                .material()
                .insets(all: kM) ??
            child;
      },
    );
    return segmentList?.scrollVertical()?.constrainedMax(
          maxHeight: widget.maxHeight ?? $screenMinSize / 2,
        ) ??
        empty;
  }
}
