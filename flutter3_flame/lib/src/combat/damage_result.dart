import 'dart:math';

import 'combat_stats.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 战斗伤害计算
/// 这个结果用于展示：
/// - 普通伤害
/// - 暴击伤害
/// - 未命中
/// - 目标防御
/// - 防御减伤
class DamageResult {
  /// 攻击力
  final double attack;

  /// 有效防御力
  final double effectiveDefense;

  /// 减伤比例
  final double reduction;

  /// 是否暴击
  final bool isCritical;

  /// 是否命中
  final bool isHit;

  /// 最终伤害
  final int damage;

  const DamageResult({
    required this.attack,
    required this.effectiveDefense,
    required this.reduction,
    required this.isCritical,
    required this.isHit,
    required this.damage,
  });
}
/*class DamageResult {
  /// 最终伤害
  final int damage;

  /// 是否暴击
  final bool isCritical;

  /// 原始攻击力
  final double attack;

  /// 防御减伤比例
  /// - 或者直接就是减伤值
  final double reduction;

  const DamageResult({
    required this.damage,
    required this.isCritical,
    required this.attack,
    required this.reduction,
  });
}*/

