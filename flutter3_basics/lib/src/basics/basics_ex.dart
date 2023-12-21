part of flutter3_basics;

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

/// 行的分隔符
/// [_newlineRegExp]
/// [Platform.lineTerminator]
String get lineSeparator =>
    Platform.lineTerminator; //Platform.isWindows ? "\r\n" : "\n";

//region Object 扩展

extension DynamicEx on dynamic {
  /// [runtimeType]
  /// [toString]
  String toRuntimeString() => "[$runtimeType]${toString()}";
}

extension ObjectEx on Object {
  /// [runtimeType]
  /// [toString]
  String toRuntimeString() => "[$runtimeType]${toString()}";

  /// [Object]的hash值
  String hash() => hashCode.toRadixString(16);

  /// [Object]的hash值
  String classHash() => "$runtimeType(${hash()})";

  /// 类型转换
  List<T> ofList<T>() => [this as T];

  /// block
  T let<T>(void Function(T it) block) {
    block(this as T);
    return this as T;
  }

  /// 转换成json字符串
  String toJsonString() => json.encode(this);

  /// 使用[Text]包裹
  Widget text({
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
  }) {
    return Text(
      "$this",
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
    );
  }
}

extension FutureEx<T> on Future<T> {
  /// [Future.then]
  Future get([ValueErrorCallback? get]) =>
      then((value) => get?.call(value, null),
          onError: (error, stackTrace) => get?.call(null, error));

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
          return builder.call(snapshot.data);
        }
        return loadingBuilder?.call() ??
            GlobalConfig.of(context).loadingIndicatorBuilder(context, null);
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
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(buffer.toString().toInt(radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  /// 返回#ff00ff00
  String toHexColor([bool leadingHashSign = true]) =>
      toHex(leadingHashSign: leadingHashSign);

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
Future<String?> getClipboardText() async {
  var data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text;
}

extension StringEx on String {
  /// 复制当前的字符串到剪切板
  Future<void> copy() async => Clipboard.setData(ClipboardData(text: this));

  /// 字符串转换成int
  int toInt({int? radix}) => int.parse(this, radix: radix);

  /// 字符串转换成int
  int? toIntOrNull({int? radix}) => int.tryParse(this, radix: radix);

  /// 字符转换成Color对象
  Color toColor() => ColorEx.fromHex(this);

  /// "yyyy-MM-dd HH:mm:ss" 转换成时间
  DateTime toDateTime() => DateTime.parse(this);

  String sha1() => utf8.encode(this).sha1();

  String sha256() => utf8.encode(this).sha256();

  String md5() => utf8.encode(this).md5();

  /// [Uri]
  /// [amendScheme] 如果解析失败, 则使用此scheme再解析一次
  /// [Uri.parse]
  /// [Uri.tryParse]
  Uri toUri([String? amendScheme]) {
    //debugger();
    final uri = Uri.tryParse(this);
    if (isNotEmpty &&
        amendScheme?.isNotEmpty == true &&
        uri?.scheme.isEmpty == true) {
      return Uri.parse("$amendScheme://$this");
    }
    return uri!;
  }

  /// [Uri]
  String decodeUri() => Uri.decodeFull(this);

  /// [Uri]
  String encodeUri() => Uri.encodeFull(this);

  /// 从json字符串中解析出对应的数据类型
  dynamic fromJson() => json.decode(this);

  /// 将`8000`转换成`8.0.0.0`
  String toVersionString() => split("").join(".");

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
      return '$before$prefix$this';
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

  ///[GlobalConfigEx.openWebUrl]
  Future<bool> openUrl([BuildContext? context]) => openWebUrl(this, context);
}

//endregion String 扩展

//region Rect 扩展

extension RectEx on Rect {
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

  /// 偏移矩形
  Rect offset(Offset offset) => Rect.fromLTWH(
        left + offset.dx,
        top + offset.dy,
        width,
        height,
      );

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
}

//endregion Rect 扩展

//region Size 扩展

extension SizeEx on Size {
  Rect toRect([Offset? offset]) => (offset ?? Offset.zero) & this;
}

//endregion Size 扩展

//region Int 扩展

extension NumEx on num {
  /// 保留小数点后几位
  /// [digits] 小数点后几位
  /// [removeZero] 是否移除小数点后面的0
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
    }

    // 直接转出来的字符串, 会有小数点后面的0
    var value = toStringAsFixed(digits);
    // 去掉小数点后面的0
    if (value.contains('.')) {
      while (value.endsWith('0')) {
        value = value.substring(0, value.length - 1);
      }
      if (value.endsWith('.')) {
        value = value.substring(0, value.length - 1);
      }
    }
    return value;
  }

  /// 在两个数字之间线性插值，通过 b外推因子 t。
  /// [progress] [0~1]
  /// [lerpDouble]
  num lerp(double begin, double end, double progress) {
    return begin + (end - begin) * progress;
  }
}

//endregion Int 扩展

//region Int 扩展

extension IntEx on int {
  /// 转换成颜色
  /// [Color]
  Color toColor() => Color(this);

  /// 将13位毫秒时间, 拆成对应的
  /// 0:多少毫秒
  /// 1:多少秒
  /// 2:多少分
  /// 3:多少小时
  /// 4:多少天
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
}

extension DoubleEx on double {
  /// 弧度转角度
  double get toDegrees => this * 180 / pi;

  /// 角度转弧度
  double get toRadians => this * pi / 180;
}

/// [Uint8List]
extension ListIntEx on List<int> {
  /// [Uint8List]转换成字符串
  String toStr([Utf8Codec codec = utf8, bool allowMalformed = true]) {
    return utf8.decode(this, allowMalformed: allowMalformed);
    //return String.fromCharCodes(this);
  }

  String sha1() => crypto.sha1.convert(this).toString();

  String sha256() => crypto.sha256.convert(this).toString();

  String md5() => crypto.md5.convert(this).toString();
}

extension IterableEx on Iterable {
  /// [Iterable]转换成[Type]的[Iterable]
  Iterable<Type> toTypeIterable<Type>() {
    return map((e) => e as Type);
  }

  /// [List]转换成[Type]的[List]
  List<Type> toTypeList<Type>({bool growable = false}) {
    return map((e) => e as Type).toList(growable: growable);
  }

  /// 映射类型转换成[Type]的[List]
  /// [IterableEx.mapToList]
  /// [ListEx.mapToList]
  List<Type> mapToList<Type>(
    Type Function(dynamic e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      debugger();
      var r = toElement(e);
      return r;
    }).toList(growable: growable);
  }
}

extension ListEx on List<dynamic> {
  /// 最后一个元素的索引
  int get lastIndex => length - 1;

  /// 映射类型转换成[Type]的[List]
  /// [IterableEx.mapToList]
  /// [ListEx.mapToList]
  List<Type> mapToList<Type>(
    Type Function(dynamic e) toElement, {
    bool growable = false,
  }) {
    return map<Type>((e) {
      debugger();
      var r = toElement(e);
      return r;
    }).toList(growable: growable);
  }

  /// [List]
  T? getOrNull<T>(int index, [T? nul]) {
    if (index < 0 || index >= length) {
      return nul;
    }
    return this[index];
  }

  /// [List]
  T get<T>(int index, T def) {
    if (index < 0 || index >= length) {
      return def;
    }
    return this[index];
  }
}

//endregion Int 扩展
