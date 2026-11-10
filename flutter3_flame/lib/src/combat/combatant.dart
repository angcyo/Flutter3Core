import 'dart:math';

import 'combat_stats.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 战斗角色
/// 战斗角色负责管理：
/// - 属性
/// - 当前血量
/// - 当前护盾
/// - 无敌时间
/// - 死亡状态
/// - 受到伤害
/// - 恢复血量
/// - 恢复护盾
///
/// - [Combatant] 角色
///   - [CombatStats] 属性
/// - [CombatCalculator] 计算
class Combatant {
  /// 战斗角色ID
  final String id;

  /// 战斗属性
  CombatStats stats;

  /// 当前血量
  int hp;

  /// 当前护盾
  int shield;

  /// 无敌时间
  double invulnerabilityRemaining = 0;

  /// 死亡状态
  bool isDead = false;

  Combatant({
    this.id = 'combatant',
    required this.stats,
    int? hp /*血量*/,
    int? shield /*护盾*/,
  }) : hp = (hp ?? stats.maxHP).clamp(0, stats.maxHP),
       shield = max(0, shield ?? stats.initialShield) {
    isDead = this.hp <= 0;
  }

  // =========================
  // 最大血量
  // =========================

  int get maxHP => stats.maxHP;

  // =========================
  // 血量比例
  // =========================

  double get hpPercent {
    return hp / maxHP;
  }

  // =========================
  // 护盾比例
  // =========================

  double get shieldPercent {
    if (stats.initialShield <= 0) {
      return 0;
    }

    return shield / stats.initialShield;
  }

  // =========================
  // 是否无敌
  // =========================

  bool get isInvulnerable {
    return invulnerabilityRemaining > 0;
  }

  // =========================
  // 更新无敌时间
  // =========================

  void update(double dt) {
    if (invulnerabilityRemaining > 0) {
      invulnerabilityRemaining = max(0, invulnerabilityRemaining - dt);
    }
  }

  // =========================
  // 恢复血量
  // =========================
  int heal(int amount) {
    if (isDead || amount <= 0) {
      return 0;
    }

    final actual = min(amount, maxHP - hp);
    hp += actual;
    return actual;
  }

  // =========================
  // 恢复护盾
  // =========================
  int restoreShield(int amount) {
    if (isDead || amount <= 0) {
      return 0;
    }

    final actual = amount;
    shield += actual;
    return actual;
  }

  // =========================
  // 受到伤害
  // =========================
  int takeDamage(int damage) {
    if (isDead || isInvulnerable || damage <= 0) {
      return 0;
    }

    final actual = min(hp, damage);
    hp -= actual;
    if (hp <= 0) {
      hp = 0;
      isDead = true;
    }

    return actual;
  }

  // =========================
  // 设置无敌时间
  // =========================
  void setInvulnerability(double seconds) {
    invulnerabilityRemaining = max(invulnerabilityRemaining, seconds);
  }

  // =========================
  // 更新属性
  // =========================

  void updateStats(CombatStats newStats, {bool fillHP = false}) {
    stats = newStats;

    if (fillHP) {
      hp = maxHP;
    } else {
      hp = min(hp, maxHP);
    }

    isDead = hp <= 0;
  }

  // =========================
  // 复活
  // =========================

  void revive({int? hp, int? shield}) {
    this.hp = (hp ?? maxHP).clamp(1, maxHP);
    this.shield = max(0, shield ?? stats.initialShield);
    isDead = false;
    invulnerabilityRemaining = 0;
  }
}
