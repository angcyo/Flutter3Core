part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/16
///

/// 调试动作
class DebugAction {
  /// 标签
  String? label;

  /// 描述
  String? des;

  /// 普通的按钮点击事件
  ClickAction? clickAction;

  //--

  /// 自动修改hive属性
  String? hiveKey;

  /// [hiveKey]属性对应的类型
  Type? hiveType;

  /// [hiveKey]对应的默认值
  dynamic defHiveValue;

  DebugAction({
    this.label,
    this.des,
    this.clickAction,
    this.hiveKey,
    this.hiveType,
    this.defHiveValue,
  });
}

/// [DebugAction]
mixin DebugActionMixin {
  WidgetList buildClickActionList(
    BuildContext context,
    List<DebugAction> clickList,
  ) {
    return [
      for (final action in clickList)
        GradientButton.normal(() {
          action.clickAction?.call(context);
        }, child: action.label!.text()),
    ];
  }

  WidgetList buildHiveActionList(
    BuildContext context,
    List<DebugAction> hiveList,
  ) {
    //debugger();
    return [
      for (final action in hiveList)
        if (action.hiveType == String)
          LabelSingleInputTile(
              label: action.label,
              inputHint: action.des,
              inputText:
                  action.defHiveValue ?? action.hiveKey?.hiveGet<String>(),
              onInputTextChanged: (value) {
                action.hiveKey?.hivePut(value);
              })
        else if (action.hiveType == int)
          LabelNumberTile(
            label: action.label,
            des: action.des,
            value: action.defHiveValue ?? action.hiveKey?.hiveGet<int>(0) ?? 0,
            onValueChanged: (value) {
              action.hiveKey?.hivePut(value);
            },
          )
        else if (action.hiveType == double)
          LabelNumberTile(
            label: action.label,
            des: action.des,
            value: action.defHiveValue ??
                action.hiveKey?.hiveGet<double>(0.0) ??
                0.0,
            onValueChanged: (value) {
              action.hiveKey?.hivePut(value);
            },
          )
        else if (action.hiveType == bool)
          LabelSwitchTile(
              label: action.label,
              des: action.des,
              value: action.defHiveValue ??
                  action.hiveKey?.hiveGet<bool>(false) == true,
              onValueChanged: (value) {
                action.hiveKey?.hivePut(value);
              })
        else
          "不支持的类型:${action.label}:[${action.hiveType}]".text(),
    ];
  }
}
