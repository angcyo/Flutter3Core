part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/04
///

/// 获取随机中文英文字符串
String randomString([int? length]) {
  length ??= nextInt(1000, min: 1);
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.writeCharCode(nextInt(0x9fa5, min: 0x4e00));
  }
  return buffer.toString();
}

/// 需要翻墙才能访问
String randomImageUrl() {
  final random = Random();
  final width = random.nextInt(1000) + 100;
  final height = random.nextInt(1000) + 100;
  //return "https://picsum.photos/id/${random.nextInt(1000)}/$width/$height";
  return "https://picsum.photos/$width/$height";
}

/// 国内可以访问的占位图片, 只有纯色和文字
String randomImagePlaceholderUrl({String? text}) {
  final random = Random();
  final width = random.nextInt(1000) + 100;
  final height = random.nextInt(1000) + 100;
  //return "https://via.placeholder.com/$width/$height?text=${randomString(1)}&bg=${randomColor().toHexColor()}";
  if (text == null) {
    return "https://via.placeholder.com/$width/$height";
  } else {
    return "https://via.placeholder.com/$width/$height?text=$text";
  }
}

/// 获取一个随机的颜色
Color randomColor({int min = 120, int max = 200}) => Color.fromARGB(
      255,
      nextInt(max, min: min),
      nextInt(max, min: min),
      nextInt(max, min: min),
    );

/// 获取一个随机的[StateLogWidget]
StateLogWidget randomLogWidget(
  String text, {
  double? height,
  double fontSize = 12,
  Color? color = Colors.white,
}) =>
    StateLogWidget(
      logTag: text,
      child: randomWidget(
        text,
        height: height,
        fontSize: fontSize,
        textColor: color,
      ),
    );

/// 获取一个随机的[Widget]
Widget randomWidget(
  String text, {
  double? height,
  double fontSize = 12,
  Color? textColor = Colors.white,
}) {
  final max = platformMediaQuery().size.width;
  final h = height ?? nextDouble(min: kMinInteractiveDimension, max: max);
  //保留2位小数点
  fontSize = double.parse(fontSize.toStringAsFixed(2));
  final bgColor = randomColor();
  return Container(
    color: bgColor,
    alignment: Alignment.center,
    height: h,
    child: Text(
      "$text\nh:${h.toDigits()} c:${bgColor.toHexColor()}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
      ),
    ),
  );
}
