part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/01
/// https://juejin.cn/post/7064212848565714974
/// 声明一个接口
/// 1 in = 25.4 mm = 72 pt
///
/// # mm与px换算公式
///
/// ```
/// 由 pt = px * dpi / 72
/// 则又知道 1 in = 25.4 mm = 72 pt
/// 则 25.4 mm / 72 = px * dpi / 72
/// -> 得 mm = px * dpi / 25.4
///
/// 以 Windows 下的 96 dpi 来计算
/// mm = px * 96 / 25.4
/// mm = px * 3.78
/// 基本上 1毫米 约等于 3.78像素
/// ```
///
/// ```
/// Android中:
/// 1 dp = 1 * dp
/// 1 in = 1 * xdpi
/// 1 pt = 1 * xdpi * 1/72
/// 1 mm = 1 * xdpi * 1/25.4
/// ```
///

/// 默认单位小数点位数
const kFractionDigits = 2;

/// 默认英寸单位小数点位数
const kInchFractionDigits = 3;

/// dp
@dp
double get dpr => devicePixelRatio;

/// pt
double INCHES_PER_PT = (1.0 / 72);

/// mm
double INCHES_PER_MM = (1.0 / 25.4);

abstract class IUnit {
  /// 单位常量
  static const px = PixelUnit();
  static const dp = DpUnit();
  static const mm = MmUnit();
  static const pt = PtUnit();
  static const inch = InchUnit();

  /// 正常的刻度
  static const AXIS_TYPE_NORMAL = 0x1;

  /// 次要的刻度
  static const AXIS_TYPE_SECONDARY = AXIS_TYPE_NORMAL << 1;

  /// 主要的刻度
  static const AXIS_TYPE_PRIMARY = AXIS_TYPE_SECONDARY << 1;

  /// 需要绘制Label的刻度
  static const AXIS_TYPE_MASK = 0xff;

  /// 需要绘制Label的刻度
  static const AXIS_TYPE_LABEL = AXIS_TYPE_NORMAL << 7;

  //region ---基础---

  /// 单位后缀
  String get suffix;

  /// 将当前单位的值[value]转换成[px]单位的值
  @pixel
  dynamic toPx(@unit dynamic value);

  /// 将[px]单位的值[value]转换成当前单位的值
  @unit
  dynamic toUnit(@pixel dynamic value);

  /// 格式化当前单位数值的输出
  /// [showSuffix] 是否显示单位后缀
  /// [fractionDigits] 小数点位数
  String format(
    @unit num value, {
    bool showSuffix,
    int fractionDigits,
    bool removeZero,
    bool ensureInt,
  });

  //endregion ---基础---

  //region ---坐标轴---

  /// 在坐标轴上, 每隔多少个dp距离单位, 显示一个刻度
  @dp
  double getAxisGap(int index, double scale);

  /// 获取坐标轴的类型
  /// [index] 当前刻度距离0开始的索引
  /// [AXIS_TYPE_NORMAL]
  /// [AXIS_TYPE_SECONDARY]
  /// [AXIS_TYPE_PRIMARY]
  /// [AXIS_TYPE_LABEL]
  int getAxisType(int index, double scale);

//endregion ---坐标轴---
}

/// 像素单位
@pixel
class PixelUnit implements IUnit {
  @override
  String get suffix => " px";

  const PixelUnit();

  @override
  String format(
    num value, {
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
  }) {
    return "${value.toDigits(
      digits: fractionDigits,
      removeZero: removeZero,
      ensureInt: ensureInt,
    )}${showSuffix ? suffix : ''}";
  }

  @override
  dynamic toPx(dynamic value) => value;

  @override
  dynamic toUnit(dynamic value) => value;

  @override
  double getAxisGap(int index, double scale) => 10;

  @override
  int getAxisType(int index, double scale) {
    switch (index % 10) {
      case 0:
        return IUnit.AXIS_TYPE_PRIMARY | IUnit.AXIS_TYPE_LABEL;
      case 5:
        return IUnit.AXIS_TYPE_SECONDARY;
      default:
        return IUnit.AXIS_TYPE_NORMAL;
    }
  }
}

@dp
class DpUnit implements IUnit {
  @override
  String get suffix => " dp";

  const DpUnit();

  @override
  String format(
    num value, {
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
  }) {
    return "${value.toDigits(
      digits: fractionDigits,
      removeZero: removeZero,
      ensureInt: ensureInt,
    )}${showSuffix ? suffix : ''}";
  }

  @override
  dynamic toPx(dynamic value) => value * dpr;

  @override
  dynamic toUnit(dynamic value) => value / dpr;

  @override
  double getAxisGap(int index, double scale) => 10;

  @override
  int getAxisType(int index, double scale) {
    switch (index % 10) {
      case 0:
        return IUnit.AXIS_TYPE_PRIMARY | IUnit.AXIS_TYPE_LABEL;
      case 5:
        return IUnit.AXIS_TYPE_SECONDARY;
      default:
        return IUnit.AXIS_TYPE_NORMAL;
    }
  }
}

@mm
class MmUnit implements IUnit {
  @override
  String get suffix => " mm";

  const MmUnit();

  @override
  String format(
    num value, {
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
  }) {
    return "${value.toDigits(
      digits: fractionDigits,
      removeZero: removeZero,
      ensureInt: ensureInt,
    )}${showSuffix ? suffix : ''}";
  }

  @override
  dynamic toPx(dynamic value) => value * dpi * INCHES_PER_MM;

  @override
  dynamic toUnit(dynamic value) => value / dpi / INCHES_PER_MM;

  @override
  double getAxisGap(int index, double scale) => 10;

  @override
  int getAxisType(int index, double scale) {
    switch (index % 10) {
      case 0:
        return IUnit.AXIS_TYPE_PRIMARY | IUnit.AXIS_TYPE_LABEL;
      case 5:
        return IUnit.AXIS_TYPE_SECONDARY;
      default:
        return IUnit.AXIS_TYPE_NORMAL;
    }
  }
}

@pt
class PtUnit implements IUnit {
  @override
  String get suffix => " pt";

  const PtUnit();

  @override
  String format(
    num value, {
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
  }) {
    return "${value.toDigits(
      digits: fractionDigits,
      removeZero: removeZero,
      ensureInt: ensureInt,
    )}${showSuffix ? suffix : ''}";
  }

  @override
  dynamic toPx(dynamic value) => value * dpi * INCHES_PER_PT;

  @override
  dynamic toUnit(dynamic value) => value / dpi / INCHES_PER_PT;

  @override
  double getAxisGap(int index, double scale) => 10;

  @override
  int getAxisType(int index, double scale) {
    switch (index % 10) {
      case 0:
        return IUnit.AXIS_TYPE_PRIMARY | IUnit.AXIS_TYPE_LABEL;
      case 5:
        return IUnit.AXIS_TYPE_SECONDARY;
      default:
        return IUnit.AXIS_TYPE_NORMAL;
    }
  }
}

@inch
class InchUnit implements IUnit {
  @override
  String get suffix => " in";

  const InchUnit();

  @override
  String format(
    num value, {
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kInchFractionDigits,
  }) {
    return "${value.toDigits(
      digits: fractionDigits,
      removeZero: removeZero,
      ensureInt: ensureInt,
    )}${showSuffix ? suffix : ''}";
  }

  @override
  dynamic toPx(dynamic value) => value * dpi;

  @override
  dynamic toUnit(dynamic value) => value / dpi;

  @override
  double getAxisGap(int index, double scale) => 10;

  @override
  int getAxisType(int index, double scale) {
    switch (index % 10) {
      case 0:
        return IUnit.AXIS_TYPE_PRIMARY | IUnit.AXIS_TYPE_LABEL;
      case 5:
        return IUnit.AXIS_TYPE_SECONDARY;
      default:
        return IUnit.AXIS_TYPE_NORMAL;
    }
  }
}

/// 单位转换扩展
extension UnitNumEx on num {
  /// 将指定单位[unit](默认是毫米单位)的值[value]转换成像素单位的值
  /// [IUnit.mm]
  @pixel
  dynamic toPixel([@unit IUnit unit = IUnit.mm]) {
    return unit.toPx(this);
  }

  /// 格式化成对应单位描述的值
  String formatUnitValue({
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
    @unit required IUnit unit,
  }) {
    return unit.format(
      this,
      showSuffix: showSuffix,
      removeZero: removeZero,
      ensureInt: ensureInt,
      fractionDigits: fractionDigits,
    );
  }

  /// 将当前的值格式化成像素单位的值
  String formatPixel({
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
  }) {
    return formatUnitValue(
      showSuffix: showSuffix,
      removeZero: removeZero,
      ensureInt: ensureInt,
      fractionDigits: fractionDigits,
      unit: IUnit.px,
    );
  }

  String formatMm({
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kFractionDigits,
  }) {
    return formatUnitValue(
      showSuffix: showSuffix,
      removeZero: removeZero,
      ensureInt: ensureInt,
      fractionDigits: fractionDigits,
      unit: IUnit.mm,
    );
  }

  String formatInch({
    bool showSuffix = true,
    bool removeZero = true,
    bool ensureInt = false,
    int fractionDigits = kInchFractionDigits,
  }) {
    return formatUnitValue(
      showSuffix: showSuffix,
      removeZero: removeZero,
      ensureInt: ensureInt,
      fractionDigits: fractionDigits,
      unit: IUnit.inch,
    );
  }

  /// 将指定单位[unit](默认是像素单位)的值[value]转换成毫米单位的值
  @mm
  dynamic toMm([@unit IUnit unit = IUnit.px]) {
    return IUnit.mm.toUnit(toPixel(unit));
  }

  @mm
  dynamic toMmFromDp([@unit IUnit unit = IUnit.dp]) {
    return IUnit.mm.toUnit(toPixel(unit));
  }

  @mm
  dynamic toDpFromMm([@unit IUnit unit = IUnit.mm]) {
    return IUnit.dp.toUnit(toPixel(unit));
  }
}
