part of '../flutter3_vector.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/29
///
/// # GCode 常用指令
///
/// - `G20` 英寸单位, `默认`
/// - `G21` 毫米单位
/// - ---
/// - `G90` 绝对位置/绝对距离模式 `默认`
/// - `G91` 相对位置/增量距离模式
/// - ---
/// - `G0` moveTo
/// - `G1` lineTo
/// - `G2` 顺时针画弧 `G2 X100 Y100 I50 J50`
/// - `G3` 逆时针画弧
/// - ---
/// - `M2、M30` 程序结束
///     - `M2` - 结束程序。
///     - `M30` - 交换托盘穿梭车并结束程序。
/// - `M3、M4、M5` 主轴控制
///     - `M3` - 以 S 速度顺时针启动选定的主轴。
///     - `M4` - 以 S 速度逆时针启动选定的主轴。
///     - `M5` - 停止选定的主轴。
/// - `M7、M8、M9` 冷却液控制
///     - `M7` 打开雾化冷却液
///     - `M8` 打开溢流冷却液
///     - `M9` 关闭`M7`和`M8`。
/// - `M5/M05` 关闭主轴,所有`G`操作, 都变成`moveTo`
/// - `M3/M03` 打开主轴
/// - `M4/M04` 自动激光
/// - ---
/// - `S255` `S0` 出光功率
///
/// # GCode 其他指令
///
/// - `G0/G00` 快速协调运动
/// - `G17-G19.1` 平面选择坐标系选择
/// - `G17` `XY`
/// - `G18` `ZX`
/// - `G19` `YZ`
/// - `G40` 关闭刀具补偿
/// - `G54-G59.3` 选择坐标系
///
/// M 代码命令，常与 G 代码一起在程序中使用。以下是一些常见的 M 代码命令：
///
/// M00 – 程序停止
/// M02 – 程序结束
/// M03 – 主轴开启 – 顺时针
/// M04 – 主轴开启 – 逆时针
/// M05 – 主轴停止
/// M06 – 换刀
/// M08 – 开启冷却夜
/// M09 – 关闭冷却液
/// M30 – 程序结束
///
/// ```
/// G90
/// G21
/// M03S255
/// G0X0Y0
/// G1X100Y0
/// G1X100Y100
/// G1X0Y100
/// G1X0Y0
/// M05S0
/// ```
/// 将GCode数据解析成[UiPath]
class GCodeParser {
  /// 当前字符串
  String gcodeText = "";

  @entryPoint
  Path? parse(String? gcode) {
    if (gcode == null || isNil(gcode)) {
      return null;
    }
    gcodeText = gcode;
    startParseGCode();
    /*final scanner = StringScanner(gcode);
    while (!scanner.isDone) {
      final chat = String.fromCharCode(scanner.readChar());
      l.d(chat);
    }*/
    return _result;
  }

  /// 需要返回的数据
  @output
  Path? _result;

  int get length => gcodeText.length;

  //region---Path操作---

  /// 初始化Path对象
  void initPath() {
    _result ??= Path();
  }

  void moveTo(double x, double y) {
    initPath();
    _result?.moveTo(x, y);
  }

  void lineTo(double x, double y) {
    initPath();
    _result?.lineTo(x, y);
  }

  void addArc(double left, double top, double right, double bottom,
      double startAngle, double sweepAngle) {
    initPath();
    _result?.addArc(
        Rect.fromLTRB(left, top, right, bottom), startAngle, sweepAngle);
  }

  void closePath() {
    _result?.close();
  }

  //endregion---Path操作---

  //region---GCode解析---

  /// [mmFactor] `G21` 毫米单位时, 数值要乘以的倍数
  double mmFactor = 1.0.toDpFromMm();

  /// [inchFactor] `G20` 英寸单位时, 数值要乘以的倍数
  double inchFactor = 1.0.toDpFrom(IUnit.inch);

  /// 当前的坐标比例
  double currentFactor = 1.0;

  bool isAbsolutePosition = true;

  /// 是否是自动cnc
  bool isAutoCnc = true;

  /// 是否关闭了主轴, 关闭主轴之后, 所有G操作都变成G0.
  /// S0 M03 //M05指令:主轴关闭, M03:主轴打开 M04自动
  ///
  bool isCloseCnc = true;

  /// 主轴转速是否为空, 为空之后, 所有操作变成G0
  bool isS0 = false;

  /// 主轴打开后, 第一条指令全部变成G0
  bool isMoveTo = false;

  /// 当前的读取位置索引
  int index = 0;

  /// 当前第几行了
  int line = 0;

  /// 上一次的G指令: 比例[G0 G1 G2 G3]
  String lastGCmd = "G0";

  /// 上一次读取到的指令值
  double lastX = 0;
  double lastY = 0;
  double lastI = 0;
  double lastJ = 0;
  double lastR = 0;

  /// 开始解析GCode, 入口
  void startParseGCode() {
    currentFactor = mmFactor; //默认使用mm单位
    while (index < length) {
      readPreCmd();
      final c = gcodeText[index].toUpperCase();
      //LOGD("开始解析1:%ld %c", index, c);
      if (c == 'G' || c == 'F' || c == 'M') {
        //读取到指令
        readCmd(c);
        skipCurrentLine();
      } else if (c == 'X' || c == 'Y' || c == 'I' || c == 'J') {
        //读取到坐标指令, 通常是在新的一行就读取了坐标指令
        readGCmd(lastGCmd);
        skipCurrentLine();
      } else if (c == ' ') {
        //空格
      } else if (c == ';') {
        //注释
        readComment();
      } else if (isBreakLine(c)) {
        //换行
        line++;
      } else {
        //其他字符
      }
      index++;
    }
    //LOGD("解析结束:%ld", index);
  }

  /// 当读到有效指令之后
  void readCmd(String currentCmd) {
    //读取到指令
    if (currentCmd == 'G') {
      //G指令
      String gCmd = "G${readNumberString()}";
      //LOGD("解析到G指令[%ld]:%s", index, gCmd.c_str());
      if (gCmd == "G0" || gCmd == "G1" || gCmd == "G2" || gCmd == "G3") {
        //直线 //圆弧
        lastGCmd = gCmd;
        readGCmd(gCmd);
      } else if (gCmd == "G20") {
        //英寸
        currentFactor = inchFactor;
        /*inchFactor = 25.4f;
                mmFactor = 1.0f;*/
      } else if (gCmd == "G21") {
        //毫米
        currentFactor = mmFactor;
      } else if (gCmd == "G90") {
        //绝对坐标
        isAbsolutePosition = true;
      } else if (gCmd == "G91") {
        //相对坐标
        isAbsolutePosition = false;
      } else if (gCmd == "G92") {
        //设置当前坐标
        readXY();
        moveTo(lastX, lastY);
      }
    } else if (currentCmd == 'M') {
      //M指令
      int number = readNumberString().toIntOrNull() ?? 0;
      String mCmd = "M$number";
      //LOGD("解析到m指令[%ld]:%s", index, mCmd.c_str());
      if (mCmd == "M3" || mCmd == "M03") {
        //主轴打开
        isCloseCnc = false;
        isAutoCnc = false;
      } else if (mCmd == "M5" || mCmd == "M05") {
        //主轴关闭
        isCloseCnc = true;
        isAutoCnc = false;
      } else if (mCmd == "M4" || mCmd == "M04") {
        //自动cnc
        isAutoCnc = true;
      } else if (mCmd == "M2" || mCmd == "M02") {
        //结束, 文档结束
        index = length;
      }
    } else if (currentCmd == 'F') {
      //速度
      //readNumber();
      //float speed = atof(string(numberChars.begin(), numberChars.end()).c_str());
    }
  }

  void readGCmd(String gCmd) {
    if (gCmd == "G0" || gCmd == "G1") {
      //直线
      if (!readXY()) {
        //有X Y指令
        return;
      }

      if (isAutoCnc && gCmd == "G1") {
        isCloseCnc = false;
      }

      if (isS0 || isCloseCnc || gCmd == "G0" || !isMoveTo) {
        moveTo(lastX, lastY);
        isMoveTo = true;
        //LOGD("moveTo:x:%f y:%f", lastX, lastY);
      } else {
        lineTo(lastX, lastY);
        //LOGD("lineTo:x:%f y:%f", lastX, lastY);
      }
    } else if (gCmd == "G2" || gCmd == "G3") {
      //圆弧
      double startX = lastX;
      double startY = lastY;
      if (!readXY()) {
        //没有X Y指令
        return;
      }

      if (isAutoCnc) {
        isCloseCnc = false;
      }

      if (!isMoveTo) {
        moveTo(lastX, lastY);
        isMoveTo = true;
        //LOGD("force moveTo:x:%f y:%f", lastX, lastY);
        if (!isAutoCnc) {
          //不是自动激光, 则返回.
          return;
        }
      }

      if (readR()) {
        //有R指令, 则通过R指令计算I J
        double r = lastR;
        double x1 = startX;
        double y1 = startY;
        double x2 = lastX;
        double y2 = lastY;
        // 求出中点坐标

        //已知2个点和半径和顺时针方向 求圆心坐标

        Offset p1 = Offset(x1, y1); // 输入p1点坐标
        Offset p2 = Offset(x2, y2); // 输入p2点坐标
        double dRadius = r; // 输入半径

        final centerList = centerOfCircleRadius(p1, p2, dRadius);
        final center =
            judgeCenter(centerList[0], centerList[1], p1, p2, gCmd == "G2");
        if (!center.dx.isValid || !center.dy.isValid) {
          //不是一个有效的数值
          //LOGD("test:%f %f", center[0], center[1]);
          moveTo(lastX, lastY);
          isMoveTo = true;
          return;
        } else {
          //LOGD("test2:%f %f", center[0], center[1]);
          lastI = center.dx - startX;
          lastJ = center.dy - startY;
        }
      } else {
        readIJ();
      }

      //圆心中点坐标
      double originX = startX + lastI;
      double originY = startY + lastJ;
      //半径
      double radius = sqrt(pow(lastI, 2) + pow(lastJ, 2));
      double left = originX - radius;
      double top = originY - radius;
      double right = originX + radius;
      double bottom = originY + radius;

      //中点启动之间的角度, 角度单位
      double startAngle = atan2(startY - originY, startX - originX) * 180 / pi;
      //中点结束之间的角度
      double endAngle = atan2(lastY - originY, lastX - originX) * 180 / pi;

      if (startAngle < 0) {
        startAngle = 360 + startAngle;
      }
      if (endAngle < 0) {
        endAngle = 360 + endAngle;
      }

      //sweep angle
      double sweepAngle = 0;
      //圆弧方向
      if (gCmd == "G2") {
        //顺时针, 在NCViewer里面表示, 从起点到终点, 顺时针绘制
        //在Android里面表示, 从起点到终点, 负数sweep绘制
        sweepAngle = ((startAngle + 360) - endAngle).abs();
        if (sweepAngle > 360) {
          sweepAngle = sweepAngle - 360;
        }
        sweepAngle = -sweepAngle; //一定要是负数
      } else {
        //逆时针, 正数sweep绘制
        sweepAngle = ((endAngle + 360) - startAngle).abs();
        if (sweepAngle > 360) {
          sweepAngle = sweepAngle - 360; //一定要是正数
        }
      }

      //取圆上的点x坐标
      double x = originX + radius * cos(endAngle * pi / 180);
      //取圆上的点y坐标
      double y = originY + radius * sin(endAngle * pi / 180);

      lastX = x;
      lastY = y;

      if (isS0 || isCloseCnc) {
        moveTo(lastX, lastY);
        isMoveTo = true;
        //LOGD("moveTo:x:%f y:%f", lastX, lastY);
      } else {
        //startAngle * 180 / M_PI 弧度转角度
        //角度转弧度,  弧度 = 角度 * M_PI / 180
        addArc(left, top, right, bottom, startAngle, sweepAngle);
        //LOGD("arcTo: startAngle:%f sweepAngle:%f", startAngle, sweepAngle);
      }

      //LOGD("last:x:%f y:%f", lastX, lastY);

      //moveTo(lastX, lastY);
    }
  }

  /// 读取注释, 直到下一行
  void readComment() {
    while (index < gcodeText.length) {
      final c = gcodeText[index];
      if (isBreakLine(c)) {
        break;
      }
      index++;
    }
  }

  /// 读取前置指令, 比例[S]等影响一行中G1顺序的指令
  void readPreCmd() {
    int oldIndex = index;
    while (index < length) {
      gcodeText[index];
      final c = gcodeText[index].toUpperCase();
      if (c == 'S') {
        //主轴转速
        final number = readNumberString().toIntOrNull() ?? 0;
        isS0 = number <= 0;
        //LOGD("关闭主轴转速: %d", isS0);
        break;
      } else if (c == ';' || isBreakLine(c)) {
        break;
      }
      index++;
    }
    index = oldIndex;
  }

  /// 从["G0" "G1"]指令后面读取X, Y, 直到换行或者遇到其他指令
  /// 返回整个语句中是否包含xy
  bool readXY() {
    int oldIndex = index;
    bool haveXY = false;
    while (index < gcodeText.length) {
      final c = gcodeText[index].toUpperCase();
      if (c == 'X') {
        double number = readNumberString().toDoubleOrNull() ?? 0;
        double value = number * currentFactor;
        if (isAbsolutePosition) {
          lastX = value;
        } else {
          lastX += value;
        }
        haveXY = true;
      } else if (c == 'Y') {
        double number = readNumberString().toDoubleOrNull() ?? 0;
        double value = number * currentFactor;
        if (isAbsolutePosition) {
          lastY = value;
        } else {
          lastY += value;
        }
        haveXY = true;
      } else if (c == ' ') {
        //空格
        index++;
      } else if (c == ';') {
        //注释
        break;
      } else if (isBreakLine(c)) {
        //换行
        break;
      } else {
        //其他字符
        break;
      }
    }
    if (!haveXY) {
      index = oldIndex;
    }
    return haveXY;
  }

  /// 从["G2" "G3"]指令后面读取I, J直到换行或者遇到其他指令
  bool readIJ() {
    int oldIndex = index;
    bool haveIJ = false;
    while (index < gcodeText.length) {
      final c = gcodeText[index].toUpperCase();
      if (c == 'I') {
        double number = readNumberString().toDoubleOrNull() ?? 0;
        double value = number * currentFactor;
        if (isAbsolutePosition) {
          lastI = value;
        } else {
          lastI += value;
        }
        haveIJ = true;
      } else if (c == 'J') {
        double number = readNumberString().toDoubleOrNull() ?? 0;
        double value = number * currentFactor;
        if (isAbsolutePosition) {
          lastJ = value;
        } else {
          lastJ += value;
        }
        haveIJ = true;
      } else if (c == ' ') {
        //空格
        index++;
      } else if (c == ';') {
        //注释
        break;
      } else if (isBreakLine(c)) {
        //换行
        break;
      } else {
        //其他字符
        break;
      }
    }
    if (!haveIJ) {
      index = oldIndex;
    }
    return haveIJ;
  }

  /// 读取G2/G3 对应当然R半径指令, 返回是否有R指令
  /// 如果有R指令, 则R指令对应的值会保存到[lastR]中
  ///
  bool readR() {
    int oldIndex = index;
    bool haveR = false;
    while (index < gcodeText.length) {
      final c = gcodeText[index].toUpperCase();
      if (c == 'R') {
        double number = readNumberString().toDoubleOrNull() ?? 0;
        double value = number * currentFactor;
        if (isAbsolutePosition) {
          lastR = value;
        } else {
          lastR += value;
        }
        haveR = true;
        break;
      } else if (c == ';') {
        //注释
        break;
      } else if (isBreakLine(c)) {
        //换行
        break;
      }
      index++;
    }
    index = oldIndex;
    return haveR;
  }

  //endregion---GCode解析---

  //region---辅助方法---

  /// 跳过当前行
  void skipCurrentLine() {
    while (index < length) {
      final c = gcodeText[index].toUpperCase();
      if (isBreakLine(c)) {
        break;
      }
      index++;
    }
  }

  bool isBreakLine(String c) {
    return c == '\r\n' || c == '\n' || c == '\r';
  }

  StringBuffer numberChars = StringBuffer();

  /// 在当前有效指令后面读取有效的浮点数字字符串, 索引后移
  String readNumberString() {
    numberChars.clear();
    index++; //移动一位
    bool isFirst = true;
    while (index < length) {
      final cStr = gcodeText[index];
      final c = cStr.ascii;

      if ((isFirst && c == '-'.ascii) ||
          (c >= '0'.ascii && c <= '9'.ascii) ||
          c == '.'.ascii) {
        numberChars.write(cStr);
        index++;
        isFirst = false;
      } else {
        break;
      }
    }
    return numberChars.toString();
  }

  /// 判断获取需要的圆心
  Offset judgeCenter(Offset center1, Offset center2, Offset p1, Offset p2,
      bool cw /*是否是顺时针*/) {
    if (cw) {
      //顺时针
      if (p2.dx <= p1.dx) {
        //如果终点在起点的左边
        if (p2.dy <= p1.dy) {
          //终点在起点的左上方,则取左下角的圆心
          if (center1.dx <= center2.dx && center1.dy >= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        } else {
          //终点在起点的左下方,则取最右下角的圆心
          if (center1.dx >= center2.dx && center1.dy >= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        }
      } else {
        //如果终点在起点的右边
        if (p2.dy <= p1.dy) {
          //终点在起点的右上方,则取左上角的圆心
          if (center1.dx <= center2.dx && center1.dy <= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        } else {
          //终点在起点的右下方,则取右上角的圆心
          if (center1.dx >= center2.dx && center1.dy <= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        }
      }
    } else {
      //逆时针
      if (p2.dx <= p1.dx) {
        //如果终点在起点的左边
        if (p2.dy <= p1.dy) {
          //终点在起点的左上方,则取右下角的圆心
          if (center1.dx >= center2.dx && center1.dy <= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        } else {
          //终点在起点的左下方,则取最左上角的圆心
          if (center1.dx <= center2.dx && center1.dy <= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        }
      } else {
        //如果终点在起点的右边
        if (p2.dy <= p1.dy) {
          //终点在起点的右上方,则取右下角的圆心
          if (center1.dx >= center2.dx && center1.dy >= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        } else {
          //终点在起点的右下方,则取左下角的圆心
          if (center1.dx <= center2.dx && center1.dy >= center2.dy) {
            return center1;
          } else {
            return center2;
          }
        }
      }
    }
  }

//endregion---辅助方法---
}

extension GCodeStringEx on String {
  /// GCode数据转换成[Path]可绘制对象
  Path? toPathFromGCode() {
    GCodeParser parser = GCodeParser();
    return parser.parse(this);
  }
}
