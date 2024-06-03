part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//const kDebugMode = bool.fromEnvironment("dart.vm.product") == false;
/// 默认的小数点后几位
const kDefaultDigits = 2;

/// 一天的毫秒数
const kDay = 24 * 60 * 60 * kSecond;

/// 一小时的毫秒数
const kHour = 60 * 60 * kSecond;

/// 一分钟的毫秒数
const kMinute = 60 * kSecond;

/// 一秒的毫秒数
const kSecond = 1000;

/// [uuid]
String get $uuid => uuid();

/// ```
/// // Generate a v1 (time-based) id
/// uuid.v1(); // -> '6c84fb90-12c4-11e1-840d-7b25c5ee775a'
///
/// // Generate a v4 (random) id
/// uuid.v4(); // -> '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
///
/// // Generate a v5 (namespace-name-sha1-based) id
/// uuid.v5(Uuid.NAMESPACE_URL, 'www.google.com'); // -> 'c74a196f-f19d-5ea9-bffd-a2742432fc9c'
/// ```
//String get uuid => uuidOrigin(true);
String uuid([bool trim = true]) {
  var v4 = const Uuid().v4();
  if (trim) {
    v4 = v4.replaceAll("-" /*RegExp(r'-')*/, '');
  }
  return v4;
}

/// [UniqueKey]
/// [868497392] 28位
int get uniqueId => UniqueKey().hashCode;

/// [4219854331] 32位
int get microsecondsId => DateTime.now().microsecondsSinceEpoch & 0xFFFFFFFF;

/// 行的分隔符
/// [_newlineRegExp]
/// [Platform.lineTerminator]
String get lineSeparator =>
    Platform.lineTerminator; //Platform.isWindows ? "\r\n" : "\n";

/// [WidgetBuilder]
/// [WidgetErrorBuilder]
typedef WidgetErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

//region Object 扩展

/// 动态[dynamic]的扩展, 只是在编译的时候有代码提示,
/// 最终还是要对应的类型上有方法才行, 否则会抛异常.
extension DynamicEx on dynamic {
  /// [DynamicEx.fromJson]
  /// [ObjectEx.fromJson]
  /// [StringEx.fromJson]
  /// [JsonDecoder]
  /// [JsonEncoder]
  /// [encode]
  /// [_defaultToEncodable]
  /// 从json字符串中解析出对应的数据类型
  dynamic fromJson() => toString().fromJson();

  /// 请在具体的类型上实现[toJson]方法, 否则会抛异常
  /// 此方法通常返回的是Map<String, dynamic>类型
  dynamic toJson() => this.toJson();

  /// 直接转成json字符串
  /// [toJsonString]
  String toJsonString() => (this as Object).toJsonString(null);

  /// [runtimeType]
  /// [toString]
  /// [classHash]
  String toRuntimeString() => "[$runtimeType]${toString()}";
}

final int __int64MaxValue = double.maxFinite.toInt();

extension ObjectEx on Object {
  /// 弱引用
  WeakReference<T> toWeakRef<T extends Object>() => WeakReference<T>(this as T);

  /// [runtimeType]
  /// [toString]
  String toRuntimeString() => "[$runtimeType]${toString()}";

  /// [Object]的hash值
  String hash() => hashCode.toRadixString(16);

  /// [Object]的hash值
  String classHash() => "$runtimeType(${hash()})";

  ld() {
    assert(() {
      l.d(this);
      return true;
    }());
  }

  li() {
    assert(() {
      l.i(this);
      return true;
    }());
  }

  lw() {
    assert(() {
      l.w(this);
      return true;
    }());
  }

  le() {
    assert(() {
      l.e(this);
      return true;
    }());
  }

  /// 类型转换
  List<T> ofList<T>() => [this as T];

  /// 转换成json字符串
  /// ```
  /// @JsonKey(ignore: true)
  /// @JsonKey(includeFromJson: false, includeToJson: false)
  /// ```
  /// [indent] 缩进后就是多行输出, 如果不指定则是单行输出.
  /// 所有的类型, 必须实现`toJson`这个方法, 否则会报错.
  ///
  /// [json]
  /// [JsonKey]
  /// [jsonDecode]
  /// [jsonEncode]
  String toJsonString([String? indent = '  ']) =>
      JsonEncoder.withIndent(indent).convert(this);

  /// [DynamicEx.fromJson]
  /// [ObjectEx.fromJson]
  /// [StringEx.fromJson]
  /// 从json字符串中解析出对应的数据类型
  dynamic fromJson() => toString().fromJson();

  /// 使用[Text]包裹
  ///
  /// [style] 文本样式
  /// ...
  /// [highlight] 需要高亮的文本
  /// [highlightList] 需要高亮的文本列表
  /// [caseSensitive] 是否区分大小写
  /// [words] 是否只匹配单词(匹配完整的单词)
  /// ...
  /// [Text]
  /// [RichText]
  /// https://pub.dev/packages/substring_highlight
  /// https://pub.dev/packages/highlightable
  /// https://pub.dev/packages/search_highlight_text
  ///
  /// [selectable] 是否可以选择文本
  /// [SelectableText]
  Widget text({
    TextStyle? style,
    double? fontSize,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    String? highlight,
    Color? highlightColor,
    TextStyle? highlightTextStyle,
    List<String>? highlightList,
    bool caseSensitive = false,
    String wordDelimiters = ' .,;?!<>[]~`@#\$%^&*()+-=|\/_',
    // default is to match substrings (hence the package name!)
    bool words = false,
    bool selectable = false,
  }) {
    //使用正则匹配高亮文本
    if (!isNullOrEmpty(highlight) || !isNullOrEmpty(highlightList)) {
      highlightTextStyle ??=
          style?.copyWith(color: highlightColor ?? Colors.red);

      final String text = toString();
      final String textLC = caseSensitive ? text : text.toLowerCase();

      // corner case: if both term and terms array are passed then combine
      final List<String> termList = [highlight ?? '', ...?highlightList];

      // remove empty search terms ('') because they cause infinite loops
      final List<String> termListLC = termList
          .where((s) => s.isNotEmpty)
          .map((s) => caseSensitive ? s : s.toLowerCase())
          .toList();

      List<InlineSpan> children = [];

      int start = 0;
      int idx = 0; // walks text (string that is searched)
      while (idx < textLC.length) {
        // print('=== idx=$idx');
        nonHighlightAdd(int end) => children.add(TextSpan(
            text: text.substring(start, end), style: highlightTextStyle));

        // find index of term that's closest to current idx position
        int iNearest = -1;
        int idxNearest = __int64MaxValue;
        for (int i = 0; i < termListLC.length; i++) {
          // print('*** i=$i');
          int at;
          if ((at = textLC.indexOf(termListLC[i], idx)) >= 0) //MAGIC//CORE
          {
            // print('idx=$idx i=$i at=$at => FOUND: ${termListLC[i]}');

            if (words) {
              if (at > 0 &&
                  !wordDelimiters.contains(
                      textLC[at - 1])) // is preceding character a delimiter?
              {
                // print('disqualify preceding: idx=$idx i=$i');
                continue; // preceding character isn't delimiter so disqualify
              }

              int followingIdx = at + termListLC[i].length;
              if (followingIdx < textLC.length &&
                  !wordDelimiters.contains(textLC[
                      followingIdx])) // is character following the search term a delimiter?
              {
                // print('disqualify following: idx=$idx i=$i');
                continue; // following character isn't delimiter so disqualify
              }
            }

            // print('term #$i found at=$at (${termListLC[i]})');
            if (at < idxNearest) {
              // print('PEG');
              iNearest = i;
              idxNearest = at;
            }
          }
        }

        if (iNearest >= 0) {
          // found one of the terms at or after idx
          // iNearest is the index of the closest term at or after idx that matches

          // print('iNearest=$iNearest @ $idxNearest');
          if (start < idxNearest) {
            // we found a match BUT FIRST output non-highlighted text that comes BEFORE this match
            nonHighlightAdd(idxNearest);
            start = idxNearest;
          }

          // output the match using desired highlighting
          int termLen = termListLC[iNearest].length;
          children.add(TextSpan(
              text: text.substring(start, idxNearest + termLen),
              style: highlightTextStyle));
          start = idx = idxNearest + termLen;
        } else {
          if (words) {
            idx++;
            nonHighlightAdd(idx);
            start = idx;
          } else {
            // if none match at all (ever!)
            // --or--
            // one or more matches but during this iteration there are NO MORE matches
            // in either case, add reminder of text as non-highlighted text
            nonHighlightAdd(textLC.length);
            break;
          }
        }
      }

      if (selectable) {
        return SelectableText.rich(
          TextSpan(children: children, style: highlightTextStyle),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          /*softWrap: softWrap,
          overflow: overflow,*/
        );
      }
      return Text.rich(
        TextSpan(children: children, style: highlightTextStyle),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: overflow,
      );
    }

    if (selectable) {
      return SelectableText(
        "$this",
        style: style ??
            (fontSize == null && textColor == null && fontWeight == null
                ? null
                : TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: fontWeight,
                  )),
        textAlign: textAlign,
        maxLines: maxLines,
        /*softWrap: softWrap,
        overflow: overflow,*/
      );
    }

    return Text(
      "$this",
      style: style ??
          (fontSize == null && textColor == null && fontWeight == null
              ? null
              : TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: fontWeight,
                )),
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
    );
  }
}

extension FutureEx<T> on Future<T> {
  /// 合并[Future.then]和[Future.catchError]方法
  Future get([
    ValueErrorCallback? get,
    StackTrace? stack,
  ]) {
    stack ??= StackTrace.current;
    return then((value) {
      try {
        //debugger();
        get?.call(value, null); //这一层的错误会被捕获
        return value;
      } catch (error) {
        //debugger();
        assert(() {
          l.w('FutureGet异常:$error↓');
          printError(error, stack);
          return true;
        }());
        get?.call(null, error); //这一层的错误可以走正常的Future异常处理
        return null;
      }
    }, onError: (error) {
      //此处无法捕获[get]中的异常
      //debugger();
      if (error is FutureCancelException) {
        assert(() {
          l.w('Future被取消:$error');
          return true;
        }());
      } else {
        assert(() {
          l.w('Future异常:$error↓');
          printError(error, stack);
          return true;
        }());
        get?.call(null, error);
      }
    });
  }

  /// 支持类型的[FutureEx.get]方法
  Future getValue([
    dynamic Function(T? value, dynamic error)? get,
    StackTrace? stack,
  ]) =>
      this.get((value, error) {
        if (error != null) {
          get?.call(null, error);
          return null;
        } else {
          get?.call(value, null);
          return value;
        }
      }, stack);

  /// 获取[Future]的错误信息, 有错误时, 才会触发[get]方法
  Future getError([
    dynamic Function(dynamic error)? get,
    StackTrace? stack,
  ]) =>
      this.get((value, error) {
        if (error != null) {
          get?.call(error);
        }
        return value;
      }, stack);

  /// 此方法并不能立即出发[Future]
  /// 不需要等待当前的[Future]执行完成, 但是会报告错误
  /// [ignore] 完成和错误都被忽略
  void unAwait() {
    unawaited(this);
  }

  /// [FutureBuilder]
  Widget toWidget(
    Widget Function(T? value) builder, {
    Widget Function(Object? error)? errorBuilder,
    Widget Function()? loadingBuilder,
    Widget Function()? emptyBuilder,
  }) {
    return FutureBuilder<T>(
      future: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(snapshot.error) ??
              GlobalConfig.of(context)
                  .errorPlaceholderBuilder(context, snapshot.error);
        }
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return emptyBuilder?.call() ??
                GlobalConfig.of(context).emptyPlaceholderBuilder(context, null);
          } else {
            return builder.call(snapshot.data);
          }
        }
        return loadingBuilder?.call() ??
            GlobalConfig.of(context)
                .loadingIndicatorBuilder(context, this, null);
      },
    );
  }
}

//endregion Object 扩展

//region Color 扩展

/// https://pub.dev/packages/hsluv
extension ColorEx on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    if (hexString.startsWith("0x")) {
      hexString = hexString.substring(2);
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(buffer.toString().toInt(radix: 16));
  }

  /// 默认的[value]时argb
  /// 这里返回rgba
  int get rgbaValue => red << 24 | green << 16 | blue << 8 | alpha;

  /// 在已有的透明值上进行再次透明
  /// 使用一个增量透明比例创建一个新的颜色
  /// [withOpacity]
  /// [withAlpha]
  Color withOpacityRatio(double opacity) =>
      withAlpha((alpha * opacity).round());

  /// 返回小写的十六进制字符串
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  /// [a] 是否包含透明通道
  String toHex({bool leadingHashSign = true, bool a = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${a ? alpha.toRadixString(16).padLeft(2, '0') : ""}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  /// 返回#ff00ff00
  String toHexColor([bool leadingHashSign = true, bool a = true]) =>
      toHex(leadingHashSign: leadingHashSign, a: a);

  /// 判断当前颜色是否是暗色
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.dark;

  /// 判断当前颜色是否是亮色
  bool get isLight =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light;

  /// `import 'dart:ui' as ui;`
  /// [ui.ColorFilter]
  UiColorFilter toColorFilter([BlendMode blendMode = BlendMode.srcIn]) =>
      ui.ColorFilter.mode(this, blendMode);

  /// 获取当前颜色暗一点的颜色变体
  /// [ColorScheme]
  /// [Scheme]
  Color get darkColor => HSLuvColor.fromColor(this).addLightness(-4).toColor();

  Color get lightColor => HSLuvColor.fromColor(this).addLightness(4).toColor();

  /// 获取当前颜色的禁用颜色变体
  /// [withAlpha] [0~255] 值越大, 越不透明.
  /// [withOpacity] [0~1] 值越小, 越透明.
  Color get disabledColor => withOpacity(0.6);

  /// 获取当前颜色的强调色,
  /// 值越小, 越弱调, 越暗, 黑色, min:0
  /// 值越大, 越强调, 越亮, 白色, max:100
  Color tone(int tone) => CorePalette.of(value).primary.get(tone).toColor();
}

//endregion Color 扩展

//region String 扩展

typedef StringEachCallback = void Function(String element);
typedef StringIndexEachCallback = void Function(int index, String element);

/// 获取剪切板的文本
/// [StringEx.copy]
Future<String?> getClipboardText() async {
  var data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text;
}

extension StringEx on String {
  /// 获取单字符对应的ASCII码
  /// [IntEx.ascii]
  /// [StringEx.ascii]
  int get ascii => codeUnitAt(0);

  /// 将ascii对应的int值解析出来
  /// 7e2b7dfc->2116779516
  /// [StringEx.toAsciiInt]
  /// [IntEx.toAsciiString]
  int toAsciiInt() {
    var result = 0;
    final length = this.length * 4;
    forEachIndex((index, char) {
      //7e2b7dfc
      final hex = char.toString();
      final int = hex.toHexInt();
      result = result | (int << (length - (index + 1) * 4));
    });
    return result;
  }

  /// 判断当前字符串是否是ip字符串
  bool get isIpStr => isMatch(r'^(\d{1,3}\.){3}\d{1,3}$');

  /// 快速散列函数
  /// 针对 Dart 字符串优化的 64 位哈希算法 FNV-1a
  /// https://isar.dev/zh/recipes/string_ids.html#%E5%BF%AB%E9%80%9F%E6%95%A3%E5%88%97%E5%87%BD%E6%95%B0
  int get fastHash {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < length) {
      final codeUnit = codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }
    return hash;
  }

  /// 分割文本, 并且去除空白字符
  List<String> splitAndTrim(String separator,
      {bool trim = true, bool removeEmpty = true}) {
    final list = split(separator);
    if (removeEmpty) {
      return list
          .map((e) => trim ? e.trim() : e)
          .where((element) => element.isNotEmpty)
          .toList();
    }
    return list.map((e) => trim ? e.trim() : e).toList();
  }

  /// 转换成[utf8]字节数组
  /// [byteData]
  Uint8List get bytes => utf8.encode(this);

  /// 转换成[utf8]字节数组
  /// [bytes]
  ByteData get byteData => ByteData.view(Uint8List.fromList(bytes).buffer);

  /// 重复字符串多少次[repeat]
  String operator *(int repeat) => List.filled(repeat, this).join();

  /// 接上一个字符
  String connect([String? str]) => "$this${str ?? ""}";

  /// 字符串转换成int
  int toInt({int? radix}) => int.parse(this, radix: radix);

  /// 字符串转换成int
  int? toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// 字符串转换成double
  double toDouble() => double.parse(this);

  double? toDoubleOrNull() => double.tryParse(this);

  /// 字符串转换成布尔
  bool toBool() => bool.parse(this, caseSensitive: false);

  bool? toBoolOrNull() => bool.tryParse(this, caseSensitive: false);

  /// 字符`#ffaabbcc`转换成Color对象
  Color toColor() => ColorEx.fromHex(this);

  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  DateTime toDateTime() => DateTime.parse(this);

  /// 从json字符串中解析出对应的数据类型
  /// [DynamicEx.fromJson]
  /// [ObjectEx.fromJson]
  /// [StringEx.fromJson]
  /// [JsonDecoder]
  /// [JsonEncoder]
  /// [encode]
  /// [_defaultToEncodable]
  /// [jsonDecode]
  /// 将`jsonObject`解析成`Map<String, dynamic>`类型
  /// 将`jsonArray`解析成`List<dynamic>`类型
  /// [fromJsonBeanList]
  dynamic fromJson() => json.decode(this);

  /// Bean bean = "".fromJsonBean<Bean>();
  Bean fromJsonBean<Bean>(Bean Function(dynamic json) map) =>
      map(json.decode(this));

  /// List<Bean> list = "[]".fromJsonBeanList<Bean>()`
  /// [Iterable.map]
  List<Bean>? fromJsonBeanList<Bean>(Bean Function(dynamic json) map) =>
      json.decode(this).map<Bean>(map).toList();

  /// 将`jsonArray`解析成`Iterable<dynamic>`类型
  Iterable? fromJsonIterable() => json.decode(this) as Iterable?;

  /// `List<String> list = "[]".fromJsonList<String>()`
  List<T>? fromJsonList<T>() => json.decode(this).cast<T>();

  /// [TextSpan]
  TextSpan toTextSpan({TextStyle? style}) => TextSpan(text: this, style: style);

  ///为每个字符间隔插入一个指定字符
  /// 返回新的字符串
  /// [HexStringEx.fillHexSpace]
  String insertChar(String char) {
    if (isEmpty) {
      return this;
    }
    return split('').join(char);
  }

  /// [File.readAsLines]
  /// [split]
  List<String> lines([Pattern pattern = '\n']) => split(pattern);

  //region 正则

  RegExp toRegex() => RegExp(this);

  /// 当前的文本是否正则匹配通过
  /// ```dart
  /// var string = 'Dash is a bird';
  /// var regExp = RegExp(r'(humming)?bird');
  /// var match = regExp.hasMatch(string); // true
  ///
  /// regExp = RegExp(r'dog');
  /// match = regExp.hasMatch(string); // false
  /// ```
  bool isMatch(String regex) => regex.toRegex().hasMatch(this);

  /// 获取匹配的字符串集合
  List<String> matchList(String regex) =>
      regex.toRegex().allMatches(this).map((e) => e.group(0)!).toList();

  /// 使用正则替换字符串
  String replaceAll(String regex, String replace) =>
      regex.toRegex().allMatches(this).fold(this, (previousValue, element) {
        return previousValue.replaceRange(element.start, element.end, replace);
      });

  /// [Match]
  /// [RegExpMatch]
  /// [Match.start]
  /// [Match.end]
  /// [Match.groupCount]
  Iterable<RegExpMatch> allMatches(String regex, [int start = 0]) =>
      regex.toRegex().allMatches(this, start);

  /// 通过正则匹配, 判断字符串中是否包含指定的字符
  /// [match] 是否是全匹配, 否则包含即可
  bool have(String? text, [bool match = false]) {
    if (text == null) {
      return false;
    }
    if (this == text) {
      return true;
    }
    try {
      final regex = text.toRegex();
      if (match) {
        return regex.hasMatch(this);
      } else {
        return contains(regex);
      }
    } catch (e) {
      return false;
    }
  }

  /// 使用正则, 获取字符串中所有的正负浮点数
  List<double> getFloatList() {
    const regex = r"[-+]?\d?\.?\d+";
    return allMatches(regex).map((e) => double.parse(e.group(0)!)).toList();
  }

  /// 使用正则, 获取字符串中所有的正负整数
  List<int> getIntList() {
    const regex = r"[-+]?[0-9]+";
    return allMatches(regex).map((e) => int.parse(e.group(0)!)).toList();
  }

  //endregion 正则

  //region 加密

  /// [StringEx]
  String sha1() => bytes.sha1();

  /// [StringEx]
  String sha256() => bytes.sha256();

  /// [StringEx]
  String md5() => bytes.md5();

  /// [Uri]
  String decodeUri() => Uri.decodeFull(this);

  /// [Uri]
  String encodeUri() => Uri.encodeFull(this);

  //endregion 加密

  /// 去除Url中的参数, 获取没有参数的链接
  String get baseRawUrl {
    //var uri = Uri.parse(this);
    //return uri.replace(queryParameters: null).toString();
    return split("?").first;
  }

  /// [Uri]
  /// [amendScheme] 如果解析失败, 则使用此scheme再解析一次
  /// [Uri.parse]
  /// [Uri.tryParse]
  Uri? toUri([String? amendScheme]) {
    //debugger();
    final uri = Uri.tryParse(this);
    if (isNotEmpty &&
        amendScheme?.isNotEmpty == true &&
        uri?.scheme.isEmpty == true) {
      return Uri.parse("$amendScheme://$this");
    }
    return uri;
  }

  /// 确保前缀是指定的字符串
  /// 返回新的字符串
  String ensurePrefix(String? prefix) {
    if (prefix == null || prefix.isEmpty) {
      return this;
    }
    if (!startsWith(prefix)) {
      return '$prefix$this';
    }
    return this;
  }

  /// 指定[package]的前缀
  /// [package] 包名, 比如`flutter3_basics` 或者`flutter3_core` 或者`flutter3_widgets`
  /// [prefix] 前缀, 比如`assets/images/` 或者`assets/svg/`
  /// 最终返回`packages/flutter3_basics/assets/images/xxx.xxx`
  /// `packages/flutter3_canvas/assets/svg/canvas_lock_point.svg`
  String ensurePackagePrefix(String? package, String? prefix) {
    var before = "";
    if (package == null || package.isEmpty) {
    } else {
      before = "packages/$package/";
    }
    if (prefix == null || prefix.isEmpty) {
      return '$before$this';
    }
    if (!startsWith(prefix)) {
      if (prefix.endsWith('/')) {
        return '$before$prefix$this';
      }
      return '$before$prefix/$this';
    }
    return '$before$this';
  }

  /// 确保后缀
  /// 返回新的字符串
  String ensureSuffix(String? suffix) {
    if (suffix == null || suffix.isEmpty) {
      return this;
    }
    if (!endsWith(suffix)) {
      return '$this$suffix';
    }
    return this;
  }

  //region 遍历

  /// 遍历字符串, 不带索引
  forEach(StringEachCallback callback) {
    for (var i = 0; i < length; i++) {
      callback(this[i]);
    }
  }

  /// 遍历字符串, 带索引
  forEachIndex(StringIndexEachCallback callback) {
    for (var i = 0; i < length; i++) {
      callback(i, this[i]);
    }
  }

  /// 遍历字符串, 不带索引
  forEachByChars(StringEachCallback callback) {
    for (var element in characters) {
      callback(element);
    }
  }

  /// 遍历字符串, 带索引
  forEachIndexByChars(StringIndexEachCallback callback) {
    var index = 0;
    for (var element in characters) {
      callback(index++, element);
    }
  }

  //endregion 遍历

  //region 功能

  ///[GlobalConfigEx.openWebUrl]
  Future<bool> openUrl([BuildContext? context]) => openWebUrl(this, context);

  /// 复制当前的字符串到剪切板
  /// [getClipboardText]
  Future<void> copy() async => Clipboard.setData(ClipboardData(text: this));

  /// 将`8000`转换成`8.0.0.0`
  String toVersionString() => split("").join(".");

//endregion 功能
}

extension StringBufferEx on StringBuffer {
  /// 如果[StringBuffer]为空, 则追加指定的字符串, 否则不动
  StringBuffer appendIfEmpty([String str = "\n"]) {
    if (isEmpty) {
      write(str);
    }
    return this;
  }

  /// 如果[StringBuffer]不为空, 则追加指定的字符串, 否则不动
  StringBuffer appendIfNotEmpty([String str = "\n"]) {
    if (isNotEmpty) {
      write(str);
    }
    return this;
  }
}

//endregion String 扩展

//region Rect/Offset/Size 扩展

extension OffsetEx on Offset {
  String get log =>
      "Offset(${dx.toStringAsFixed(1)}, ${dy.toStringAsFixed(1)})";

  /// [Offset]的绝对值
  Offset abs() => Offset(dx.abs(), dy.abs());
}

extension RectEx on Rect {
  /// [toString]
  String get log =>
      "Rect.LTRB(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${right.toStringAsFixed(1)}, ${bottom.toStringAsFixed(1)})";

  /// [toString]
  String get logSize =>
      "Rect.LTWH(${left.toStringAsFixed(1)}, ${top.toStringAsFixed(1)}, ${width.toStringAsFixed(1)}, ${height.toStringAsFixed(1)})";

  /// [Rect]的中心点
  Offset get center => Offset.fromDirection(0, width / 2) + topLeft;

  /// [Rect]的起点
  Offset get lt => Offset(left, top);

  Offset get rt => Offset(right, top);

  /// [Rect]的右下角
  Offset get rb => Offset(right, bottom);

  Offset get lb => Offset(left, bottom);

  Rect operator -(Offset offset) => Rect.fromLTWH(
        left - offset.dx,
        top - offset.dy,
        width,
        height,
      );

  Rect operator +(Offset offset) => Rect.fromLTWH(
        left + offset.dx,
        top + offset.dy,
        width,
        height,
      );

  /// 偏移到0,0的位置
  Rect offsetToZero() => Rect.fromLTWH(0, 0, width, height);

  /// 偏移矩形
  Rect offset(Offset offset) => Rect.fromLTWH(
        left + offset.dx,
        top + offset.dy,
        width,
        height,
      );

  /// 转换成[Path]
  Path toPath() => Path()..addRect(this);

  /// 转换成圆角矩形
  /// [RRect]
  RRect toRRect(double radius) =>
      RRect.fromRectAndRadius(this, Radius.circular(radius));

  /// [toRRect]
  RRect toRRectFromRadius(Radius radius) =>
      RRect.fromRectAndRadius(this, radius);

  /// [toRRect]
  RRect toRRectFromXY(double radiusX, double radiusY) =>
      RRect.fromRectXY(this, radiusX, radiusY);

  /// [toRRect]
  RRect toRRectFromCorners(
          {Radius topLeft = Radius.zero,
          Radius topRight = Radius.zero,
          Radius bottomRight = Radius.zero,
          Radius bottomLeft = Radius.zero}) =>
      RRect.fromRectAndCorners(
        this,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
      );

  /// [toRRect]
  RRect toRRectTB({double topRadius = 0, double bottomRadius = 0}) =>
      RRect.fromLTRBAndCorners(
        left,
        top,
        right,
        bottom,
        topLeft: Radius.circular(topRadius),
        topRight: Radius.circular(topRadius),
        bottomLeft: Radius.circular(bottomRadius),
        bottomRight: Radius.circular(bottomRadius),
      );

  /// [toRRect]
  RRect toRRectLR({double leftRadius = 0, double rightRadius = 0}) =>
      RRect.fromLTRBAndCorners(
        left,
        top,
        right,
        bottom,
        topLeft: Radius.circular(leftRadius),
        topRight: Radius.circular(rightRadius),
        bottomLeft: Radius.circular(leftRadius),
        bottomRight: Radius.circular(rightRadius),
      );

  /// [toRRect]
  RRect toRRectSymmetric({double vertical = 0, double horizontal = 0}) =>
      RRect.fromLTRBAndCorners(
        left,
        top,
        right,
        bottom,
        topLeft: Radius.circular(vertical),
        topRight: Radius.circular(horizontal),
        bottomLeft: Radius.circular(vertical),
        bottomRight: Radius.circular(horizontal),
      );

  /// 将一个点扩展到矩形中, 返回一个新的矩形
  /// [expandToInclude]
  /// [deflate]
  ui.Rect union(Offset point) {
    return Rect.fromLTRB(
      math.min(left, point.dx),
      math.min(top, point.dy),
      math.max(right, point.dx),
      math.max(bottom, point.dy),
    );
  }

  /// 将一个矩形内缩一定的大小, 返回一个新的矩形
  /// [center] 是否居中缩放
  /// [deflate]
  /// [inflate]
  /// [value] 支持[Offset]和[num]
  ///
  /// [inflateValue]
  ui.Rect deflateValue(dynamic value, [bool center = true]) {
    final l, t, r, b;
    if (value is Rect) {
      l = value.left;
      t = value.top;
      r = value.right;
      b = value.bottom;
    } else if (value is EdgeInsets) {
      l = value.left;
      t = value.top;
      r = value.right;
      b = value.bottom;
    } else if (value is Offset) {
      l = value.dx;
      t = value.dy;
      r = value.dx;
      b = value.dy;
    } else if (value is num) {
      l = value;
      t = value;
      r = value;
      b = value;
    } else {
      l = 0;
      t = 0;
      r = 0;
      b = 0;
    }

    if (center) {
      return Rect.fromLTRB(
        left + l,
        top + t,
        right - r,
        bottom - b,
      );
    }
    return Rect.fromLTWH(
      left,
      top,
      width - l - r,
      height - t - b,
    );
  }

  /// 将一个矩形向外扩一定的大小, 返回一个新的矩形
  /// [deflateValue]
  ui.Rect inflateValue(dynamic value, [bool center = true]) {
    final l, t, r, b;
    if (value is Rect) {
      l = value.left;
      t = value.top;
      r = value.right;
      b = value.bottom;
    } else if (value is EdgeInsets) {
      l = value.left;
      t = value.top;
      r = value.right;
      b = value.bottom;
    } else if (value is Offset) {
      l = value.dx;
      t = value.dy;
      r = value.dx;
      b = value.dy;
    } else if (value is num) {
      l = value;
      t = value;
      r = value;
      b = value;
    } else {
      l = 0;
      t = 0;
      r = 0;
      b = 0;
    }

    if (center) {
      return Rect.fromLTRB(
        left - l,
        top - t,
        right + r,
        bottom + b,
      );
    }
    return Rect.fromLTWH(
      left - l,
      top - t,
      width + l + r,
      height + t + b,
    );
  }

  /// dp单位的坐标, 转换成mm单位的坐标
  @mm
  Rect toRectMM() => Rect.fromLTRB(
        left.toMmFromDp(),
        top.toMmFromDp(),
        right.toMmFromDp(),
        bottom.toMmFromDp(),
      );
}

extension SizeEx on Size {
  Rect toRect([Offset? offset]) => (offset ?? Offset.zero) & this;
}

//endregion Rect/Offset/Size 扩展

//region bool 扩展

extension BoolEx on bool {
  /// 转换成对错字符显示
  /// 对错字符
  /// https://manual.toulan.fun/posts/macos-type-right-wrong-symbol/
  ///
  /// ✅
  /// ❎
  /// ❌
  /// ✖
  /// 红色
  /// ✘
  /// ✔︎
  /// ✓
  /// ✗
  ///
  String toDC() => this ? "✔︎" : "✘"; //if (this == true) "√" else "×"
}

//endregion bool 扩展

//region Num 扩展

/// [abs] 绝对值
/// [floor] 向下取整
/// [ceil] 向上取整
/// [round] 四舍五入
/// [truncate] 截断
extension NumEx on num {
  ///保持60帧的刷新率
  ///[refreshRate]
  double get rr => this / (refreshRate / 60.0);

  /// 正负取反
  get inverted => -this;

  //region ---math---

  /// 角度
  double get jd => toDegrees;

  /// [sanitizeDegrees]
  double get jds => toDegrees.sanitizeDegrees;

  /// 弧度
  double get hd => toRadians;

  /// [sanitizeRadians]
  double get hds => toRadians.sanitizeRadians;

  /// 弧度转角度
  double get toDegrees => this * 180 / math.pi;

  /// 弧度转角度, 并消除多余的角度, 限制角度范围在[0~360]
  /// [sanitizeDegrees]
  double get toSanitizeDegrees => toDegrees.sanitizeDegrees;

  /// 角度转弧度
  /// 0 = 0
  /// 15 = 0.2617993877991494
  /// 30 = 0.5235987755982988
  /// 45 = 0.7853981633974483
  /// 60 = 1.0471975511965976
  /// 90 = 1.5707963267948966
  /// 180 = 3.141592653589793
  /// 270 = 4.71238898038469
  /// 360 = 6.283185307179586
  double get toRadians => this * math.pi / 180;

  /// 消除多余的角度和负数角度, 限制角度范围在[0~360]
  double get sanitizeDegrees {
    if (this == 0) {
      return 0;
    }
    var degrees = this % 360;
    if (degrees <= 0) {
      degrees += 360;
    }
    return degrees.toDouble();
  }

  /// 消除多余的弧度和负数弧度, 限制弧度范围在[0~2π]
  double get sanitizeRadians {
    if (this == 0) {
      return 0;
    }
    var radians = this % (2 * math.pi);
    if (radians <= 0) {
      radians += 2 * math.pi;
    }
    return radians.toDouble();
  }

  /// N次方
  dynamic pow(num exponent) => math.pow(this, exponent);

  /// 开平方
  dynamic get sqrt => math.sqrt(this);

  //endregion ---math---

  /// 保留小数点后几位
  /// [digits] 小数点后几位
  /// [removeZero] 是否移除小数点尾部后面的0
  /// [ensureInt] 如果是整数, 是否优先使用整数格式输出
  /// ```
  /// 8.10 -> 8.1   //removeZero
  /// 8.00 -> 8     //removeZero or ensureInt
  /// 8.10 -> 8.10  //ensureInt
  /// ```
  String toDigits({
    int digits = kDefaultDigits,
    bool removeZero = true,
    bool ensureInt = false,
  }) {
    if (ensureInt) {
      if (this is int) {
        return toString();
      } else {
        var int = toInt();
        if (this == int) {
          return int.toString();
        }
      }
    } else if (this is int) {
      return toString();
    }

    // 直接转出来的字符串, 会有小数点后面的0. -0.000000
    String value = toStringAsFixed(digits);
    /*if (value.startsWith("-")) {
      debugger();
    }*/
    // 去掉小数点后面的0
    if (removeZero) {
      if (value.toDouble() == 0) {
        return '0';
      }
      if (value.contains('.')) {
        while (value.endsWith('0')) {
          value = value.substring(0, value.length - 1);
        }
        if (value.endsWith('.')) {
          value = value.substring(0, value.length - 1);
        }
      }
    }
    return value;
  }

  /// 在两个数字之间线性插值，通过 b外推因子 t。
  /// [progress] [0~1]
  /// [lerpDouble]
  dynamic lerp(dynamic begin, dynamic end, double progress) {
    return begin + (end - begin) * progress;
  }

  /// 限制数字的范围
  dynamic clamp(dynamic min, dynamic max) {
    return this < min ? min : (this > max ? max : this);
  }

  /// 检查此双精度值是否等于 other，避免浮点错误。
  /// [precisionErrorTolerance] 误差范围
  bool equalTo(double other) => (this - other).abs() < 0.0000001;
}

extension IntEx on int {
  /// ascii 码转成对应的字符
  /// [IntEx.ascii]
  /// [StringEx.ascii]
  String get ascii => String.fromCharCode(this);

  /// 获取对应的无符号的整型
  int get uint => this & 0xFFFFFFFF;

  /// 2116779516 -> 7E2B7DFC
  /// 将一个int用ascii字符表示出来
  /// [this] 输入的值
  /// [length] 需要输出多少个ascii字符, 4位一个ascii字符
  /// [StringEx.toAsciiInt]
  /// [IntEx.toAsciiString]
  String toAsciiString([int length = 32 ~/ 4]) {
    final list = <String>[];
    for (var i = 0; i < length; i++) {
      //每4位取一次值
      int char = (this >>> (i * 4)) & 0xF;
      //再转成十六进制, 这样就可以限定值为[0~F]
      final hex = char.toHex();
      list.add(hex.substring(1));
    }
    return list.reversed.join("");
  }

  /// [FileSizeEx.toSizeStr]
  String toSizeStr([int round = 2, String space = ""]) {
    return filesize(this, round);
  }

  /// 从整型数中取第[bit]位的数
  /// [bit] 从右往左, 第几位, 1开始
  int bit(int bit) => (this >> (math.max(bit, 1) - 1)) & 0x1;

  /// 是否有指定的标志位
  bool have(int flag) {
    if (this == 0 && flag == 0) {
      return true;
    } else if (this == 0 || flag == 0) {
      return false;
    } else if ((this > 0 && flag < 0) || (this < 0 && flag > 0)) {
      return false;
    } else {
      return (this & flag) == flag;
    }
  }

  /// 添加一个标志位
  int add(int flag, [bool add = true]) => add ? this | flag : remove(flag);

  /// 移除一个标志位
  int remove(int flag) => this & ~flag;

  /// 转换成颜色
  /// [Color]
  Color toColor() => Color(this);

  /// 转换成十六进制颜色
  String toHexColor({bool leadingHashSign = true, bool a = true}) =>
      toColor().toHexColor(leadingHashSign, a);

  /// 将13位毫秒时间, 拆成对应的
  /// 0:多少毫秒
  /// 1:多少秒
  /// 2:多少分
  /// 3:多少小时
  /// 4:多少天
  /// [IntEx.toPartTimes]
  /// [TimeEx.toTimeAgo]
  List<int> toPartTimes() {
    var list = <int>[];
    var time = this;
    var day = time ~/ kDay;
    time = time % kDay;
    var hour = time ~/ kHour;
    time = time % kHour;
    var minute = time ~/ kMinute;
    time = time % kMinute;
    var second = time ~/ kSecond;
    time = time % kSecond;
    var millisecond = time;
    list.add(millisecond);
    list.add(second);
    list.add(minute);
    list.add(hour);
    list.add(day);
    return list;
  }

  /// 将整型转换u8列表
  /// [length] 需要输出的字节长度
  List<int> toUint8List([int length = 4]) {
    final list = <int>[];
    for (var i = 0; i < length; i++) {
      list.add((this >> (i * 8)) & 0xFF);
    }
    return list.reversed.toList();
  }
}

extension DoubleEx on double {
  /// 判断2个浮点数是否相等
  /// [notEqualTo]
  bool equalTo(double other, [double epsilon = 1e-8]) =>
      (this - other).abs() < epsilon;

  /// 判断2个浮点数是否不等于
  /// [equalTo]
  bool notEqualTo(double other, [double epsilon = 1e-8]) =>
      (this - other).abs() >= epsilon;

  /// 判断浮点数是否是一个有效的数值
  /// `0/0`:Nan
  /// `0/1`:1
  /// `1/0`:Infinity
  bool get isValid => !isNaN && !isInfinite;

  /// 确保浮点数是一个有效的数
  double ensureValid([double def = 0]) => isValid ? this : def;

  /// 四舍五入
  /// [double.round] 四舍五入
  /// [double.ceil] 向上取整
  /// [Picture.toImage]
  /// [Picture.toImageSync]
  int get imageInt => round();
}

//endregion Num 扩展

//region List 扩展

/// [ListIntEx]
/// [ListEx]
/// [IterableEx]
/// [Uint8List]
extension ListIntEx on List<int> {
  /// [Uint8List]转换成字符串
  /// [String.fromCharCodes]
  String toStr([Encoding codec = utf8, bool allowMalformed = true]) {
    return utf8.decode(this, allowMalformed: allowMalformed);
    //return String.fromCharCodes(this);
  }

  /// [toStr]
  String decode([Encoding codec = utf8, bool allowMalformed = true]) {
    return utf8.decode(this, allowMalformed: allowMalformed);
  }

  /// [ListIntEx]
  String sha1() => crypto.sha1.convert(this).toString();

  /// [ListIntEx]
  String sha256() => crypto.sha256.convert(this).toString();

  /// [ListIntEx]
  String md5() => crypto.md5.convert(this).toString();

  /// [ListIntEx]
  /// [Uint8List]
  /// `Uint8List implements List<int>, TypedData`
  Uint8List get bytes => Uint8List.fromList(this);

  /// 将字节数组转成对应的整型数字
  /// [length] 需要用几个字节来转换
  /// [endian] 大小端, 默认大端: 低位在前, 高位在后. 读取的时候先读取来的在高位
  int toInt([int length = 4, Endian endian = Endian.big]) {
    length = clamp(length, 0, size());
    if (endian == Endian.big) {
      var value = 0;
      for (var i = 0; i < length; i++) {
        value += (this[i] & 0xff) << (8 * (length - i - 1));
      }
      return value;
    } else {
      var value = 0;
      for (var i = 0; i < length; i++) {
        value += (this[i] & 0xff) << (8 * i);
      }
      return value;
    }
  }
}

/// [ListEx]
/// [IterableEx]
extension IterableEx<E> on Iterable<E> {
  /// 最后一个元素的索引
  int get lastIndex => length - 1;

  /// 最后一个元素是否是指定的元素
  bool isLastOf(E? e) => e != null && e == lastOrNull;

  /// 查找第一个
  E? findFirst(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  /// 查找最后一个
  E? findLast(bool Function(E element) test) {
    for (var i = lastIndex; i >= 0; i--) {
      var element = elementAt(i);
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  /// 过滤元素, 返回满足条件的新列表
  /// [test] 返回true, 则保留元素
  /// [WhereIterable]
  List<E> filter(bool Function(E element) test) => where(test).toList();

  /// 过滤掉null
  List<R> filterNull<R>() =>
      where((element) => element != null).cast<R>().toList();

  /// 所有的元素是否都满足条件
  /// [every]
  bool all(bool Function(E element) test) => every(test);

  /// 过滤到新的列表中
  /// [WhereIterable]
  /// [List]
  List<E> whereToList(bool Function(dynamic) test) =>
      where(test).cast<E>().toList();

  /// [Iterable]转换成[Type]的[Iterable]
  Iterable<Type> toTypeIterable<Type>() {
    return map((e) => e as Type);
  }

  /// [List]转换成[Type]的[List]
  List<Type> toTypeList<Type>({bool growable = false}) {
    return map((e) => e as Type).toList(growable: growable);
  }

  /// 映射类型转换成[Type]的[List]
  /// [MappedIterable]
  /// [IterableEx.mapToList]
  /// [ListEx.mapToList]
  List<Type> mapToList<Type>(
    Type Function(dynamic e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      //debugger();
      var r = toElement(e);
      return r;
    }).toList(growable: growable);
  }

  /// 复制一份, 浅拷贝
  /// [growable] 是否可变, 不可变的列表, 不能操作元素
  /// `Cannot remove from a fixed-length list`
  List<E> clone([
    bool growable = false,
  ]) =>
      toList(growable: growable);

  /// 将当前的列表和新的列表进行合并, 去除重复的元素, 添加新的元素, 返回新的列表
  List<E> merge(Iterable<E> elements) {
    final result = toList(growable: true);
    for (var element in elements) {
      if (!result.contains(element)) {
        result.add(element);
      }
    }
    return result;
  }

  /// 带索引的[map]
  Iterable<T> mapIndex<T>(T Function(E element, int index) toElement) {
    var index = 0;
    return map((e) => toElement(e, index++));
  }
}

/// [ListEx]
/// [IterableEx]
extension ListEx<T> on List<T> {
  /// [length]
  int size() => length;

  /// 最后一个元素的索引
  int get lastIndex => length - 1;

  /// [StatelessWidget]->[ScrollView]->[BoxScrollView]->[ListView]
  ListView toListView(
    Widget Function(BuildContext context, T element, int index) itemBuilder, {
    Axis scrollDirection = Axis.vertical,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      itemCount: length,
      scrollDirection: scrollDirection,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        return itemBuilder(context, this[index], index);
      },
    );
  }

  /// 添加一个元素, 如果为null则不添加
  void addIfNotNull(T? element) {
    if (element != null) {
      add(element);
    }
  }

  /// 映射类型转换成[Type]的[List]
  /// [IterableEx.mapToList]
  /// [ListEx.mapToList]
  List<Type> mapToList<Type>(
    Type Function(dynamic e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      //debugger();
      var r = toElement(e);
      return r;
    }).toList(growable: growable);
  }

  /// [List]
  T? getOrNull(int index, [T? nul]) {
    if (index < 0 || index >= length) {
      return nul;
    }
    return this[index];
  }

  /// [List]
  T get(int index, T def) {
    if (index < 0 || index >= length) {
      return def;
    }
    return this[index];
  }

  /// [List]
  /// [getByName]
  /// [getByNameOrNull]
  T getByName(
    String? name,
    T def, {
    bool ignoreCase = true,
  }) {
    if (name == null || name.isEmpty) {
      return def;
    }
    return getByNameOrNull(name, ignoreCase: ignoreCase) ?? def;
  }

  /// [List]
  /// [ignoreCase] 是否忽略大小写
  /// [getByName]
  /// [getByNameOrNull]
  T? getByNameOrNull(
    String? name, {
    bool ignoreCase = true,
  }) {
    return findFirst(
      (element) {
        if (element is Enum) {
          return ignoreCase
              ? element.name.toLowerCase() == name?.toLowerCase()
              : element.name == name;
        } else {
          return ignoreCase
              ? "$element".toLowerCase() == name?.toLowerCase()
              : "$element" == name;
        }
      },
    );
  }

  /// 判断2个List是否至少有一个相同的元素
  /// 交叉的数据
  bool hasSameElement(List? list) {
    if (list == null || list.isEmpty || isEmpty) {
      return false;
    }
    return any((element) => list.contains(element));
  }

  ///如果列表不为空时, 则删除第一个元素
  T? removeFirstIfNotEmpty() {
    if (isNotEmpty) {
      return removeAt(0);
    }
    return null;
  }

  ///如果列表不为空时, 则删除最后一个元素
  T? removeLastIfNotEmpty() {
    if (isNotEmpty) {
      return removeLast();
    }
    return null;
  }

  /// 重置列表的元素
  void reset(Iterable<T> elements) {
    clear();
    addAll(elements);
  }

  /// 移除所有元素, 并返回移除的元素
  List<T> removeAll(Iterable<T> elements) {
    final result = <T>[];
    for (var element in elements) {
      if (contains(element)) {
        if (remove(element)) {
          result.add(element);
        }
      }
    }
    return result;
  }

  /// 切片, 保证索引不越界. [start~end)
  /// [sublist] 系统的切片方法
  List<T> subList(int start, [int? end]) {
    start = clamp(start, 0, length);
    if (end == null) {
      return sublist(start);
    }
    end = clamp(end, start, length);
    return sublist(start, end);
  }

  /// [subList]
  List<T> subListCount(int start, int count) => subList(start, start + count);

  /// 获取指定元素的下一个元素
  T? nextOf(T element) {
    var index = indexOf(element);
    if (index == -1) {
      return null;
    }
    index++;
    if (index >= length) {
      return null;
    }
    return this[index];
  }

  T? afterOf(T element) => nextOf(element);

  /// 获取指定元素的上一个元素
  T? previousOf(T element) {
    var index = indexOf(element);
    if (index == -1) {
      return null;
    }
    index--;
    if (index < 0) {
      return null;
    }
    return this[index];
  }

  T? beforeOf(T element) => previousOf(element);

  /// 每多少个数字, 分一段数据
  /// [count] 每多少个数字, 分一段数据
  List<List<T>> split(int count) {
    if (count <= 0) {
      return [];
    }
    var list = <List<T>>[];
    for (var i = 0; i < length; i += count) {
      list.add(subList(i, i + count));
    }
    return list;
  }

  /// 每多少个数字, 分一段数据
  /// [count] 每多少个数据, 分一段数据, 返回多段数据
  List<List<T>> splitByCount(int count) {
    if (count <= 0) {
      return [this];
    }
    final list = <List<T>>[];
    for (var i = 0; i < length; i += count) {
      list.add(subListCount(i, count));
    }
    return list;
  }
}

//endregion List 扩展

extension AxisDirectionEx on AxisDirection {
  /// 是否是水平方向
  bool get isHorizontal =>
      this == AxisDirection.left || this == AxisDirection.right;

  /// 是否是垂直方向
  bool get isVertical => this == AxisDirection.up || this == AxisDirection.down;
}
