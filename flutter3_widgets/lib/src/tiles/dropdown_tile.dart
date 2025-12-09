part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///
/// 下拉按钮菜单tile, 系统内部使用[PopupRoute]实现
///
/// - [DropdownButton] 系统
/// - [DropdownMenu] 系统
/// - [MenuAnchor] 系统
///
/// - [DropdownTile] tile
/// - [DropdownMenuTile] tile
/// - [DropdownButtonTile] tile
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

  /// [DropdownMenuItem]
  final AlignmentGeometry itemAlignment;

  /// 变换小部件
  final TransformDataWidgetBuilder? itemTransformBuilder;

  //--Dropdown

  /// Dropdown
  final dynamic dropdownValue;
  final List<dynamic>? dropdownValueList;
  final ValueChanged<dynamic>? onChanged;

  /// Dropdown2
  final Widget? icon;
  final double iconSize;

  final AlignmentGeometry alignment;

  final bool isDense;
  final bool isExpanded;
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
    this.alignment = AlignmentDirectional.center,
    this.mainAxisSize,
    this.isDense = false,
    this.isExpanded = false,
    this.underline,
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
    return [
      widget
          .buildTextWidget(
            context,
            textWidget: widget.labelWidget,
            text: widget.label ?? "",
            textPadding: widget.labelPadding,
          )
          ?.expanded(enable: widget.mainAxisSize != MainAxisSize.min),
      DropdownButton(
        items: _buildDropdownMenuItems(context),
        value: currentValueMixin,
        //文本样式
        style: null,
        icon: widget.icon,
        iconSize: widget.iconSize,
        itemHeight: kMinInteractiveDimension,
        menuMaxHeight: null,
        //紧凑的高度
        isDense: widget.isDense,
        isExpanded: widget.isExpanded,
        //下划线
        underline: widget.underline,
        //下拉菜单的背景颜色
        //[ThemeData.canvasColor]
        dropdownColor: null,
        enableFeedback: true,
        alignment: widget.alignment,
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
      ),
    ].row(mainAxisSize: widget.mainAxisSize)!;
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
            widgetOf(context, value) ?? textOf(value, context)!.text(),
            index,
            value,
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
  ) {
    return widget.itemTransformBuilder?.call(context, item, index, data) ??
        item;
  }
}

/// 下拉输入框菜单tile, 系统内部使用[Overlay]实现
///
/// - [DropdownButton] 系统
/// - [DropdownMenu] 系统
/// - [MenuAnchor] 系统
///
/// - [DropdownTile] tile
/// - [DropdownMenuTile] tile
/// - [DropdownButtonTile] tile
/// - [MenuAnchorTile] tile
class DropdownMenuTile extends StatelessWidget with TileMixin {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// Dropdown
  final dynamic dropdownValue;
  final List<dynamic>? dropdownValueList;
  final ValueChanged<dynamic>? onChanged;

  /// text
  final TextEditingController? controller;

  const DropdownMenuTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.dropdownValue,
    this.dropdownValueList,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      buildTextWidget(
        context,
        textWidget: labelWidget,
        text: label ?? "",
        textPadding: labelPadding,
      )!.expanded(),
      DropdownMenu(
        dropdownMenuEntries: _buildDropdownMenuEntry(context),
        enabled: true,
        enableFilter: false,
        enableSearch: true,
        searchCallback: null,
        menuHeight: null,
        initialSelection: dropdownValue,
        //输入控制器
        controller: controller,
        //控制输入框的焦点
        requestFocusOnTap: controller != null,
        width: null,
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          filled: false,
          fillColor: null,
          outlineBorder: null,
          activeIndicatorBorder: null,
          errorBorder: null,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          floatingLabelAlignment: FloatingLabelAlignment.center,
          constraints: BoxConstraints(maxHeight: kMinInteractiveDimension),
          contentPadding: EdgeInsets.zero,
        ),
        onSelected: (value) {
          onChanged?.call(value);
        },
      ),
    ].row()!;
  }

  /// [DropdownMenuEntry]
  List<DropdownMenuEntry> _buildDropdownMenuEntry(BuildContext context) {
    return [
      for (final value in dropdownValueList ?? [])
        DropdownMenuEntry(
          label: "${textOf(value, context)}",
          value: value,
          labelWidget: null,
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
/// - [DropdownButton] 系统
/// - [DropdownMenu] 系统
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
            : MaterialStatePropertyAll(widget.menuBgColor),
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
/// 内部使用[OverlayPortal]实现
/// - [CompositedTransformTarget]
/// - [CompositedTransformFollower]
///
/// - [DropdownButton] 系统
/// - [DropdownMenu] 系统
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
    return DropdownFlutter(
      enabled: widget.enabled,
      excludeSelected: widget.excludeSelected,
      hintText: widget.hintText,
      maxlines: widget.textMaxLines,
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
