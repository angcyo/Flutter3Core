part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// [WheelDialog]
class LabelWheelTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// content
  final dynamic initValue;
  final List? values;
  final List<Widget>? valuesWidget;

  /// 索引改变回调
  final IndexCallback? onTabIndexChanged;

  const LabelWheelTile({
    super.key,
    this.label,
    this.labelWidget,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.onTabIndexChanged,
  });

  @override
  State<LabelWheelTile> createState() => _LabelWheelTileState();
}

class _LabelWheelTileState extends State<LabelWheelTile> with TileMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: kM, vertical: kX),
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(minHeight: kMinInteractiveHeight),
      child: [
        (widgetOf(context, widget.initValue, tryTextWidget: true) ?? empty)
            .expanded(),
        loadCoreAssetSvgPicture(Assets.svg.coreNext)
      ].row()!,
    ).ink(
      () async {
        final result = await context.showWidgetDialog(WheelDialog(
          title: widget.label,
          initValue: widget.initValue,
          values: widget.values,
          valuesWidget: widget.valuesWidget,
        ));
        if (result != null) {
          if (result is int) {
            widget.onTabIndexChanged?.call(result);
          } else {
            assert(() {
              l.w('无效的wheel返回值类型');
              return true;
            }());
          }
        }
      },
      backgroundColor: globalTheme.itemWhiteBgColor,
      radius: kDefaultBorderRadiusXX,
    ).paddingInsets(kContentPadding);

    return [label, content.expanded()].row()!.material();
  }
}
