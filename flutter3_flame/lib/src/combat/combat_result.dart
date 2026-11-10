///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 战斗角色完整攻击结果
/// - [damage] 表示防御和暴击计算后的伤害。
/// - [shieldDamage] 表示护盾吸收的伤害。
/// - [hpDamage] 表示真正扣除的血量。
class CombatResult {
  /// 是否命中
  final bool isHit;

  /// 是否暴击
  final bool isCritical;

  /// 是否闪避
  final bool isDodged;

  /// 是否无敌
  final bool isInvulnerable;

  /// 攻击伤害
  final int damage;

  /// 护盾吸收的伤害
  final int shieldDamage;

  /// 真正扣除的血量
  final int hpDamage;

  /// 吸血量
  final int healed;

  /// 反弹伤害 / 反伤
  final int reflectedDamage;

  /// 目标是否死亡
  final bool targetDead;

  /// 是否吸血了
  bool get isHealed => healed > 0;

  /// 是否反弹了伤害
  bool get isReflected => reflectedDamage > 0;

  const CombatResult({
    required this.isHit,
    required this.isCritical,
    required this.isDodged,
    required this.isInvulnerable,
    required this.damage,
    required this.shieldDamage,
    required this.hpDamage,
    required this.healed,
    required this.reflectedDamage,
    required this.targetDead,
  });
}
