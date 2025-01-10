part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/29
///
/// 提供一个文本字符串
mixin ITextProvider {
  /// 获取一个文本
  String? get provideText => null;

  /// 获取一个国际化的文本
  IntlTextBuilder? get provideIntlText =>
      provideText == null ? null : (_) => provideText!;
}

/// 提供一个Widget
mixin IWidgetProvider {
  WidgetBuilder? get provideWidget => null;
}

/// 在一个数据中, 提取文本
/// [ITextProvider]
String? textOf(dynamic data, [BuildContext? context]) {
  //debugger();
  if (data == null) {
    return null;
  }
  if (data is String ||
      data is bool ||
      data is num ||
      data is Iterable ||
      data is Map) {
    return "$data";
  }
  if (data is ITextProvider) {
    if (context != null) {
      return data.provideIntlText?.call(context) ?? data.provideText;
    }
    return data.provideText;
  } else {
    try {
      return data.provideText;
    } catch (e, s) {
      /*assert(() {
        printError(e, s);
        return true;
      }());*/
    }
  }
  if (data != null) {
    try {
      return data.text;
    } catch (e) {
      //debugger();
      assert(() {
        l.w('当前类型[${data.runtimeType}],不支持[.text]/[ITextProvider]操作.');
        return true;
      }());
      return data.toString();
    }
  }
  return null;
}

/// 在一个数据中, 提取Widget
/// [tryTextWidget] 是否尝试使用[Text]小部件
Widget? widgetOf(BuildContext context,
    dynamic data, {
      bool tryTextWidget = false,
      TextStyle? textStyle,
      TextAlign? textAlign,
    }) {
  if (data == null) {
    return null;
  }
  if (data is Widget) {
    return data;
  }
  if (data is IWidgetProvider && data.provideWidget != null) {
    return data.provideWidget?.call(context);
  } else {
    try {
      return data.provideWidget?.call(context);
    } catch (e, s) {
      /*assert(() {
        printError(e, s);
        return true;
      }());*/
    }
  }

  if (tryTextWidget) {
    final text = textOf(data, context);
    if (text != null) {
      final globalTheme = GlobalTheme.of(context);
      return text.text(
        style: textStyle ?? globalTheme.textGeneralStyle,
        textAlign: textAlign,
      );
    }
  }
  assert(() {
    l.v('当前类型[${data.runtimeType}]不支持[IWidgetProvider]操作.');
    return true;
  }());
  return null;
}

//---
