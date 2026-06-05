part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///
/// 下拉按钮菜单tile, 系统内部使用[PopupRoute]实现
///
/// - [DropdownButton] 系统, 点击触发下拉菜单, 下划线样式, 下拉样式
/// - [DropdownMenu] 系统, 焦点触发下拉菜单, 边框样式, 还可输入
/// - [MenuAnchor] 系统
///
/// - [DropdownTile] tile
/// - [DropdownMenuTile] tile 内部[Overlay]
/// - [DropdownButtonTile] tile 内部[PopupRoute]
/// - [MenuAnchorTile] tile
///
class DropdownButtonTile extends StatefulWidget with TileMixin {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  ///
  final MainAxisSize? mainAxisSize;

  //--Item

  /// 下拉菜单中, item的对齐方式
  /// [DropdownMenuItem]
  final AlignmentGeometry itemAlignment;

  /// 变换小部件
  final TransformDataWidgetBuilder? itemTransformBuilder;

  //--Dropdown

  /// Dropdown
  final dynamic dropdownValue;
  final List<dynamic>? dropdownValueList;

  /// [dropdownValue]也会被回调
  final ValueChanged<dynamic>? onChanged;

  /// 填充边距
  @defInjectMark
  final EdgeInsetsGeometry? padding;

  /// Dropdown2
  /// 右边箭头的小部件, 系统有默认
  final Widget? icon;
  final double iconSize;

  /// 文本样式
  final TextStyle? style;

  final AlignmentGeometry alignment;

  /// 下拉背景颜色
  final Color? dropdownColor;

  //--

  /// 紧凑
  final bool isDense;

  /// 扩展宽度, 箭头就会被顶到最后面
  /// 不指定时, 当[labelWidget]为空时. 自动撑满
  @defInjectMark
  final bool? isExpanded;

  /// 下划线, 系统有默认
  final Widget? underline;

  const DropdownButtonTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    //--
    this.itemAlignment = AlignmentDirectional.centerStart,
    this.itemTransformBuilder,
    //--Dropdown
    this.dropdownValue,
    this.dropdownValueList,
    this.onChanged,
    this.icon,
    this.iconSize = 24.0,
    this.style,
    this.alignment = AlignmentDirectional.center,
    this.mainAxisSize,
    this.isDense = false,
    this.isExpanded,
    this.underline,
    this.dropdownColor,
    this.padding,
  });

  @override
  State<DropdownButtonTile> createState() => _DropdownButtonTileState();
}

class _DropdownButtonTileState extends State<DropdownButtonTile>
    with ValueChangeMixin<DropdownButtonTile, dynamic> {
  @override
  dynamic getInitialValueMixin() => widget.dropdownValue;

  @override
  Widget build(BuildContext context) {
    final labelWidget = widget
        .buildTextWidget(
          context,
          textWidget: widget.labelWidget,
          text: widget.label,
          textPadding: widget.labelPadding,
        )
        ?.expanded(enable: widget.mainAxisSize != MainAxisSize.min);
    final dropdown = DropdownButton(
      items: _buildDropdownMenuItems(context),
      value: currentValueMixin,
      //文本样式
      style: widget.style,
      icon: widget.icon,
      iconSize: widget.iconSize,
      itemHeight: kMinInteractiveDimension,
      menuMaxHeight: null,
      //紧凑的高度
      isDense: widget.isDense,
      isExpanded: widget.isExpanded ?? labelWidget == null,
      //下划线
      underline: widget.underline,
      //下拉菜单的背景颜色
      //[ThemeData.canvasColor]
      dropdownColor: widget.dropdownColor,
      enableFeedback: true,
      alignment: widget.alignment,
      padding: widget.padding ?? insets(h: kH),
      onChanged: (value) {
        /*initialValue = value;
            updateState();*/
        assert(() {
          l.w("DropdownButtonTile.onChanged[${value.runtimeType}]: $value");
          return true;
        }());
        updateValueMixin(value);
        widget.onChanged?.call(value);
      },
    );
    if (labelWidget == null) {
      return dropdown;
    }
    return [labelWidget, dropdown].row(mainAxisSize: widget.mainAxisSize)!;
  }

  /// [DropdownMenuItem]
  List<DropdownMenuItem> _buildDropdownMenuItems(BuildContext context) {
    return [
      for (final (index, value) in (widget.dropdownValueList ?? []).indexed)
        DropdownMenuItem(
          value: value,
          enabled: true,
          alignment: widget.itemAlignment,
          child: _transformItemWidget(
            context,
            widgetOf(context, value, tryTextWidget: true) ?? empty,
            index,
            value,
            value == currentValueMixin,
          ),
        ),
    ];
  }

  /// [itemTransformBuilder]
  Widget _transformItemWidget(
    BuildContext context,
    Widget item,
    int index,
    dynamic data,
    bool? isSelected,
  ) {
    return widget.itemTransformBuilder?.call(
          context,
          item,
          index,
          data,
          isSelected,
        ) ??
        item;
  }
}

/// 下拉输入框菜单tile, 系统内部使用[Overlay]实现
///
/// - [DropdownButton] 系统, 点击触发下拉菜单, 下划线样式, 下拉样式
/// - [DropdownMenu] 系统, 焦点触发下拉菜单, 边框样式, 还可输入
/// - [MenuAnchor] 系统
///
/// - [DropdownTile] tile
/// - [DropdownMenuTile] tile 内部[Overlay]
/// - [DropdownButtonTile] tile 内部[PopupRoute]
/// - [MenuAnchorTile] tile
class DropdownMenuTile extends StatefulWidget with TileMixin {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  ///
  final MainAxisSize? mainAxisSize;

  /// Dropdown
  final dynamic dropdownValue;
  final List<dynamic>? dropdownValueList;
  final ValueChanged<dynamic>? onChanged;

  /// 输入框的文本改变回调, 选择了下拉菜单项, 也会触发
  final ValueChanged<String>? onTextChanged;

  /// 是否显示尾部图标
  final bool showTrailingIcon;

  /// 尾部图标
  final Widget? trailingIcon;

  /// 头部图标
  final Widget? leadingIcon;

  /// 撑满并且加内边距
  /// - null, 则不撑满布局
  final EdgeInsetsGeometry? expandedInsets;

  //MARK: - menu

  /// 下拉菜单的样式
  final MenuStyle? menuStyle;

  /// 下拉菜单样式的背景颜色
  @defInjectMark
  final Color? menuBgColor;

  /// 下拉菜单中, item的对齐方式
  /// [DropdownMenuItem]
  final AlignmentGeometry itemAlignment;

  /// 紧凑
  final bool isDense;

  /// 扩展宽度, 箭头就会被顶到最后面
  /// 不指定时, 当[labelWidget]为空时. 自动撑满
  @defInjectMark
  final bool? isExpanded;

  /// 输入框过滤
  /// - 根据输入框的值[controller]过滤下拉列表
  final bool enableFilter;

  /// 只选择, 不输入
  final bool selectOnly;

  //MARK: - input

  /// 输入框输入格式
  final List<TextInputFormatter>? inputFormatters;

  /// 输入框的输入行为
  final TextInputAction? textInputAction;

  /// 最大行数
  final int? maxLines;

  /// 设置了此值, 才有输入框
  final TextEditingController? controller;

  /// 输入框提示语
  final String? hintText;

  /// 输入框下面的提示语
  final String? helperText;

  /// 输入框边框样式
  final InputBorderType? inputBorderType;

  /// 输入框的标签
  final Widget? inputLabelWidget;
  final String? inputLabel;

  const DropdownMenuTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.mainAxisSize,
    this.showTrailingIcon = true,
    this.trailingIcon,
    this.leadingIcon,
    this.expandedInsets = .zero,
    //--
    this.dropdownValue,
    this.dropdownValueList,
    this.onChanged,
    this.onTextChanged,
    this.isDense = true,
    this.isExpanded,
    this.selectOnly = false,
    this.enableFilter = true,
    this.menuStyle,
    this.menuBgColor,
    this.itemAlignment = AlignmentDirectional.centerStart,
    //--
    this.inputFormatters,
    this.textInputAction,
    this.maxLines = 1,
    this.controller,
    this.hintText,
    this.helperText,
    this.inputBorderType = InputBorderType.outline,
    this.inputLabel,
    this.inputLabelWidget,
  });

  @override
  State<DropdownMenuTile> createState() => _DropdownMenuTileState();
}

class _DropdownMenuTileState extends State<DropdownMenuTile>
    with InputDecorationMixin {
  TextEditingController? _textEditingController;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.enableFilter) {
      _textEditingController = widget.controller ?? TextEditingController();
    } else {
      _textEditingController = widget.controller;
    }
    if (_textEditingController != null) {
      _textEditingController!.addListener(_onTextChanged);
    }
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textEditingController?.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DropdownMenuTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableFilter) {
      if (_textEditingController != widget.controller) {
        _textEditingController?.removeListener(_onTextChanged);
        _textEditingController =
            widget.controller ??
            _textEditingController ??
            TextEditingController();
      }
    } else {
      _textEditingController?.removeListener(_onTextChanged);
      _textEditingController = widget.controller;
    }
    if (_textEditingController != null) {
      _textEditingController!.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    final text = _textEditingController?.text;
    assert(() {
      l.w(
        "DropdownMenuTile.onTextChanged[${widget.dropdownValue.runtimeType}]: $text",
      );
      return true;
    }());
    if (text != null) {
      widget.onTextChanged?.call(text);
    }
  }

  void _onFocusChanged() {
    //updateState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final menuBgColor = widget.menuBgColor ?? globalTheme.dialogSurfaceBgColor;
    final labelWidget = widget
        .buildTextWidget(
          context,
          textWidget: widget.labelWidget,
          text: widget.label,
          textPadding: widget.labelPadding,
        )
        ?.expanded(enable: widget.mainAxisSize != MainAxisSize.min);
    final dropdown = DropdownMenu(
      dropdownMenuEntries: _buildDropdownMenuEntry(context),
      enabled: true,
      focusNode: focusNode,
      selectOnly: widget.selectOnly /*仅支持选择?*/,
      enableFilter: widget.enableFilter,
      enableSearch: true /*激活搜索高亮?*/,
      searchCallback: (entries, query) {
        //debugger();
        //返回需要高亮的index
        int index = entries.indexWhere(
          (entry) => "${entry.value}".startsWith(query),
        );
        if (index == -1) {
          index = entries.indexWhere(
            (entry) => "${entry.value}".contains(query),
          );
        }
        return index == -1 ? null : index;
      },
      //实现自定义的过滤规则
      /*filterCallback: widget.enableFilter
          ? (entries, query) {
              //搜索过滤
              return entries;
            }
          : null,*/
      initialSelection: widget.dropdownValue,
      width: null /*double.infinity*/ /*显示的宽度*/,
      menuHeight: null /*下拉菜单整体的高度*/,
      expandedInsets: widget.expandedInsets /*撑满并且加内边距*/,
      //菜单样式
      menuStyle:
          widget.menuStyle ??
          MenuStyle(
            backgroundColor: WidgetStatePropertyAll(menuBgColor),
            //菜单显示时, 对齐锚点的方式
            elevation: const WidgetStatePropertyAll<double?>(3.0),
            shape: const WidgetStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
            alignment: .bottomStart,
          ),
      //输入控制器
      requestFocusOnTap: _textEditingController != null,
      controller: _textEditingController,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      //控制输入框的焦点
      label: widget.inputBorderType == null
          ? widget.inputLabelWidget
          : null /*"Label".text().bounds()*/ /*不能和装饰器同时存在*/,
      hintText: widget.hintText,
      helperText: widget.helperText,
      showTrailingIcon: widget.showTrailingIcon,
      trailingIcon: widget.trailingIcon,
      leadingIcon: widget.leadingIcon,
      decorationBuilder: widget.inputBorderType != null
          ? (ctx, controller) => buildInputDecoration(
              ctx,
              isDense: !widget.showTrailingIcon,
              suffixIconConstraints: kSuffixIconConstraints,
              label: widget.inputLabelWidget,
              labelText: widget.inputLabel,
              hasFocus: focusNode.hasFocus,
            )
          : null,
      //输入框样式 [inputDecorationTheme] [InputDecorationThemeData]
      inputDecorationTheme: InputDecorationThemeData(
        isDense: !widget.showTrailingIcon,
        isCollapsed: true,
        suffixIconConstraints: kSuffixIconConstraints,
      ),
      /*inputDecorationTheme: InputDecorationTheme(
        isDense: widget.isDense,
        filled: false,
        fillColor: null,
        outlineBorder: null,
        activeIndicatorBorder: null,
        errorBorder: null,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        constraints: BoxConstraints(maxHeight: kMinInteractiveDimension),
        contentPadding: null */
      /*EdgeInsets.zero*/
      /*,
      ),*/
      onSelected: (value) {
        assert(() {
          l.w("DropdownMenuTile.onChanged[${value.runtimeType}]: $value");
          return true;
        }());
        widget.onChanged?.call(value);
        if (widget.selectOnly) {
          widget.onTextChanged?.call(value);
        }
      },
    );
    if (labelWidget == null) {
      return dropdown;
    }
    return [labelWidget, dropdown].row(mainAxisSize: widget.mainAxisSize)!;
  }

  /// [DropdownMenuEntry]
  List<DropdownMenuEntry> _buildDropdownMenuEntry(BuildContext context) {
    return [
      for (final value in widget.dropdownValueList ?? [])
        DropdownMenuEntry(
          label: "${textOf(value, context)}",
          labelWidget: widgetOf(context, value, tryTextWidget: true),
          value: value,
          leadingIcon: null,
          trailingIcon: null,
          enabled: true,
          style: null,
        ),
    ];
  }
}

/// 锚点菜单tile, 使用[MenuAnchor]实现
/// 内部使用[Overlay]实现
///
/// - [DropdownButton] 系统, 点击触发下拉菜单, 下划线样式, 下拉样式
/// - [DropdownMenu] 系统, 焦点触发下拉菜单, 边框样式, 还可输入
/// - [MenuAnchor] 系统
///
/// - [DropdownTile] tile
/// - [DropdownMenuTile] tile
/// - [DropdownButtonTile] tile
/// - [MenuAnchorTile] tile
class MenuAnchorTile extends StatefulWidget {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// menu
  final List<Widget>? menuChildren;
  final MenuAnchorChildBuilder? anchorBuilder;
  final Widget? anchorChild;

  /// 菜单显示时的对齐方式
  final AlignmentGeometry? menuAlignment;
  final Color? menuBgColor;

  /// default menu
  final List<dynamic>? menuValueList;
  final ValueChanged<dynamic>? onChanged;

  const MenuAnchorTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.menuChildren,
    this.anchorBuilder,
    this.anchorChild,
    this.menuValueList,
    this.menuAlignment,
    this.menuBgColor = Colors.white,
    this.onChanged,
  });

  @override
  State<MenuAnchorTile> createState() => _MenuAnchorTileState();
}

class _MenuAnchorTileState extends State<MenuAnchorTile> with TileMixin {
  MenuController menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    //--
    final label = buildTextWidget(
      context,
      textWidget: widget.labelWidget,
      text: widget.label ?? "",
      textPadding: widget.labelPadding,
    )!.expanded();
    //--
    final menuAnchor = MenuAnchor(
      controller: menuController,
      menuChildren: widget.menuChildren ?? _buildDefaultMenuItems(context),
      style: MenuStyle(
        backgroundColor: widget.menuBgColor == null
            ? null
            : WidgetStatePropertyAll(widget.menuBgColor),
        alignment: widget.menuAlignment,
      ),
      consumeOutsideTap: false,
      crossAxisUnconstrained: false,
      onOpen: () {
        l.d('open');
      },
      onClose: () {
        l.d('close');
      },
      builder: widget.anchorBuilder,
      child: (widget.anchorChild == null && widget.anchorBuilder == null)
          ? [label].row()?.click(() {
              //debugger();
              if (menuController.isOpen) {
                menuController.close();
              } else {
                menuController.open();
              }
            })
          : widget.anchorChild,
    );

    //--
    if (widget.anchorChild == null && widget.anchorBuilder == null) {
      return menuAnchor;
    }
    return [label, menuAnchor].row()!;
  }

  /// [Widget]
  List<Widget> _buildDefaultMenuItems(BuildContext context) {
    return [
      for (final value in widget.menuValueList ?? [])
        widgetOf(context, value) ??
            textOf(value, context)!
                .text(textAlign: ui.TextAlign.start)
                .paddingSymmetric(horizontal: kX)
                .align(AlignmentDirectional.centerStart)
                .ink(() {
                  widget.onChanged?.call(value);
                  menuController.close();
                })
                .constrainedMin(minHeight: kMinInteractiveDimension),
    ];
  }
}

/// 使用 `dropdown_flutter: ^1.0.3` 实现的下拉菜单tile
/// # https://pub.dev/packages/dropdown_flutter
/// - 样式更现代
/// - 有箭头
/// - 支持多选
/// - 支持搜索骨哦绿
///
/// 内部使用[OverlayPortal]实现
/// - [CompositedTransformTarget]
/// - [CompositedTransformFollower]
///
/// - [DropdownButton] 系统, 点击触发下拉菜单, 下划线样式, 下拉样式
/// - [DropdownMenu] 系统, 焦点触发下拉菜单, 边框样式, 还可输入
/// - [MenuAnchor] 系统
///
/// - [DropdownTile] tile
/// - [DropdownMenuTile] tile
/// - [DropdownButtonTile] tile
/// - [MenuAnchorTile] tile
class DropdownTile extends StatefulWidget {
  //MARK: - config

  /// 是否启用
  final bool enabled;

  /// 是否排除已选择的项在下拉菜单中
  final bool excludeSelected;

  /// 提示语
  final String? hintText;

  /// 搜索框提示语
  final String? searchHintText;

  final int textMaxLines;

  //MARK: - Dropdown

  /// Dropdown
  final dynamic dropdownValue;
  final List<dynamic>? dropdownValueList;
  final ValueChanged<dynamic>? onChanged;

  const DropdownTile({
    super.key,
    this.enabled = true,
    this.excludeSelected = true,
    this.hintText,
    this.searchHintText,
    this.textMaxLines = 1,
    this.dropdownValue,
    this.dropdownValueList,
    this.onChanged,
  });

  @override
  State<DropdownTile> createState() => _DropdownTileState();
}

class _DropdownTileState extends State<DropdownTile> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return DropdownFlutter(
      enabled: widget.enabled,
      excludeSelected: widget.excludeSelected,
      hintText: widget.hintText,
      maxlines: widget.textMaxLines,
      decoration: CustomDropdownDecoration(
        closedFillColor: globalTheme.themeWhiteColor,
        expandedFillColor: globalTheme.themeWhiteColor,
      ),
      /*closedHeaderPadding: insets(),
      expandedHeaderPadding: insets(),*/
      /*itemsListPadding: ,
      listItemPadding: ,*/
      /*searchHintText: "searchHintText",*/
      /*hideSelectedFieldWhenExpanded:,*/
      initialItem: widget.dropdownValue,
      /*initialItems: widget.dropdownValue,*/
      items: widget.dropdownValueList,
      /*onListChanged: widget.dropdownValueList,*/
      onChanged: (value) {
        //debugger();
        assert(() {
          l.d("${value.runtimeType} value: $value");
          return true;
        }());
        widget.onChanged?.call(value);
      },
    );
  }
}

//MARK: - ex

extension DropdownMenuValueListEx on List {
  /// - [dropdownValue] 默认值
  /// - [useOverlayStyle] 是否使用[DropdownMenuTile]实现
  ///
  /// - [DropdownButtonTile]
  /// - [DropdownMenuTile]
  ///   - [enableInputFilter] 是否启用过滤
  Widget dropdownMenu(
    dynamic dropdownValue, {
    Key? key,
    ValueChanged<dynamic>? onChanged,
    ValueChanged<String>? onTextChanged,
    //--
    bool isDense = false,
    bool? isExpanded,
    //--input style
    bool? useOverlayStyle,
    bool enableInputFilter = true,
    bool showInputTrailingIcon = true,
    InputBorderType? inputBorderType,
    String? inputLabel,
    Widget? inputLabelWidget,
    //--
    bool? notifyFirst,
  }) {
    List values;
    if (dropdownValue != null && !contains(dropdownValue)) {
      values = [dropdownValue, ...this];
    } else {
      values = this;
    }
    if (notifyFirst == true || dropdownValue == null) {
      //debugger();
      dropdownValue ??= values.firstOrNull;
      if (notifyFirst == true || dropdownValue != null) {
        onChanged?.call(dropdownValue);
        onTextChanged?.call("$dropdownValue");
      }
    }
    if (useOverlayStyle == true) {
      return DropdownMenuTile(
        key: key,
        dropdownValue: dropdownValue,
        dropdownValueList: values,
        onChanged: onChanged,
        onTextChanged: onTextChanged,
        isExpanded: isExpanded,
        isDense: isDense,
        selectOnly: !enableInputFilter,
        enableFilter: enableInputFilter,
        showTrailingIcon: showInputTrailingIcon,
        inputBorderType: inputBorderType ?? InputBorderType.outline,
        inputLabel: inputLabel,
        inputLabelWidget: inputLabelWidget,
      );
    }
    return DropdownButtonTile(
      key: key,
      dropdownValue: dropdownValue,
      dropdownValueList: values,
      onChanged: onChanged,
      isExpanded: isExpanded,
      isDense: isDense,
    );
  }
}
