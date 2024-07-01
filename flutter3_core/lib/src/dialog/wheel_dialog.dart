part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// @return pop 返回选中的索引
class WheelDialog extends StatefulWidget with DialogMixin {
  /// title
  final String? title;
  final Widget? titleWidget;

  /// content
  final dynamic initValue;
  final List? values;
  final List<Widget>? valuesWidget;
  final TransformDataWidgetBuilder? transformValueWidget;

  /// wheel
  final bool enableWheelSelectedIndexColor;

  @override
  TranslationType get translationType => TranslationType.translation;

  const WheelDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.transformValueWidget,
    this.enableWheelSelectedIndexColor = true,
  });

  @override
  State<WheelDialog> createState() => _WheelDialogState();
}

class _WheelDialogState extends State<WheelDialog>
    with DialogMixin, TileMixin, ValueChangeMixin<WheelDialog, int> {
  final _itemExtent = kMinItemInteractiveHeight;
  final _wheelHeight = 200.0;

  @override
  int getInitialValueMixin() {
    int index = widget.values?.indexOf(widget.initValue) ?? 0;
    index = max(index, 0);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    WidgetList? children = buildChildrenFromValues(
      context,
      values: widget.values,
      valuesWidget: widget.valuesWidget,
      transformValueWidget: widget.transformValueWidget,
    );

    return buildBottomChildrenDialog(
        context,
        [
          CoreDialogTitle(
            title: widget.title,
            titleWidget: widget.titleWidget,
            enableTrailing: currentValueMixin != initialValueMixin,
            onPop: () {
              return currentValueMixin;
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                  decoration: fillDecoration(
                color: Colors.black12,
                borderRadius: 0,
              )).wh(double.infinity, _itemExtent),
              Wheel(
                looping: false,
                size: _wheelHeight,
                itemExtent: _itemExtent,
                initialIndex: currentValueMixin,
                enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
                onIndexChanged: (index) {
                  currentValueMixin = index;
                  updateState();
                },
                children: [...?children, if (children == null) empty],
              ).wh(double.infinity, _wheelHeight),
            ],
          ),
          /*ListWheelScrollView(
            itemExtent: _itemExtent,
            children: [
              "1".text(),
              "1".text(),
              "1".text(),
              "1".text(),
              "1".text(),
              "1".text(),
            ],
          ).size(width: double.infinity, height: 200)*/
        ],
        clipTopRadius: kDefaultBorderRadiusXX);
  }
}
