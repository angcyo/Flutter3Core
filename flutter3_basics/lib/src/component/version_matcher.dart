part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/17
///
/// 版本匹配规则验证
/// 规则[x~xxx x~xxx x~xxx],若干组[x~xxx]的范围
class VersionMatcher {
  VersionMatcher._();

  /// 所有版本
  static const kAll = "*";

  /// 多个范围用空格隔开
  static const kRS = " ";

  /// min和max用波浪号隔开
  static const kVS = "~";

  /// 解析范围
  /// [config] 格式 [ x x~ ~x xxx~xxx xxx~xxx]
  static List<ValueRange> parseRange(String? config) {
    final rangeStringList = config?.split(kRS);
    final list = <ValueRange>[];
    rangeStringList?.forEach((range) {
      if (range.isNotEmpty) {
        final r = range.range;
        if (r != null) {
          list.add(r);
        }
      }
    });
    return list;
  }

  /// 当前的版本[version]适配满足配置的规则[min~max]
  /// [version] 当前的版本 比如:678 / 1.0.0
  /// [config] 版本配置 比如:xxx~xxx ~xxx xxx~
  ///
  /// [defOrNull] 默认值, 当版本号[version]未指定时, 或者匹配范围未指定时, 返回的默认值
  /// [defOrEmpty] 当匹配范围为空时的默认值
  ///
  static bool matches(
    dynamic version,
    String? config, {
    /*未配置[config]规则时返回*/
    bool defOrNull = false,
    /*[config]规则为空时*/
    bool defOrEmpty = true,
  }) {
    if (version == null) {
      return false;
    }

    if (config == null) {
      //无规则, 则返回默认值
      return defOrNull;
    }

    if (config.isEmpty) {
      //规则空, 则返回默认值
      return defOrEmpty;
    }

    final versionRangeList = parseRange(config);
    if (versionRangeList.isEmpty) {
      //无规则, 则返回默认值
      return defOrEmpty;
    }

    return matchesRange(version, versionRangeList);
  }

  /// 匹配, 当前输入的版本号[version]是否在指定的范围内
  /// - [version] 支持版本号, 语义化版本名
  static bool matchesRange(dynamic version, List<ValueRange> rangeList) {
    if (version == null) {
      return false;
    }
    for (final range in rangeList) {
      //debugger();
      if (version is String && version.contains(".")) {
        //语义化版本号名匹配
        final valueList = version.split(".");
        int major = double.tryParse(valueList.getOrNull(0) ?? "")?.round() ?? 0;
        int minor = double.tryParse(valueList.getOrNull(1) ?? "")?.round() ?? 0;
        int patch = double.tryParse(valueList.getOrNull(2) ?? "")?.round() ?? 0;

        //MARK: - min
        bool match = major >= range.minMajor.round();
        if (match) {
          if (minor > (range.minMinor?.round() ?? 0)) {
            match = true;
          } else {
            match = patch >= (range.minPatch?.round() ?? 0);
          }

          //MARK: - max
          if (match) {
            match = major <= range.maxMajor.round();
            if (match) {
              if (minor < (range.maxMinor?.round() ?? 0)) {
                match = true;
              } else {
                match = patch <= (range.minPatch?.round() ?? 0);
              }
            }
          }
        }
        if (match) {
          return match;
        }
      }
      if (range.isSemver) {
        continue;
      }
      final v =
          (version is num
                  ? version.toDouble()
                  : double.tryParse(version.toString()) ?? 0.0)
              .round();
      if (v >= range.minInt && v <= range.maxInt) {
        return true;
      }
    }
    return false;
  }
}

/// 数值范围最小和最大值
/// - 版本规则数据结构[min~max]
/// - 如果是语义化的版本号, 则是[]
class ValueRange {
  //MARK: - number 常规数值

  final double min;
  final double max;

  int get minInt => min.round();

  int get maxInt => max.round();

  //--

  ///
  double get num => max - min;

  /// 值
  int get numInt => num.round();

  //MARK: - semver 语义化版本号

  /// [major] + [minor] + [patch]
  /// https://semver.org/lang/zh-CN/
  /// 主版本
  double get minMajor => min;

  double get maxMajor => max;

  /// 次版本
  final double? minMinor;
  final double? maxMinor;

  /// 修订版本
  final double? minPatch;
  final double? maxPatch;

  /// 是否是语义化版本号
  bool get isSemver =>
      minMinor != null ||
      maxMinor != null ||
      minPatch != null ||
      maxPatch != null;

  ValueRange(
    this.min,
    this.max, {
    this.minMinor,
    this.maxMinor,
    this.minPatch,
    this.maxPatch,
  });

  @override
  String toString() {
    if (isSemver) {
      return '[min:${minMajor.round()}.${minMinor?.round() ?? 0}.${minPatch?.round() ?? 0} '
          'max:${maxMajor.round()}.${maxMinor?.round() ?? 0}.${maxPatch?.round() ?? 0}]';
    }
    return '[min:$min max:$max]';
  }
}

/// [VersionStringEx]
extension VersionIntEx on int {
  /// 当前的版本是否配置指定的规则
  bool matchVersion(
    String? config, {
    /*未配置[config]规则时返回*/
    bool defOrNull = false,
    /*[config]规则为空时*/
    bool defOrEmpty = true,
  }) {
    return VersionMatcher.matches(
      this,
      config,
      defOrNull: defOrNull,
      defOrEmpty: defOrEmpty,
    );
  }
}

/// [VersionIntEx]
extension VersionStringEx on String {
  /// 解析范围
  /// 格式 [* / x / x~ / ~x / xxx~xxx / x.x.x~x.x.x]
  ValueRange? get range {
    if (this == VersionMatcher.kAll) {
      return ValueRange(
        intMinValue.roundToDouble(),
        intMaxValue.roundToDouble(),
      );
    } else {
      final rangeString = split(VersionMatcher.kVS);
      if (rangeString.length == 1) {
        final value = rangeString[0];
        if (contains(".")) {
          //[x.x.x] 的格式, 固定版本
          final valueList = value.split(".");
          double? major = double.tryParse(valueList.getOrNull(0) ?? "");
          double? minor = double.tryParse(valueList.getOrNull(1) ?? "");
          double? patch = double.tryParse(valueList.getOrNull(2) ?? "");
          return ValueRange(
            major ?? 0.0,
            major ?? 0.0,
            minMinor: minor,
            maxMinor: minor,
            minPatch: patch,
            maxPatch: patch,
          );
        } else {
          final min = double.tryParse(value) ?? 0.0;
          //[x] 的格式, 固定版本
          return ValueRange(min, min);
        }
      } else if (rangeString.length >= 2) {
        //[x~x]
        if (contains(".")) {
          final minValueList = rangeString[0].split(".");
          final maxValueList = rangeString[1].split(".");
          double? minMajor = double.tryParse(minValueList.getOrNull(0) ?? "");
          double? minMinor = double.tryParse(minValueList.getOrNull(1) ?? "");
          double? minPatch = double.tryParse(minValueList.getOrNull(2) ?? "");
          double? maxMajor = double.tryParse(maxValueList.getOrNull(0) ?? "");
          double? maxMinor = double.tryParse(maxValueList.getOrNull(1) ?? "");
          double? maxPatch = double.tryParse(maxValueList.getOrNull(2) ?? "");
          return ValueRange(
            minMajor ?? 0.0,
            maxMajor ?? intMax32Value.roundToDouble(),
            minMinor: minMinor,
            maxMinor: maxMinor,
            minPatch: minPatch,
            maxPatch: maxPatch,
          );
        } else {
          final min = double.tryParse(rangeString[0]) ?? 0.0;
          final max =
              double.tryParse(rangeString[1]) ?? intMax32Value.roundToDouble();
          if (startsWith(VersionMatcher.kVS)) {
            //[~x] 的格式
            return ValueRange(intMinValue.roundToDouble(), min);
          } else if (endsWith(VersionMatcher.kVS)) {
            //[x~] 的格式
            return ValueRange(min, intMaxValue.roundToDouble());
          }
          return ValueRange(min, max);
        }
      }
    }
    return null;
  }

  /// 当前的版本范围是否配置指定的版本
  bool matchVersion(
    int? version, {
    /*未配置[config]规则时返回*/
    bool defOrNull = false,
    /*[config]规则为空时*/
    bool defOrEmpty = true,
  }) => version == null
      ? false
      : version.matchVersion(
          this,
          defOrNull: defOrNull,
          defOrEmpty: defOrEmpty,
        );
}
