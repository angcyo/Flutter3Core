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
const double INCHES_PER_PT = (1.0 / 72);

/// mm
const double INCHES_PER_MM = (1.0 / 25.4);

abstract class IUnit {
  /// 单位常量
  static const px = PixelUnit();
  static const dp = DpUnit();
  static const mm = MmUnit();
  static const pt = PtUnit();
  static const inch = InchUnit();

  /// 正常的刻度
  static const axisTypeNormal = 0x1;

  /// 次要的刻度
  static const axisTypeSecondary = axisTypeNormal << 1;

  /// 主要的刻度
  static const axisTypePrimary = axisTypeSecondary << 1;

  /// mask
  static const axisTypeMask = 0xff;

  /// 需要绘制Label的刻度
  static const axisTypeLabel = axisTypeNormal << 7;

  const IUnit();

  //region ---基础---

  /// 单位后缀
  String get suffix;

  /// 将当前单位的值[value]转换成[px]单位的值
  @pixel
  double toPx(@unit num value);

  /// 将[px]单位的值[value]转换成当前单位的值
  @unit
  double toUnit(@pixel num value);

  /// 将[otherUnit]单位的值[value]转换成当前单位的值
  @unit
  double toUnitFromUnit(IUnit otherUnit, @unit num value) {
    return toUnit(otherUnit.toPx(value));
  }

  @unit
  double toUnitFromDp(@dp num value) {
    return toUnit(value.toPixelFromDp());
  }

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

  String formatFromDp(
    @dp num value, {
    bool showSuffix = true,
    int fractionDigits = kFractionDigits,
    bool removeZero = true,
    bool ensureInt = true,
  }) {
    return format(toUnitFromDp(value),
        showSuffix: showSuffix,
        fractionDigits: fractionDigits,
        removeZero: removeZero,
        ensureInt: ensureInt);
  }

  //endregion ---基础---

  //region ---坐标轴---

  /// 根据缩放比例, 计算坐标轴上的刻度间隔
  /// [scale] 缩放比例
  /// [baseGap] 1:1时的刻度间隔
  @dp
  double baseAxisGap(int index, double scale, @dp double baseGap) {
    if (scale >= 4) {
      //放大4倍后
      return baseGap / 2;
    } else if (scale <= 0.1) {
      return baseGap * 50;
    } else if (scale <= 0.25) {
      //缩小4倍后
      return baseGap * 10;
    } else if (scale <= 0.75) {
      return baseGap * 5;
    } else {
      return baseGap;
    }
  }

  /// 在坐标轴上, 每隔多少个dp距离单位, 显示一个刻度
  @dp
  double getAxisGap(int index, double scale);

  /// 获取坐标轴的类型
  /// [index] 当前刻度距离0开始的索引
  /// [axisTypeNormal]
  /// [axisTypeSecondary]
  /// [axisTypePrimary]
  /// [axisTypeLabel]
  int getAxisType(int index, double scale) {
    if (index % 10 == 0) {
      return IUnit.axisTypePrimary | IUnit.axisTypeLabel;
    }
    if (index % 10 == 5) {
      if (scale < 0.75) {
        return IUnit.axisTypeSecondary | IUnit.axisTypeLabel;
      }
      return IUnit.axisTypeSecondary;
    }
    return IUnit.axisTypeNormal;
  }

//endregion ---坐标轴---
}

/// 像素单位
@pixel
class PixelUnit extends IUnit {
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
  double toPx(num value) => value.toDouble();

  @override
  double toUnit(num value) => value.toDouble();

  @override
  double getAxisGap(int index, double scale) => 10;
}

@dp
class DpUnit extends IUnit {
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
  double toPx(num value) => value * dpr;

  @override
  double toUnitFromDp(num value) => value + 0.0;

  @override
  double toUnit(num value) => value / dpr;

  @override
  double getAxisGap(int index, double scale) => baseAxisGap(index, scale, 10);
}

@mm
class MmUnit extends IUnit {
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
  double toPx(num value) => value * dpi * INCHES_PER_MM;

  @override
  double toUnit(num value) => value / dpi / INCHES_PER_MM;

  @override
  double getAxisGap(int index, double scale) =>
      baseAxisGap(index, scale, 1.toDpFromMm());
}

@pt
class PtUnit extends IUnit {
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
  double toPx(num value) => value * dpi * INCHES_PER_PT;

  @override
  double toUnit(num value) => value / dpi / INCHES_PER_PT;

  @override
  double getAxisGap(int index, double scale) => 10;
}

@inch
class InchUnit extends IUnit {
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
  String formatFromDp(
    num value, {
    bool showSuffix = true,
    int fractionDigits = kInchFractionDigits,
    bool removeZero = true,
    bool ensureInt = true,
  }) {
    return super.formatFromDp(value,
        showSuffix: showSuffix,
        fractionDigits: fractionDigits,
        removeZero: removeZero,
        ensureInt: ensureInt);
  }

  @override
  double toPx(num value) => value * dpi;

  @override
  double toUnit(num value) => value / dpi;

  @override
  double getAxisGap(int index, double scale) {
    final baseGap = 0.125.toDpFromMm(IUnit.inch);
    if (scale >= 4) {
      //放大4倍后
      return baseGap / 8;
    } else if (scale >= 2) {
      return baseGap / 4;
    } else if (scale <= 0.1) {
      return baseGap * 4;
    } else if (scale <= 0.25) {
      //缩小4倍后
      return baseGap * 2;
    } else if (scale <= 0.75) {
      return baseGap * 1;
    } else {
      return baseGap;
    }
  }

  @override
  int getAxisType(int index, double scale) {
    switch (index % 8) {
      case 0:
        return IUnit.axisTypePrimary | IUnit.axisTypeLabel;
      case 4:
        return IUnit.axisTypeSecondary;
      default:
        return IUnit.axisTypeNormal;
    }
  }
}

/// 单位转换扩展
extension UnitNumEx on num {
  /// 将指定单位[unit](默认是毫米单位)的值[value]转换成像素单位的值
  /// [IUnit.mm]
  @pixel
  double toPixel([@unit IUnit unit = IUnit.mm]) {
    return unit.toPx(this);
  }

  ///[toPixel]
  @pixel
  double toPixelFromDp([@unit IUnit unit = IUnit.dp]) {
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

  String formatDp({
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
      unit: IUnit.dp,
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
  double toMmFromPx([@unit IUnit unit = IUnit.px]) {
    return IUnit.mm.toUnit(toPixel(unit));
  }

  @mm
  double toMmFromDp([@unit IUnit unit = IUnit.dp]) {
    return IUnit.mm.toUnit(toPixel(unit));
  }

  @mm
  double toDpFromMm([@unit IUnit unit = IUnit.mm]) {
    return IUnit.dp.toUnit(toPixel(unit));
  }

  @mm
  double toDpFromPx([@unit IUnit unit = IUnit.px]) {
    return IUnit.dp.toUnit(toPixel(unit));
  }
}

/// 单位转换扩展
extension UnitSizeEx on Size {
  ///[toPixel]
  @pixel
  Size toPixelFromDp([@unit IUnit unit = IUnit.dp]) {
    return Size(width.toPixelFromDp(unit), height.toPixelFromDp(unit));
  }
}

/// 单位转换扩展
extension UnitRectEx on Rect {
  ///[toPixel]
  @pixel
  Rect toPixelFromDp([@unit IUnit unit = IUnit.dp]) {
    return Rect.fromLTRB(
      left.toPixelFromDp(unit),
      top.toPixelFromDp(unit),
      right.toPixelFromDp(unit),
      bottom.toPixelFromDp(unit),
    );
  }
}
