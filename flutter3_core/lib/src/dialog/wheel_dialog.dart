part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// pop返回选中的索引
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

class _WheelDialogState extends State<WheelDialog> with DialogMixin, TileMixin {
  int _initialIndex = 0;
  int _currentIndex = 0;
  final _itemExtent = kMinItemInteractiveHeight;
  final _wheelHeight = 200.0;

  @override
  void initState() {
    _initialIndex = widget.values?.indexOf(widget.initValue) ?? 0;
    _currentIndex = max(_initialIndex, 0);
    super.initState();
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
            enableTrailing: _currentIndex != _initialIndex,
            onPop: () {
              return _currentIndex;
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
                initialIndex: _currentIndex,
                enableSelectedIndexColor: widget.enableWheelSelectedIndexColor,
                onIndexChanged: (index) {
                  _currentIndex = index;
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
