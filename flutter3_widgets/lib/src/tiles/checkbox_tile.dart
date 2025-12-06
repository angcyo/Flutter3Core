part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/07
///
/// 系统[Checkbox]样式的复选框tile
/// [CheckboxTile]
/// [LabelSwitchTile]
///
/// [CheckboxTheme].[CheckboxThemeData]
class CheckboxTile extends StatefulWidget {
  /// 文本描述信息
  final String? text;
  final TextStyle? textStyle;
  final EdgeInsets? textPadding;
  final Widget? textWidget;

  /// 是否选中
  /// 如果开启了半选状态, 值可能为null
  final bool? value;

  /// 并不需要在此方法中更新界面
  /// null: 半选
  final ValueChanged<bool?>? onChanged;

  /// 选中之后是否能点击
  final bool enableCheckedTap;

  //--

  /// 是否要支持半选
  final bool tristate;

  /// 是否是圆形
  /// [RoundedRectangleBorder]
  /// [CircleBorder]
  final bool isCircleShape;

  /// 视觉密度
  final VisualDensity? visualDensity;

  //--

  /// 正常时的边框颜色
  @defInjectMark
  final Color? normalColor;

  /// 正常时边框宽度, 当为null时, 则使用系统样式
  final double? normalWidth;

  /// 激活时的颜色
  @defInjectMark
  final Color? activeColor;

  /// 打勾时勾的颜色
  /// [CheckboxThemeData.checkColor]
  final Color? checkColor;

  //--

  /// [MainAxisSize.min]
  /// [MainAxisSize.max] 默认
  @defInjectMark
  final MainAxisSize? mainAxisSize;

  const CheckboxTile({
    super.key,
    //--
    this.text,
    this.textStyle,
    this.textWidget,
    this.textPadding = kContentPadding,
    //--
    this.tristate = false,
    this.value = false,
    this.enableCheckedTap = true,
    this.onChanged,
    this.isCircleShape = false,
    //--
    this.mainAxisSize,
    this.visualDensity = VisualDensity.compact,
    this.normalColor,
    this.normalWidth = 1.0,
    this.activeColor,
    this.checkColor,
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
        visualDensity: widget.visualDensity,
        /*打勾时勾的颜色*/
        checkColor: widget.checkColor,
        activeColor: widget.activeColor ?? globalTheme.accentColor,
        shape: widget.isCircleShape
            ? const CircleBorder()
            : const RoundedRectangleBorder(),
        side: widget.normalWidth != null
            ? WidgetStateBorderSide.resolveWith(
                (states) {
                  if (states.isEmpty) {
                    return BorderSide(
                      width: widget.normalWidth ?? 1.0,
                      color: widget.normalColor ?? globalTheme.lineDarkColor,
                    );
                  }
                  return null;
                },
              )
            : null,
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
        textStyle: widget.textStyle,
        textPadding: widget.textPadding,
      )?.expanded(enable: widget.mainAxisSize != MainAxisSize.min),
    ]
        .row(
            mainAxisSize: widget.mainAxisSize,
            crossAxisAlignment: CrossAxisAlignment.center)!
        .click(() {
      _initValue = !_initValue!;
      widget.onChanged?.call(_initValue);
      updateState();
    }).ignorePointer(!widget.enableCheckedTap && _initValue == true);
  }
}

/// 使用[Checkbox]实现的不具有点击事件的check样式小部件
class CheckStyleWidget extends StatelessWidget {
  /// 是否是圆形
  /// [RoundedRectangleBorder]
  /// [CircleBorder]
  final bool isCircleShape;

  /// 激活时的颜色
  @defInjectMark
  final Color? activeColor;
  final Color? checkColor;

  const CheckStyleWidget({
    super.key,
    this.isCircleShape = true,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return Checkbox(
      value: true,
      /*打勾时勾的颜色*/
      checkColor: checkColor,
      activeColor: activeColor ?? globalTheme.accentColor,
      shape:
          isCircleShape ? const CircleBorder() : const RoundedRectangleBorder(),
      /*visualDensity: const VisualDensity(horizontal: 4, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.padded,*/
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onChanged: (value) {},
    ).ignorePointer();
  }
}
