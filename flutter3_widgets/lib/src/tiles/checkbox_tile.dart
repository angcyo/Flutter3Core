part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/07
///
/// 复选框tile
/// [CheckboxTile]
/// [LabelSwitchTile]
///
/// [CheckboxTheme].[CheckboxThemeData]
class CheckboxTile extends StatefulWidget {
  /// 文本描述信息
  final String? text;
  final EdgeInsets? textPadding;
  final Widget? textWidget;

  /// 是否选中
  /// 如果开启了半选状态, 值可能为null
  final bool? value;

  /// 并不需要在此方法中更新界面
  final ValueChanged<bool?>? onChanged;

  //--

  /// 是否要支持半选
  final bool tristate;

  /// 是否是圆形
  /// [RoundedRectangleBorder]
  /// [CircleBorder]
  final bool isCircleShape;

  //--

  /// 正常时的边框颜色
  @defInjectMark
  final Color? normalColor;

  /// 正常时边框宽度
  @defInjectMark
  final double? normalWidth;

  /// 激活时的颜色
  @defInjectMark
  final Color? activeColor;

  const CheckboxTile({
    super.key,
    this.text,
    this.textWidget,
    this.textPadding = kContentPadding,
    this.value = false,
    this.tristate = false,
    this.isCircleShape = false,
    this.normalColor,
    this.normalWidth,
    this.activeColor,
    this.onChanged,
  });

  @override
  State<CheckboxTile> createState() => _CheckboxTileState();
}

class _CheckboxTileState extends State<CheckboxTile> with TileMixin {
  bool? _initValue;

  @override
  void initState() {
    super.initState();
    _initValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CheckboxTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return [
      Checkbox(
        value: _initValue,
        tristate: widget.tristate,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        /*打勾时勾的颜色*/
        /*checkColor: Colors.purpleAccent,*/
        activeColor: widget.activeColor ?? globalTheme.accentColor,
        shape: widget.isCircleShape
            ? const CircleBorder()
            : const RoundedRectangleBorder(),
        side: WidgetStateBorderSide.resolveWith(
          (states) {
            if (states.isEmpty) {
              return BorderSide(
                width: widget.normalWidth ?? 1.0,
                color: widget.normalColor ?? globalTheme.lineDarkColor,
              );
            }
            return null;
          },
        ),
        onChanged: (value) {
          _initValue = value;
          widget.onChanged?.call(value);
          updateState();
        },
      ),
      buildTextWidget(
        context,
        textWidget: widget.textWidget,
        text: widget.text,
        textPadding: widget.textPadding,
      )?.expanded(),
    ].row(crossAxisAlignment: CrossAxisAlignment.center)!.click(() {
      _initValue = !_initValue!;
      widget.onChanged?.call(_initValue);
      updateState();
    });
  }
}
