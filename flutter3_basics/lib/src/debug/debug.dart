part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/04
///

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
