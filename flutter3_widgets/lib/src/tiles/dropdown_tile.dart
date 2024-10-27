part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///
/// 下拉按钮菜单tile, 使用[PopupRoute]实现
/// [DropdownButtonTile]
/// [DropdownMenuTile]
class DropdownButtonTile extends StatelessWidget with TileMixin {
  /// 标签
  final String? label;
  final EdgeInsets? labelPadding;
  final Widget? labelWidget;

  /// Dropdown
  final dynamic dropdownValue;
  final List<dynamic>? dropdownValueList;
  final ValueChanged<dynamic>? onChanged;

  /// Dropdown2
  final Widget? icon;
  final double iconSize;

  final AlignmentGeometry alignment;

  /// [DropdownMenuItem]
  final AlignmentGeometry itemAlignment;

  ///
  final MainAxisSize? mainAxisSize;

  const DropdownButtonTile({
    super.key,
    this.label,
    this.labelWidget,
    this.labelPadding = kLabelPadding,
    this.dropdownValue,
    this.dropdownValueList,
    this.onChanged,
    this.icon,
    this.iconSize = 24.0,
    this.alignment = AlignmentDirectional.center,
    this.itemAlignment = AlignmentDirectional.centerStart,
    this.mainAxisSize,
  });

  @override
  Widget build(BuildContext context) {
    return [
      buildTextWidget(
        context,
        textWidget: labelWidget,
        text: label ?? "",
        textPadding: labelPadding,
      )?.expanded(enable: mainAxisSize != MainAxisSize.min),
      DropdownButton(
          items: _buildDropdownMenuItems(context),
          value: dropdownValue,
          //文本样式
          style: null,
          icon: icon,
          iconSize: iconSize,
          itemHeight: kMinInteractiveDimension,
          menuMaxHeight: null,
          //紧凑的高度
          isDense: false,
          isExpanded: false,
          //下划线
          underline: null,
          //下拉菜单的背景颜色
          //[ThemeData.canvasColor]
          dropdownColor: null,
          enableFeedback: true,
          alignment: alignment,
          onChanged: (value) {
            /*initialValue = value;
            updateState();*/
            onChanged?.call(value);
          }),
    ].row(mainAxisSize: mainAxisSize)!;
  }

  /// [DropdownMenuItem]
  List<DropdownMenuItem> _buildDropdownMenuItems(BuildContext context) {
    return [
      for (final value in dropdownValueList ?? [])
        DropdownMenuItem(
          value: value,
          enabled: true,
          alignment: itemAlignment,
          child: widgetOf(context, value) ?? textOf(value)!.text(),
        )
    ];
  }
}

/// 下拉输入框菜单tile, 使用[Overlay]实现
/// [DropdownMenuTile]
/// [DropdownButtonTile]
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
      )!
          .expanded(),
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
          label: "${textOf(value)}",
          value: value,
          labelWidget: null,
          leadingIcon: null,
          trailingIcon: null,
          enabled: true,
          style: null,
        )
    ];
  }
}

/// 锚点菜单tile, 使用[Overlay]实现
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
    )!
        .expanded();
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
          ? [
              label,
            ].row()?.click(() {
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
            textOf(value)!
                .text(textAlign: ui.TextAlign.start)
                .paddingSymmetric(horizontal: kX)
                .align(AlignmentDirectional.centerStart)
                .ink(() {
              widget.onChanged?.call(value);
              menuController.close();
            }).constrainedMin(minHeight: kMinInteractiveDimension),
    ];
  }
}
