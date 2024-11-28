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
String get $uuid {
  //debugger();
  return uuid();
}

/// 等待[milliseconds]毫秒
Future wait([int milliseconds = 1]) =>
    Future.delayed(Duration(milliseconds: milliseconds));

/// 延迟执行
Future delayed([Duration? duration]) =>
    Future.delayed(duration ?? Duration(milliseconds: 1));

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
/// ```
/// throw UnimplementedError();
/// ```
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
  /// [json.decode(this)]
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

extension ObjectNullEx on Object? {
  bool get isNil => this == null || isNullOrEmpty(this);
}

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
  /// [textSpan] 富文本.[InlineSpan]->[TextSpan]
  /// ...
  /// [style] 文本样式
  /// [bold] 是否加粗[fontWeight]
  /// [lineHeight].[TextStyle.height] 行高, 默认值`1.464`附近
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
  /// [selectable] 是否可以选择文本, 使用[SelectableText]小部件实现
  /// [SelectableText]
  Widget text({
    //--
    TextSpan? textSpan,
    //--
    TextStyle? style,
    double? fontSize,
    Color? textColor,
    FontWeight? fontWeight,
    double? lineHeight,
    bool? bold /*加粗*/,
    FontStyle? fontStyle,
    String? fontFamily,
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
    if (maxLines != null) {
      overflow ??= TextOverflow.ellipsis;
    }
    if (bold == true) {
      fontWeight ??= FontWeight.bold;
    }
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

      //高亮处理
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

    //普通文本处理
    if (style != null) {
      //如果style不为空, 则使用参数覆盖style
      if (fontSize != null ||
          textColor != null ||
          fontWeight != null ||
          fontFamily != null ||
          fontStyle != null ||
          lineHeight != null) {
        style = style.copyWith(
          fontSize: fontSize ?? style.fontSize,
          color: textColor ?? style.color,
          fontWeight: fontWeight ?? style.fontWeight,
          fontStyle: fontStyle ?? style.fontStyle,
          fontFamily: fontFamily ?? style.fontFamily,
          height: lineHeight ?? style.height,
        );
      }
    }

    //style参数为空, 则使用参数创建样式
    final textStyle = style ??
        (fontSize == null &&
                textColor == null &&
                fontWeight == null &&
                fontFamily == null &&
                fontStyle == null &&
                lineHeight == null
            ? null
            : TextStyle(
                fontSize: fontSize,
                color: textColor,
                fontWeight: fontWeight,
                fontStyle: fontStyle,
                fontFamily: fontFamily,
                height: lineHeight,
              ));

    if (selectable) {
      //SelectableText
      if (textSpan != null) {
        return SelectableText.rich(
          textSpan,
          style: textStyle,
          textAlign: textAlign,
          maxLines: maxLines,
        );
      }
      return SelectableText(
        "$this",
        style: textStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        /*softWrap: softWrap,
        overflow: overflow,*/
      );
    }

    //text
    if (textSpan != null) {
      return Text.rich(
        textSpan,
        style: textStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: overflow,
      );
    }
    return Text(
      "$this",
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
    );
  }
}

extension FutureEx<T> on Future<T> {
  /// 合并[Future.then]和[Future.catchError]方法
  /// [throwError] [get]中遇到的错误是否重新抛出?
  Future get([ValueErrorCallback? get, StackTrace? stack, bool? throwError]) {
    stack ??= StackTrace.current;
    return then((value) {
      try {
        //debugger();
        final data = get?.call(value, null); //这一层的错误会被捕获
        return data ?? value;
      } catch (error) {
        //debugger();
        if (throwError == true) {
          rethrow;
        } else {
          assert(() {
            l.w('FutureGet异常:$error↓');
            printError(error, stack);
            return true;
          }());
        }
        get?.call(null, error); //这一层的错误可以走正常的Future异常处理
        return null;
      }
    }, onError: (error, errorStack) {
      //此处无法捕获[get]中的异常
      if (error is RCancelException) {
        assert(() {
          l.w('操作被取消:$error');
          return true;
        }());
      } else if (error is FutureCancelException) {
        assert(() {
          l.w('Future被取消:$error');
          return true;
        }());
      } else {
        //debugger();
        if (throwError == true) {
          throw error;
        } else {
          assert(() {
            l.w('Future异常:$error↓');
            printError(error, errorStack ?? stack);
            return true;
          }());
        }
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
  /// [FutureExtensions.ignore] 完成和错误都被忽略
  void unAwait() {
    unawaited(this);
  }

  /// 忽略[Future]的错误
  Future ignoreError() async {
    try {
      await this;
    } catch (e) {
      // 忽略错误
    }
  }

  /// [initialData] 当初始化的值有值时, 不会则直接触发[builder]
  /// [FutureBuilder]
  Widget toWidget(
    Widget Function(BuildContext context, T? value) builder, {
    Widget Function(BuildContext context, dynamic error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? emptyBuilder,
    T? initialData,
  }) {
    if (initialData != null) {
      return Builder(builder: (context) => builder.call(context, initialData));
    }
    return FutureBuilder<T>(
      future: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              GlobalConfig.of(context)
                  .errorPlaceholderBuilder(context, snapshot.error);
        }
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return emptyBuilder?.call(context) ??
                GlobalConfig.of(context).emptyPlaceholderBuilder(context, null);
          } else {
            return builder.call(context, snapshot.data);
          }
        }
        return loadingBuilder?.call(context) ??
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
  /// [def] 失败后的默认颜色
  static Color fromHex(String hexString, [Color def = Colors.black]) {
    try {
      if (hexString.startsWith("0x")) {
        hexString = hexString.substring(2);
      }
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(buffer.toString().toInt(radix: 16));
    } catch (e) {
      assert(() {
        print(e);
        return true;
      }());
      return def;
    }
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
  /// [leadingHashSign] 是否包含#
  /// [includeAlpha] 是否包含透明通道
  /// [toHexColor]
  String toHex({bool leadingHashSign = true, bool includeAlpha = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : ""}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  /// 返回#ff00ff00
  /// [toHex]
  String toHexColor([bool leadingHashSign = true, bool includeAlpha = true]) =>
      toHex(leadingHashSign: leadingHashSign, includeAlpha: includeAlpha);

  /// 判断当前颜色是否是暗色
  /// [Color.computeLuminance]
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.dark;

  /// 判断当前颜色是否是亮色
  /// [Color.computeLuminance]
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

typedef StringEachCallback = dynamic Function(String element);
typedef StringIndexEachCallback = dynamic Function(int index, String element);

/// 获取剪切板的文本
/// [StringEx.copy]
Future<String?> getClipboardText() async {
  var data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text;
}

extension StringEx on String {
  /// 截取字符串, 超过[length]的部分, 会用[ellipsis]代替
  /// 系统用的时[_kEllipsis]
  String ellipsis(int? length, [String ellipsis = '\u2026']) =>
      (length != null && length < this.length)
          ? "${substring(0, length)}$ellipsis"
          : this;

  /// 转换成[DateTime]
  /// [pattern] 时间模板 'yyyy-MM-dd'
  /// ```
  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  /// DateTime toDateTime() => DateTime.parse(this);
  /// ```
  DateTime toDateTime([String? pattern = "yyyy-MM-dd HH:mm:ss"]) {
    // 解析日期字符串
    intl.DateFormat inputFormat = intl.DateFormat(pattern);
    return inputFormat.parse(this);
  }

  /// 反序字符串
  String get reversed {
    final range = Characters(this).iteratorAtEnd;
    final buffer = StringBuffer();
    while (range.moveBack()) {
      buffer.write(range.current);
    }
    return buffer.toString();
  }

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

  /// 使用base64加密当前的字符串
  /// 'Dart is open source' -> `RGFydCBpcyBvcGVuIHNvdXJjZQ==`
  String? get toBase64 => base64Encode(codeUnits);

  /// 使用base64解密当前的字符串
  String? get fromBase64 => base64Decode(this).utf8Str;

  /// 判断当前字符串是否是http协议开头
  bool get isHttpScheme {
    final lowerCase = toLowerCase();
    return lowerCase.startsWith('http://') || lowerCase.startsWith('https://');
  }

  /// 判断当前字符串是否是ip字符串
  bool get isIpStr => isMatch(r'^(\d{1,3}\.){3}\d{1,3}$');

  /// 判断当前字符串
  /// - 如果是http协议, 则直接返回
  /// - 如果是ip, 则返回 http://ip:port
  /// - 如果是域名, 则返回 http://域名.local:port
  String toLocal([int? port]) {
    port ??= 80;
    if (isHttpScheme /*isMatch(r'^https?://')*/) {
      //已经是http开头
      if (port == 80) {
        return this;
      } else {
        return '$this:$port';
      }
    } else if (isIpStr) {
      //ip
      if (port == 80) {
        return 'http://$this';
      } else {
        return 'http://$this:$port';
      }
    } else {
      //域名
      if (port == 80) {
        return 'http://$this.local';
      } else {
        return 'http://$this.local:$port';
      }
    }
  }

  /// 判断当前字符是否是数字
  bool get isNumber => isMatch(r'^\d+$');

  /// 从字符串中提取正负整数数字
  int? get getIntOrNull {
    final reg = RegExp(r'[+-]?\d+');
    final match = reg.firstMatch(this);
    return match?.group(0)?.toInt();
  }

  /// 从字符串中提取正负小数数字
  double? get getDoubleOrNull {
    final reg = RegExp(r'[+-]?\d+(\.\d+)?');
    final match = reg.firstMatch(this);
    return match?.group(0)?.toDouble();
  }

  /// 获取指定索引位置的字符串, 支持安全索引
  /// [negative] 是否要支持-索引
  String? getOrNull(int index, {bool negative = true}) {
    if (negative) {
      if (index < 0) {
        index = length + index;
      }
    }
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

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
  Color toColor([Color def = Colors.black]) => ColorEx.fromHex(this, def);

  /// 使用json解析字符串, 返回[Map], [List]数据结构
  ///
  /// 支持带有注释和尾随逗号的 JSON https://pub.dev/packages/jsonc
  dynamic jsonDecode() => json.decode(this);

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

  /// 正则表达式
  RegExp get regex => toRegex();

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
  String ensurePackagePrefix([String? package, String? prefix]) {
    if (startsWith("packages/")) {
      //指定了包名根路径
      return this;
    }
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
  /// [callback] 返回true, 中断遍历
  forEach(StringEachCallback callback) {
    for (var i = 0; i < length; i++) {
      final result = callback(this[i]);
      if (result is bool) {
        if (result) {
          break;
        }
      }
    }
  }

  /// 遍历字符串, 带索引
  /// [callback] 返回true, 中断遍历
  forEachIndex(StringIndexEachCallback callback) {
    for (var i = 0; i < length; i++) {
      final result = callback(i, this[i]);
      if (result is bool) {
        if (result) {
          break;
        }
      }
    }
  }

  /// 遍历字符串, 不带索引
  forEachByChars(StringEachCallback callback) {
    for (final element in characters) {
      final result = callback(element);
      if (result is bool) {
        if (result) {
          break;
        }
      }
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

  /// 数据不为空时, 才写入数据
  StringBuffer writeIf(Object? object) {
    if (object != null) {
      write(object);
    }
    return this;
  }

  /// 数据不为空时, 才写入数据
  StringBuffer writelnIf(Object? object) {
    if (object != null) {
      writeln(object);
    }
    return this;
  }
}

//endregion String 扩展

//region Rect/Offset/Size 扩展

extension OffsetEx on Offset {
  double get x => dx;

  double get y => dy;

  String get log =>
      "Offset(${dx.toStringAsFixed(1)}, ${dy.toStringAsFixed(1)})";

  /// [Offset]的绝对值
  Offset abs() => Offset(dx.abs(), dy.abs());

  /// 平移矩阵
  Matrix4 get translateMatrix => Matrix4.identity()..translate(dx, dy);
}

extension RectEx on Rect {
  /// [toString]
  String get log =>
      "Rect.LTRB(${left.toDigits(digits: 1)}, ${top.toDigits(digits: 1)}, ${right.toDigits(digits: 1)}, ${bottom.toDigits(digits: 1)})";

  /// [toString]
  String get logSize =>
      "Rect.LTWH(${left.toDigits(digits: 1)}, ${top.toDigits(digits: 1)}, ${width.toDigits(digits: 1)}, ${height.toDigits(digits: 1)})";

  /// 是否是有效有效的值
  /// `0/0`:Nan
  /// `0/1`:1
  /// `1/0`:Infinity
  bool get isValid => !hasNaN && !isInfinite;

  /// [Rect]的中心点
  Offset get center => Offset.fromDirection(0, width / 2) + topLeft;

  /// [Rect]的起点
  Offset get lt => Offset(left, top);

  Offset get rt => Offset(right, top);

  /// [Rect]的右下角
  Offset get rb => Offset(right, bottom);

  Offset get lb => Offset(left, bottom);

  /// 中心点对应的1dp矩形
  Rect get centerRect => center & const Size(1.0, 1.0);

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

  Rect offsetToZero() => Rect.fromLTWH(0, 0, width, height);

  ///
  Rect lerp(Rect target, double t) => Rect.lerp(this, target, t)!;

  /// 偏移矩形
  Rect offset(Offset offset) => Rect.fromLTWH(
        left + offset.dx,
        top + offset.dy,
        width,
        height,
      );

  /// 将当前矩形相对于[container]的位置, 转换成全局坐标的位置
  Rect toGlobalLocationIn(RenderObject? container) {
    if (container == null) {
      return this;
    }
    final offset = container.getGlobalLocation();
    if (offset == null) {
      return this;
    }
    return this + offset;
  }

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
  /// [value] 支持正负数
  /// [deflateValue]
  ui.Rect inflateValue(dynamic value, [bool center = true]) {
    final num l, t, r, b;
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

  /// 确保矩形具有最小的宽高大小
  Rect ensureValid({double? minWidth = 1, double? minHeight = 1}) {
    return Rect.fromLTWH(
      left,
      top,
      math.max(width, minWidth ?? width),
      math.max(height, minHeight ?? height),
    );
  }

  /// dp单位的坐标, 转换成mm单位的坐标
  @mm
  Rect toRectMm() => Rect.fromLTRB(
        left.toMmFromDp(),
        top.toMmFromDp(),
        right.toMmFromDp(),
        bottom.toMmFromDp(),
      );

  /// mm单位的坐标, 转换成dp单位的坐标
  @dp
  Rect toRectDp() => Rect.fromLTRB(
        left.toDpFromMm(),
        top.toDpFromMm(),
        right.toDpFromMm(),
        bottom.toDpFromMm(),
      );

  /// 作用一个矩阵, 并保持某个锚点在作用矩阵后不变
  /// [applyMatrix] 本次需要作用的矩阵, 会叠加在[originMatrix]上
  /// [originMatrix] 原始矩形作用的矩阵
  /// [anchor] 需要保持不动的锚点, 在(0,0)原始矩形中的坐标
  /// [limitContainerRect] 限制操作后的矩形在此矩形范围内, 不指定则不限制
  /// @return 返回保持[anchor]不变的矩形
  Rect applyMatrix(
    Matrix4 applyMatrix, {
    Offset anchor = Offset.zero,
    Matrix4? originMatrix,
    Rect? limitContainerRect,
  }) {
    //基础矩形
    final rect = Rect.fromLTWH(0, 0, width, height);
    final translateMatrix = Matrix4.identity()..translate(left, top);
    final Matrix4 beforeMatrix;
    if (originMatrix == null) {
      beforeMatrix = translateMatrix;
    } else {
      beforeMatrix = translateMatrix * originMatrix;
    }

    //锚点矩阵后的位置, 用来标识固定的目标位置
    final Offset beforeAnchor = beforeMatrix.mapPoint(anchor);

    final Matrix4 afterMatrix = beforeMatrix * applyMatrix;
    final Offset afterAnchor = afterMatrix.mapPoint(anchor);

    final afterRect = afterMatrix.mapRect(rect);
    final result = afterRect + (beforeAnchor - afterAnchor);

    if (limitContainerRect != null) {
      if (result.left < limitContainerRect.left ||
          result.top < limitContainerRect.top ||
          result.right > limitContainerRect.right ||
          result.bottom > limitContainerRect.bottom) {
        //超出边界, 则直接返回自身
        return this;
      }
    }
    return result;
  }
}

extension SizeEx on Size {
  Rect toRect([Offset? offset]) => (offset ?? Offset.zero) & this;

  /// 确保是一个有效的[Size]
  Size ensureValid({double? width, double? height}) => Size(
      this.width.ensureValid(width ?? this.width),
      this.height.ensureValid(height ?? this.height));
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
  /// 异步循环生成器
  /// 循环[this]的次数
  /// [step] 循环的步长
  /// ```
  /// await for (final _ in loop()) {
  ///   xxx;
  ///   () async {}();
  /// }
  /// ```
  /// [forceLast] 是否强制返回最后一个值
  /// [interval] 延迟间隔毫秒
  Stream<T> loop<T extends num>({
    T? step,
    bool forceLast = true,
    int? interval,
  }) async* {
    try {
      //试探一下数值的类型
      0 as T;
      //int 类型
      T value = 0 as T;
      while (value < this) {
        yield value;
        value = (value + (step ?? 1)) as T;
        if (forceLast && value >= this) {
          yield this as T;
        } else if (interval != null) {
          await Future.delayed(Duration(milliseconds: interval));
        }
      }
    } catch (e) {
      //浮点类型
      T value = 0.0 as T;
      while (value < this) {
        yield value;
        value = (value + (step ?? 1.0)) as T;
        if (forceLast && value >= this) {
          yield this as T;
        } else if (interval != null) {
          await Future.delayed(Duration(milliseconds: interval));
        }
      }
    }
  }

  ///高于60帧时, 保持60帧的刷新率
  ///三星手机会出现24帧率
  ///[refreshRate]
  double get rr =>
      refreshRate > 60.0 ? (this / (refreshRate / 60.0)) : toDouble();

  /// [num]->[double]
  double toNumDouble({
    bool? round,
    bool? ceil,
    bool? floor,
  }) {
    if (this is double) {
      return this as double;
    }
    if (ceil == true) {
      return ceilToDouble();
    }
    if (floor == true) {
      return floorToDouble();
    }
    return roundToDouble();
  }

  /// 将一个值[this].[value].[0~1]按照60帧的刷新率在一定时间[timestamp]内变化
  /// [value] 这个当前的值
  /// [timestamp] 多少毫秒变化到1, 用来计算step
  /// [reverse] 是否反向变化, 反向用-step
  /// @return ([0~1], 是否反向)
  (double progress, bool reverse) rrt(int timestamp, bool reverse) {
    num value = this;
    double result = value.toDouble();
    double step = (1000.0 / timestamp) / refreshRate;
    //debugger();
    if (reverse) {
      result -= step.rr;
    } else {
      result += step.rr;
    }
    if (result > 1.0) {
      result = 1.0;
      reverse = true;
    } else if (result < 0) {
      result = 0.0;
      reverse = false;
    }
    return (result, reverse);
  }

  /// 正负取反
  get inverted => -this;

  /// 2个数字是否同向, 同正或同负
  bool isSameSign(num other) => this * other > 0;

  //region ---math---

  /// 限制角度在[-360°~360°]
  double get jdm {
    if (this == 0) {
      return 0;
    }
    if (this > 0) {
      final degrees = this % 360;
      if (degrees <= 0) {
        return degrees + 360;
      }
      return degrees.toDouble();
    } else {
      final degrees = this % 360;
      if (degrees >= 0) {
        return degrees - 360;
      }
      return degrees.toDouble();
    }
  }

  /// 限制弧度在[-π~π]
  double get hdm {
    if (this == 0) {
      return 0;
    }
    if (this > 0) {
      final radians = this % (2 * math.pi);
      if (radians <= 0) {
        return radians + 2 * math.pi;
      }
      return radians.toDouble();
    } else {
      final radians = this % (2 * math.pi);
      if (radians >= 0) {
        return radians - 2 * math.pi;
      }
      return radians.toDouble();
    }
  }

  /// 转角度
  double get jd => toDegrees;

  /// [sanitizeDegrees]
  double get jds => toDegrees.sanitizeDegrees;

  /// 转弧度
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
  /// [round] 是否四舍五入
  /// [ensureInt] 如果是整数, 是否优先使用整数格式输出
  /// ```
  /// 8.10 -> 8.1   //removeZero
  /// 8.00 -> 8     //removeZero or ensureInt
  /// 8.10 -> 8.10  //ensureInt
  /// ```
  String toDigits({
    int digits = kDefaultDigits,
    bool removeZero = true,
    bool round = true,
    bool ensureInt = false,
  }) {
    if (ensureInt) {
      if (this is int) {
        return toString();
      } else {
        final int = round ? this.round() : toInt();
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
  bool equalTo(double other) => (this - other).abs() < precisionErrorTolerance;
}

extension IntEx on int {
  /// 取2个数的最大值
  int maxOf(int other) => math.max(this, other);

  int minOf(int other) => math.min(this, other);

  /// ascii 码转成对应的字符
  /// [IntEx.ascii]
  /// [StringEx.ascii]
  String get ascii => String.fromCharCode(this);

  /// [kHorizontal] 横向 0
  bool get isHorizontal => this == kHorizontal;

  /// [kVertical] 纵向 1
  bool get isVertical => this == kVertical;

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

  /// 当前字节数, 能表示的最大无符号整数
  int get maxUnsignedInt => (1 << 8 * this) - 1;

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
  /// 取2个数的最大值
  double maxOf(double other) => math.max(this, other);

  double minOf(double other) => math.min(this, other);

  /// 判断2个浮点数是否相等
  /// [notEqualTo]
  /// [precisionErrorTolerance]
  bool equalTo(double other, [double epsilon = precisionErrorTolerance]) =>
      (this - other).abs() < epsilon;

  /// 判断2个浮点数是否不等于
  /// [equalTo]
  bool notEqualTo(double other, [double epsilon = precisionErrorTolerance]) =>
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
  /// [double.floor] 向下取整
  /// [Picture.toImage]
  /// [Picture.toImageSync]
  int get imageInt => toInt() /*floor()*/;
}

//endregion Num 扩展

//region List 扩展

/// [ListIntEx]
/// [ListEx]
/// [IterableEx]
/// [Uint8List]
extension ListIntEx on List<int> {
  /// 转成[utf8]字符串
  /// [toStr]
  String get utf8Str => toStr();

  /// [Uint8List]转换成字符串
  /// [String.fromCharCodes]
  String toStr([Encoding codec = utf8, bool allowMalformed = true]) {
    return utf8.decode(this, allowMalformed: allowMalformed);
    //return String.fromCharCodes(this);
  }

  /// [utf8Str]
  /// [UTF-16]格式
  String get charCodes => String.fromCharCodes(this);

  String toCharCodesStr() => charCodes;

  /// [toStr]
  String decode([Encoding codec = utf8, bool allowMalformed = true]) {
    return utf8.decode(this, allowMalformed: allowMalformed);
  }

  /// [ListIntEx]
  /// hex 40位
  String sha1() => crypto.sha1.convert(this).toString();

  /// [ListIntEx]
  /// hex 64位
  String sha256() => crypto.sha256.convert(this).toString();

  /// [ListIntEx]
  /// hex 32位
  String md5() => crypto.md5.convert(this).toString();

  /// [ListIntEx]
  /// [Uint8List]
  /// `Uint8List implements List<int>, TypedData`
  ///
  /// [ByteDataEx].[ByteDataEx.bytes]
  /// [ByteData].[ByteData.buffer]->[ByteBuffer]
  /// [ByteBuffer].[ByteBuffer.asUint8List]->[List<int>]
  ///
  Uint8List get bytes => Uint8List.fromList(this);

  /// 将字节数组转成对应的流
  Stream<List<int>> get stream => Stream.fromIterable([this]);

  /// [Uint8ListImageEx.toImage]
  Future<ui.Image> toImage() => bytes.toImage();

  /// [Uint8ListImageEx.toImageFromPixels]
  Future<ui.Image> toImageFromPixels(int width, int height,
          [ui.PixelFormat format = ui.PixelFormat.rgba8888]) =>
      bytes.toImageFromPixels(width, height, format);

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
  /// [Iterable] 转成流, 之后就可以使用
  /// ```
  ///
  /// ```
  ///
  Stream<E> get stream => Stream.fromIterable(this);

  /// 最后一个元素的索引
  int get lastIndex => length - 1;

  /// 最后一个元素是否是指定的元素
  bool isLastOf(E? e) => e != null && e == lastOrNull;

  /// 查找第一个
  E? findFirst(bool Function(E element) test) {
    for (final element in this) {
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

  /// 统计满足条件的元素数量
  /// [fold]
  int count(bool Function(E element) test) => fold(0, (int count, E element) {
        return test(element) ? count + 1 : count;
      });

  /// 所有元素求和
  T sum<T extends num>(T Function(E element) test) {
    try {
      0 as T;
      return fold<T>(0 as T, (T count, E element) {
        return (count + test(element)) as T;
      });
    } catch (e) {
      return fold<T>(0.0 as T, (T count, E element) {
        return (count + test(element)) as T;
      });
    }
  }

  /// [filter]顺便转换类型
  List<R> filterCast<R>(bool Function(E element) test) =>
      where(test).cast<R>().toList();

  /// 过滤掉null
  List<R> filterNull<R>() =>
      where((element) => element != null).cast<R>().toList();

  /// 过滤debug模式的数据
  List<E> filterDebug() {
    return where((element) {
      if (element != null) {
        try {
          final debug = (element as dynamic).debug;
          if (debug) {
            return isDebug || GlobalConfig.def.isDebugFlagFn?.call() == true;
          }
          return true;
        } catch (e) {
          return true;
        }
      }
      return true;
    }).cast<E>().toList();
  }

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

  /// [map]
  Iterable<R> mapFlat<R>(Iterable<R>? Function(E element) transform) sync* {
    for (final current in this) {
      yield* transform(current) ?? [];
    }
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

  /// 平铺所有元素
  /// 压扁所有元素
  Iterable<E> flatten() {
    Iterable<E> flattenInner(Iterable<E> list) sync* {
      for (final value in list) {
        if (value is Iterable<E>) {
          yield* flattenInner(value);
        } else {
          yield value;
        }
      }
    }

    return flattenInner(this);
  }
}

/// [ListEx]
/// [IterableEx]
extension ListEx<T> on List<T> {
  /// [length]
  int size() => length;

  /// 最后一个元素的索引
  int get lastIndex => length - 1;

  /// 确保列表中, 至少有指定个数的元素, 不足时, 循环填充数据
  List<T> ensureLength(int length, [T Function(int index)? create]) {
    if (this.length >= length) {
      return this;
    }
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(create?.call(i) ?? this[i % this.length]);
    }
    return result;
  }

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

  /// 替换指定的元素
  void replace(T? element, T? newElement) {
    if (element != null && newElement != null) {
      var index = indexOf(element);
      if (index >= 0) {
        this[index] = newElement;
      }
    }
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
    Type Function(T e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      //debugger();
      final r = toElement(e);
      return r;
    }).toList(growable: growable);
  }

  /// [List]
  int? indexOfOrNull(T? element, [int start = 0]) {
    if (element == null) {
      return null;
    }
    final index = indexOf(element, start);
    if (index < 0) {
      return null;
    }
    return index;
  }

  /// [List], 支持正负索引
  T? getOrNull(int index, [T? nul]) {
    if (index < 0) {
      index = length + index;
    }
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

  /// [getByNameOrNull]
  T? getByValueOrNull(
    dynamic value, {
    bool ignoreCase = true,
  }) {
    return findFirst(
      (dynamic element) {
        try {
          return element?.value == value;
        } catch (e) {
          return false;
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
  void reset(Iterable<T>? elements) {
    clear();
    if (elements != null) {
      addAll(elements);
    }
  }

  /// 移除所有元素, 并返回移除的元素
  List<T>? removeAll(Iterable<T>? elements) {
    if (elements == null || elements.isEmpty) {
      return null;
    }
    final result = <T>[];
    for (final element in elements) {
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

  /// [Iterable.join]
  String? connect([String? separator = "", String Function(T)? covertString]) {
    Iterator<T> iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    final first =
        covertString?.call(iterator.current) ?? textOf(iterator.current);
    if (!iterator.moveNext()) return first;
    final buffer = StringBuffer(first ?? "");
    // TODO(51681): Drop null check when de-supporting pre-2.12 code.
    if (separator == null || separator.isEmpty) {
      do {
        final text =
            covertString?.call(iterator.current) ?? textOf(iterator.current);
        if (text != null) {
          buffer.write(text);
        }
      } while (iterator.moveNext());
    } else {
      do {
        final text =
            covertString?.call(iterator.current) ?? textOf(iterator.current);
        if (text != null) {
          buffer.write(text);
        }
        buffer.write(separator);
        if (text != null) {
          buffer.write(text);
        }
      } while (iterator.moveNext());
    }
    return buffer.toString();
  }

  /// 复制列表, 浅拷贝
  /// [Iterable.toList]
  List<T> copy() => [...this];

  /// 使用Json的方式, 进行深拷贝
  /// 不转换时, 返回的是[List<Map>].
  ///
  /// ```
  ///  List<Bean>? fromJsonBeanList<Bean>(Bean Function(dynamic json) map) =>
  ///  json.decode(this).map<Bean>(map).toList();
  /// ```
  /// [StringEx.fromJsonBeanList]
  List<Bean> copyWithJson<Bean>(Bean Function(dynamic json) map) {
    return jsonDecode(jsonEncode(this)).map<Bean>(map).toList();
  }
}

/// 通过指定行列索引, 计算数组的索引
int arrayIndex(int row, int column, int width) {
  return row * width + column;
}

/// 用一维数组结构 存储二维数组数据
extension ListIndexEx<T> on List<T> {
  /// 获取二维数组的指定某一行的所有数据
  /// [row] 二维数组的行, 从0开始
  /// [width] 二维数组的宽度
  List<T> getArrayLineAllData(int row, int width) {
    final result = <T>[];
    for (var column = 0; column < width; column++) {
      final index = arrayIndex(row, column, width);
      result.add(this[index]);
    }
    return result;
  }

  /// 获取二维数组的指定某一列的所有数据
  /// [column] 二维数组的列, 从0开始
  /// [height] 二维数组的高度
  List<T> getArrayColumnAllData(int column, int width, int height) {
    final result = <T>[];
    for (var row = 0; row < height; row++) {
      final index = arrayIndex(row, column, width);
      result.add(this[index]);
    }
    return result;
  }

  /// 获取二维数组中指定开始行/列, 行数量/列数量的一部分数据
  /// [startRow].[startColumn] 需要获取的开始行列,从0开始
  /// [rowCount].[columnCount] 需要获取的行列数量
  /// [width] 二维数组的宽度
  List<T> getArrayPartData(
    int startRow,
    int startColumn,
    int rowCount,
    int columnCount,
    int width,
  ) {
    final result = <T>[];
    for (var row = startRow; row < startRow + rowCount; row++) {
      for (var column = startColumn;
          column < startColumn + columnCount;
          column++) {
        final index = arrayIndex(row, column, width);
        result.add(this[index]);
      }
    }
    return result;
  }
}

/// 二维数组扩展
extension ListListEx<T> on List<List<T>> {
  /// 获取某一行的所有数据
  List<T> getArrayLineAllData(int row) {
    return this[row];
  }

  /// 获取某一列的所有数据
  List<T> getArrayColumnAllData(int column) {
    final result = <T>[];
    for (var row = 0; row < length; row++) {
      result.add(this[row][column]);
    }
    return result;
  }

  /// 获取二维数组中指定开始行/列, 行数量/列数量的一部分数据
  List<T> getArrayPartData(
    int startRow,
    int startColumn,
    int rowCount,
    int columnCount,
  ) {
    final result = <T>[];
    for (var row = startRow; row < startRow + rowCount; row++) {
      for (var column = startColumn;
          column < startColumn + columnCount;
          column++) {
        result.add(this[row][column]);
      }
    }
    return result;
  }
}

//endregion List 扩展

//region Map 扩展

extension MapEx<K, V> on Map<K, V> {
  /// 查找元素
  ({K key, V value})? find(bool Function(K key, V value) test) {
    ({K key, V value})? result;
    forEach((key, value) {
      if (test(key, value)) {
        result = (key: key, value: value);
        return;
      }
    });
    return result;
  }

  /// 如果value为null, 则移除这个key
  void removeIfNull(K key) {
    if (this[key] == null) {
      remove(key);
    }
  }

  /// 移除所有指定的keys
  void removeAllKey(Iterable<K> keys) {
    keys.forEach(remove);
  }

  /// 遍历移除所有value为null的key
  Map<K, V> removeAllNull([bool copy = false]) {
    final map = copy ? Map.from(this) : this;
    final keys = <K>[];
    map.forEach((key, value) {
      if (value == null) {
        keys.add(key);
      }
    });
    keys.forEach(map.remove);
    return map as Map<K, V>;
  }
}

//endregion Map 扩展

extension AxisDirectionEx on AxisDirection {
  /// 是否是水平方向
  bool get isHorizontal =>
      this == AxisDirection.left || this == AxisDirection.right;

  /// 是否是垂直方向
  bool get isVertical => this == AxisDirection.up || this == AxisDirection.down;
}

extension StreamBytesEx on Stream<List<int>> {
  /// 转换成List<int>
  Future<List<int>> toBytes() async {
    final bytes = <int>[];
    await for (final data in this) {
      bytes.addAll(data);
    }
    //return reduce((value, element) => [...value,...element]);
    return bytes;
  }
}
