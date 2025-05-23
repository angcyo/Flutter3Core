part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/17
///
/// 版本匹配规则验证
/// 规则[x~xxx x~xxx x~xxx],若干组[x~xxx]的范围
class VersionMatcher {
  VersionMatcher._();

  /// 多个范围用空格隔开
  static const _RS = " ";

  /// min和max用波浪号隔开
  static const _VS = "~";

  /// 解析范围
  /// [config] 格式 [ x x~ ~x xxx~xxx xxx~xxx]
  static List<VersionRange> parseRange(String? config) {
    final rangeStringList = config?.split(_RS);
    final list = <VersionRange>[];
    rangeStringList?.forEach((range) {
      final r = range.range;
      if (r != null) {
        list.add(r);
      }
    });
    return list;
  }

  /// 当前的版本[version]适配满足配置的规则[min~max]
  /// [version] 当前的版本 比如:678
  /// [config] 版本配置 比如:xxx~xxx ~xxx xxx~
  ///
  /// [defOrNull] 默认值, 当版本号[version]未指定时, 或者匹配范围未指定时, 返回的默认值
  /// [defOrEmpty] 当匹配范围为空时的默认值
  ///
  static bool matches(
    int? version,
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
  static bool matchesRange(int? version, List<VersionRange> rangeList) {
    if (version == null) {
      return false;
    }
    for (var range in rangeList) {
      if (version >= range.minInt && version <= range.maxInt) {
        return true;
      }
    }
    return false;
  }
}

/// 版本规则数据结构[min~max]
class VersionRange {
  final double min;
  final double max;

  int get minInt => min.round();

  int get maxInt => max.round();

  VersionRange(this.min, this.max);

  @override
  String toString() {
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
  /// 格式 [ x x~ ~x xxx~xxx xxx~xxx]
  VersionRange? get range {
    if (this == "*") {
      return VersionRange(
        intMinValue.roundToDouble(),
        intMaxValue.roundToDouble(),
      );
    } else {
      final rangeString = split(VersionMatcher._VS);
      if (rangeString.length == 1) {
        final min = double.parse(rangeString[0]);
        if (have("*")) {
          if (startsWith(VersionMatcher._VS)) {
            //[~xxx] 的格式
            return VersionRange(intMinValue.roundToDouble(), min);
          } else {
            //[x~] 的格式
            return VersionRange(min, intMaxValue.roundToDouble());
          }
        } else {
          //[x] 的格式
          return VersionRange(min, min);
        }
      } else if (rangeString.length >= 2) {
        //[x~]
        //[~x]
        final min = double.tryParse(rangeString[0]) ?? 0.0;
        final max =
            double.tryParse(rangeString[1]) ?? intMax32Value.roundToDouble();
        return VersionRange(min, max);
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
  }) =>
      version == null
          ? false
          : version.matchVersion(this,
              defOrNull: defOrNull, defOrEmpty: defOrEmpty);
}
