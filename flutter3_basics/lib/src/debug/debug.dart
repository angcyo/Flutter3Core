part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/04
///

/// 获取一个随机的颜色
Color randomColor({int min = 120, int max = 250}) => Color.fromARGB(
      255,
      nextInt(max, min: min),
      nextInt(max, min: min),
      nextInt(max, min: min),
    );

/// 获取一个随机的[StateLogWidget]
StateLogWidget randomLogWidget(
  String text, {
  double fontSize = 12,
  Color? color,
}) =>
    StateLogWidget(
      logTag: text,
      child: randomWidget(
        text,
        fontSize: fontSize,
        color: color,
      ),
    );

/// 获取一个随机的[Widget]
Widget randomWidget(
  String text, {
  double fontSize = 12,
  Color? color,
}) =>
    Container(
      color: randomColor(),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
        ),
      ),
    );
