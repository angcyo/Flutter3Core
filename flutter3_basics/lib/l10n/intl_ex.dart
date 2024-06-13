part of '../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/23
///
/// [WidgetsBinding.instance.platformDispatcher.locales]
///
/// [intl_standalone.findSystemLocale]
Future<String> findSystemLocale() {
  try {
    intl.Intl.systemLocale = intl.Intl.canonicalizedLocale(Platform.localeName);
  } catch (e) {
    return Future.value(intl.Intl.systemLocale);
  }

  //intl.Intl.withLocale('fr', () => print(intl.myLocalizedMessage()));

  //intl.BidiFormatter.RTL().wrapWithUnicode('xyz');
  //intl.BidiFormatter.RTL().wrapWithSpan('xyz');

  return Future.value(intl.Intl.systemLocale);
}

/// 系统的语言环境
/// [intl.Intl.getCurrentLocale]
String get intlSystemLocaleName {
  findSystemLocale();
  return intl.Intl.systemLocale;
}

/// 当前国际化的语言环境
String? get intlDefaultLocaleName {
  return intl.Intl.defaultLocale;
}

/// 当前国际化的语言环境
String get intlCurrentLocaleName {
  return intl.Intl.getCurrentLocale();
}

extension L10nStringEx on String {
  /// 将包含bidi的字符转换成对应的方向
  /// ```
  /// 'نوشته پارسی اینجا گذارده شود.'
  /// ```
  String wrapBidi() {
    //return intl.BidiFormatter.LTR(true).wrapWithUnicode(this);
    final visual = bidi.logicalToVisual(this);
    return String.fromCharCodes(visual);
  }

  /// [intl.Intl.message]
  /// 使用指定的name,获取对应的文本资源
  String intlMessage({
    String? defMessage,
    String? desc = '',
    Map<String, Object>? examples,
    String? locale,
    List<Object>? args,
    String? meaning,
    bool? skip,
  }) =>
      intl.Intl.message(
        defMessage ?? this,
        name: this,
        desc: desc,
        examples: examples,
        locale: locale,
        args: args,
        meaning: meaning,
        skip: skip,
      );

  /// 转换成[Locale]
  /// `const Locale('en', 'US')`
  /// `Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),`
  Locale toLocale() {
    final split = this.split('_');
    if (split.length == 1) {
      return Locale(split[0]);
    } else if (split.length == 2) {
      return Locale(split[0], split[1]);
    } else {
      return Locale(split[0], split[1]);
    }
  }
}
