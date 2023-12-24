part of flutter3_widgets;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24

/// 单行输入最大长度
const kDefaultInputLength = 30;

/// 简单的输入框对话框
class SingleInputDialog extends StatelessWidget with DialogConstraintMixin {
  final String? title;
  final Widget? titleWidget;

  final String? cancel;
  final Widget? cancelWidget;
  final String? save;
  final Widget? saveWidget;

  /// 输入框提示文本
  final String? hintText;

  /// 保存按钮点击回调, 返回true, 表示拦截默认处理
  final FutureResultCallback<bool, String>? onSaveTap;

  /// 输入框配置
  final TextFieldConfig _inputConfig;

  /// 最大行数
  final int maxLines;

  /// 最大长度
  final int? maxLength;

  SingleInputDialog({
    super.key,
    this.title,
    this.hintText,
    this.titleWidget,
    this.cancel = kDialogCancel,
    this.cancelWidget,
    this.save = kDialogSave,
    this.saveWidget,
    this.onSaveTap,
    this.maxLines = 1,
    this.maxLength = kDefaultInputLength,
    TextFieldConfig? inputConfig,
    String? text,
  }) : _inputConfig = inputConfig ?? TextFieldConfig(text: text);

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);

    //标题 和 内容
    Widget? title = titleWidget ??
        this
            .title
            ?.text(
                style: globalTheme.textBodyStyle
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.start)
            .paddingAll(kX);
    //输入框
    Widget input = SingleInputWidget(
      config: _inputConfig,
      maxLines: maxLines,
      maxLength: maxLength,
      border: underlineInputBorder(color: globalTheme.borderColor),
      focusedBorder: underlineInputBorder(color: globalTheme.accentColor),
      //labelText: "",
      hintText: hintText,
    );

    // 取消 和 保存
    Widget? cancel = cancelWidget ??
        this
            .cancel
            ?.text(
                style: globalTheme.textLabelStyle, textAlign: TextAlign.center)
            .paddingAll(kXh);

    cancel = cancel?.ink(onTap: () {
      Navigator.pop(context, false);
    }).material();

    Widget? save = saveWidget ??
        this
            .save
            ?.text(
                style: globalTheme.textLabelStyle
                    .copyWith(color: globalTheme.accentColor),
                textAlign: TextAlign.center)
            .paddingAll(kXh);
    save = save?.ink(onTap: () async {
      var result = _inputConfig.text;
      if (onSaveTap == null) {
        Navigator.pop(context, result);
      } else {
        var intercept = await onSaveTap!(result) == true;
        if (!intercept) {
          if (context.mounted) {
            Navigator.pop(context, result);
          }
        }
      }
    }).material();

    //line
    Widget? hLine = (cancel != null || save != null)
        ? Line(
            axis: Axis.horizontal,
            color: globalTheme.lineDarkColor,
            margin: const EdgeInsets.only(top: kL),
          )
        : null;
    Widget? vLine = (cancel != null && save != null)
        ? Line(
            axis: Axis.vertical,
            color: globalTheme.lineDarkColor,
          )
        : null;

    var controlRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (cancel != null) cancel.expanded(),
        if (vLine != null) vLine,
        if (save != null) save.expanded(),
      ],
    );

    var bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title,
        input.paddingSymmetric(horizontal: kX),
        if (hLine != null) hLine,
        controlRow,
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: dialogCenterContainer(
        context: context,
        child: bodyColumn,
      ),
    );
  }
}
