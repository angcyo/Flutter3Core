part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24

/// 单行输入最大长度
const kDefaultInputLength = 30;

/// 简单的输入框对话框, 默认居中输入框.
/// [SingleInputDialog.alignment] 显示位置
///
/// [showDialogWidget]
/// [SingleInputDialog]
/// [SingleBottomInputDialog]
/// @return 返回输入的字符串
class SingleInputDialog extends StatelessWidget with DialogMixin {
  /// 是否使用图标按钮, 控制按钮
  final bool useIcon;

  final String? title;
  final Widget? titleWidget;

  final String? cancel;
  final Widget? cancelWidget;
  final bool? showCancel;
  final String? save;
  final Widget? saveWidget;
  final bool? showSave;

  /// 对话框的位置, 居中还是底部全屏
  /// [Alignment.center]
  /// [Alignment.bottomCenter]
  final AlignmentGeometry alignment;

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

  @override
  EdgeInsets get contentPadding => EdgeInsets.zero;

  SingleInputDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.hintText,
    this.cancel,
    this.cancelWidget,
    this.showCancel = true,
    this.save,
    this.saveWidget,
    this.showSave = true,
    this.onSaveTap,
    this.alignment = Alignment.center,
    this.maxLines = 1,
    this.maxLength = kDefaultInputLength,
    this.useIcon = false,
    TextFieldConfig? inputConfig,
    String? text,
  }) : _inputConfig = inputConfig ?? TextFieldConfig(text: text);

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    //标题 和 内容
    Widget? title = titleWidget ??
        this
            .title
            ?.text(
                style: globalTheme.textBodyStyle
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)
            .paddingOnly(
                left: kX,
                right: kX,
                top: kX,
                bottom: alignment == Alignment.center ? 0 : kX);
    //输入框
    Widget input = SingleInputWidget(
      config: _inputConfig,
      maxLines: maxLines,
      maxLength: maxLength,
      border: underlineInputBorder(color: globalTheme.borderColor),
      focusedBorder: underlineInputBorder(color: globalTheme.accentColor),
      hintText: hintText,
      //labelText: "",
      //isDense: false,
      contentPadding: const EdgeInsets.fromLTRB(kH, kL, kH, kL),
    );

    // 取消 和 保存
    final cancelText = showCancel == true
        ? this.cancel ?? LibRes.of(context).libCancel
        : this.cancel;
    Widget? cancel = (cancelWidget == null && cancelText == null)
        ? null
        : CancelButton(
            widget: cancelWidget,
            text: cancelText,
            useIcon: useIcon,
            onTap: () {
              Navigator.pop(context, false);
            });

    final saveText =
        showSave == true ? this.save ?? LibRes.of(context).libSave : this.save;
    Widget? save = (saveWidget == null && saveText == null)
        ? null
        : ConfirmButton(
            widget: saveWidget,
            text: saveText,
            useIcon: useIcon,
            onTap: () async {
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
            });

    //line
    Widget? hLine = (cancel != null || save != null || title != null)
        ? Line(
            axis: Axis.horizontal,
            color: globalTheme.lineDarkColor,
            margin:
                EdgeInsets.only(top: alignment == Alignment.center ? kL : 0),
          )
        : null;
    Widget? vLine = (cancel != null && save != null)
        ? Line(
            axis: Axis.vertical,
            color: globalTheme.lineDarkColor,
          )
        : null;

    //result
    if (alignment == Alignment.center) {
      //居中样式的对话框
      final controlRow = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (cancel != null) cancel.expanded(),
          if (vLine != null) vLine,
          if (save != null) save.expanded(),
        ],
      );

      final bodyColumn = Column(
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
        body: buildCenterDialog(context, bodyColumn),
      );
    }

    //底部全屏样式的对话框
    final topRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (cancel != null) cancel,
        (title ?? const Empty.zero()).expanded(),
        if (save != null) save,
      ],
    );
    final bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        topRow,
        if (hLine != null) hLine,
        input.paddingSymmetric(vertical: kX),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: buildBottomDialog(context, bodyColumn),
    );
  }
}