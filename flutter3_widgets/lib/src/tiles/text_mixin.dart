part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/10
///

/// 标签混入
/// [kLabelPadding]
/// [LabelMixin]
/// [TextMixin]
///
/// [LabelLayoutTile]
///
/// ```
///   /// 标签/LabelMixin
///   @override
///   final String? label;
///   @override
///   final Widget? labelWidget;
///   @override
///   final TextStyle? labelTextStyle;
///   @override
///   final TextAlign? labelTextAlign;
///   @override
///   final EdgeInsets? labelPadding;
///   @override
///   final BoxConstraints? labelConstraints;
/// ```
mixin LabelMixin {
  //--label
  /// 标签
  String? get label => null;

  Widget? get labelWidget => null;

  TextStyle? get labelTextStyle => null;

  TextAlign? get labelTextAlign => null;

  EdgeInsets? get labelPadding => null;

  BoxConstraints? get labelConstraints => null;

  /// 构建对应的小部件
  /// [buildLabelWidget]
  @callPoint
  Widget? buildLabelWidgetMixin(
    BuildContext context, {
    bool themeStyle = true,
    EdgeInsets? padding,
    String? label,
    Widget? labelWidget,
    TextStyle? labelTextStyle,
    TextAlign? labelTextAlign,
    //--
    bool? isRequired,
  }) {
    label ??= this.label;
    labelWidget ??= this.labelWidget;
    labelTextStyle ??= this.labelTextStyle;
    labelTextAlign ??= this.labelTextAlign;
    final globalTheme = GlobalTheme.of(context);
    final widget =
        labelWidget ??
        (label
            ?.text(
              style:
                  labelTextStyle ??
                  (themeStyle ? globalTheme.tileTextLabelStyle : null),
              textAlign: labelTextAlign,
            )
            .rowOf(
              isRequired == true
                  ? " *".text(textColor: Colors.redAccent)
                  : null,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
            )
            .constrainedBox(labelConstraints)
            .paddingInsets(labelPadding));
    return widget?.paddingInsets(padding);
  }
}

/// 文本混入
/// [LabelMixin]
/// [TextMixin]
///
/// [TextTile]
///
/// ```
///   /// 文本/TextMixin
///   @override
///   final String? text;
///   @override
///   final Widget? textWidget;
///   @override
///   final TextStyle? textStyle;
///   @override
///   final TextAlign? textAlign;
///   @override
///   final EdgeInsets? textPadding;
///   @override
///   final BoxConstraints? textConstraints;
/// ```
///
mixin TextMixin {
  //--text
  /// 文本
  String? get text => null;

  Widget? get textWidget => null;

  TextStyle? get textStyle => null;

  TextAlign? get textAlign => null;

  EdgeInsets? get textPadding => null;

  BoxConstraints? get textConstraints => null;

  /// 构建对应的小部件
  /// [buildTextWidgetMixin]
  @callPoint
  Widget? buildTextWidgetMixin(
    BuildContext context, {
    bool themeStyle = true,
    bool? bold,
    EdgeInsets? padding,
    String? text,
    Widget? textWidget,
    TextStyle? textStyle,
    TextAlign? textAlign,
    //--
    int? maxLines,
  }) {
    final globalTheme = GlobalTheme.of(context);
    text ??= this.text;
    textWidget ??= this.textWidget;
    textStyle ??= this.textStyle;
    textAlign ??= this.textAlign;

    textStyle ??= (themeStyle ? globalTheme.tileTextBodyStyle : null);
    if (bold == true) {
      textStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);
    }
    final widget =
        textWidget ??
        (text
            ?.text(style: textStyle, textAlign: textAlign, maxLines: maxLines)
            .constrainedBox(textConstraints)
            .paddingInsets(textPadding));
    return widget?.paddingInsets(padding);
  }
}

///
///
/// ```
///   /// 标题/TitleMixin
///   @override
///   final String? title;
///   @override
///   final Widget? titleWidget;
///   @override
///   final TextStyle? titleTextStyle;
///   @override
///   final TextAlign? titleTextAlign;
///   @override
///   final EdgeInsets? titlePadding;
///   @override
///   final BoxConstraints? titleConstraints;
/// ```
///
mixin TitleMixin {
  //--title
  /// 标题
  String? get title => null;

  Widget? get titleWidget => null;

  TextStyle? get titleTextStyle => null;

  TextAlign? get titleTextAlign => null;

  EdgeInsets? get titlePadding => null;

  BoxConstraints? get titleConstraints => null;

  /// 构建对应的小部件
  /// [buildTitleWidget]
  @callPoint
  Widget? buildTitleWidgetMixin(
    BuildContext context, {
    bool themeStyle = true,
    EdgeInsets? padding,
    String? title,
    Widget? titleWidget,
    TextStyle? titleTextStyle,
    TextAlign? titleTextAlign,
  }) {
    final globalTheme = GlobalTheme.of(context);
    title ??= this.title;
    titleWidget ??= this.titleWidget;
    titleTextStyle ??= this.titleTextStyle;
    titleTextAlign ??= this.titleTextAlign;
    final widget =
        titleWidget ??
        (title
            ?.text(
              style:
                  titleTextStyle ??
                  (themeStyle ? globalTheme.tileTextTitleStyle : null),
              textAlign: titleTextAlign,
            )
            .constrainedBox(titleConstraints)
            .paddingInsets(titlePadding));
    return widget?.paddingInsets(padding);
  }
}
