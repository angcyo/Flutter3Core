import 'dart:math';

import 'combat_result.dart';
import 'combat_stats.dart';
import 'combatant.dart';
import 'damage_result.dart';

export 'combat_result.dart';
export 'combat_stats.dart';
export 'combatant.dart';
export 'damage_result.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// # 战斗系统
/// 这里有几个重要规则：
/// 1. 闪避发生在伤害计算之前。
/// 2. 防御穿透只作用于防御力。
/// 3. 暴击抵抗降低攻击者的暴击概率。
/// 4. 暴击伤害减免只作用于暴击伤害。
/// 5. 护盾优先吸收伤害。
/// 6. 吸血基于实际造成的血量伤害，而不是护盾伤害。
/// 7. 反伤基于实际血量伤害。
/// 8. 反伤不触发吸血，避免无限循环。
/// 9. 无敌时间内不受到伤害，也不触发吸血和反伤。
/// 10. 反伤不会再次触发反伤。
///
/// - [Combatant] 角色
///   - [CombatStats] 属性
/// - [CombatCalculator] 计算
///   - [CombatCalculator.attackTarget] 发起攻击
///     - [CombatResult] 战斗结果
///   - [CombatCalculator.calculateDamage] 计算伤害
///     - [DamageResult] 伤害结果
///
class CombatCalculator {
  final Random random;

  /// 防御系数
  final double defenseConstant;

  /// 最低伤害
  final int minimumDamage;

  /// 命中概率最低值
  final double minimumAccuracy;

  /// 无敌时间
  final double invulnerabilityDuration;

  CombatCalculator({
    Random? random,
    this.defenseConstant = 0 /*100*/,
    this.minimumDamage = 1,
    this.minimumAccuracy = 0,
    this.invulnerabilityDuration = 0 /*0.5*/,
  }) : random = random ?? Random();

  // =========================
  // 计算伤害
  // =========================

  DamageResult calculateDamage({
    required CombatStats attacker,
    required CombatStats defender,
    double? attackOverride,
  }) {
    final attack = max(0.0, attackOverride ?? attacker.attack);

    // =========================
    // 1. 防御穿透
    // =========================

    final effectiveDefense = max(
      0.0,
      defender.defense - attacker.finalPenetration,
    );

    // =========================
    // 2. 防御减伤
    // =========================

    final reduction = effectiveDefense <= 0
        ? 0.0 // 防御为0时，无减伤
        : effectiveDefense / (effectiveDefense + defenseConstant);

    var damage = reduction >= 1
        ? max(attack - reduction, 0) //超过1, 表示直接减伤, 不采用百分比
        : attack * (1 - reduction);

    // =========================
    // 3. 暴击概率
    // =========================

    final critChance =
        (attacker.critChance * (1 - defender.finalCritResistance)).clamp(
          0.0,
          1.0,
        );

    final isCritical = random.nextDouble() < critChance;

    // =========================
    // 4. 暴击伤害
    // =========================

    if (isCritical) {
      damage *= attacker.finalCritDamage;

      // 暴击伤害减免
      damage *= (1 - defender.finalCritDamageReduction);
    }

    // =========================
    // 5. 伤害加成
    // =========================

    damage *= 1 + attacker.finalDamageBonus;

    // =========================
    // 6. 伤害减免
    // =========================

    damage *= (1 - defender.finalDamageReduction);

    // =========================
    // 7. 最终伤害
    // =========================

    final finalDamage = max(minimumDamage, damage.floor());

    return DamageResult(
      attack: attack,
      effectiveDefense: effectiveDefense,
      reduction: reduction,
      isCritical: isCritical,
      isHit: true,
      damage: finalDamage,
    );
  }

  // =========================
  // 计算命中
  // =========================

  bool checkHit({
    required CombatStats attacker,
    required CombatStats defender,
  }) {
    final hitChance = (attacker.finalAccuracy * (1 - defender.finalDodgeChance))
        .clamp(minimumAccuracy, 1.0);

    return random.nextDouble() < hitChance;
  }

  // =========================
  // 完整攻击
  // =========================

  CombatResult attackTarget({
    required Combatant attacker,
    required Combatant defender,
    double? attackOverride,
  }) {
    // =========================
    // 1. 攻击者死亡
    // =========================

    if (attacker.isDead) {
      return _emptyResult(defender);
    }

    // =========================
    // 2. 目标死亡
    // =========================

    if (defender.isDead) {
      return _emptyResult(defender);
    }

    // =========================
    // 3. 目标无敌
    // =========================

    if (defender.isInvulnerable) {
      return CombatResult(
        isHit: false,
        isCritical: false,
        isDodged: false,
        isInvulnerable: true,
        damage: 0,
        shieldDamage: 0,
        hpDamage: 0,
        healed: 0,
        reflectedDamage: 0,
        targetDead: false,
      );
    }

    // =========================
    // 4. 命中判断
    // =========================

    final hit = checkHit(attacker: attacker.stats, defender: defender.stats);

    if (!hit) {
      return CombatResult(
        isHit: false,
        isCritical: false,
        isDodged: true,
        isInvulnerable: false,
        damage: 0,
        shieldDamage: 0,
        hpDamage: 0,
        healed: 0,
        reflectedDamage: 0,
        targetDead: false,
      );
    }

    // =========================
    // 5. 计算伤害
    // =========================
    final damageResult = calculateDamage(
      attacker: attacker.stats,
      defender: defender.stats,
      attackOverride: attackOverride,
    );
    var remainingDamage = damageResult.damage;

    // =========================
    // 6. 护盾吸收
    // =========================
    final shieldDamage = min(defender.shield, remainingDamage);
    defender.shield -= shieldDamage;
    remainingDamage -= shieldDamage;

    // =========================
    // 7. 扣除血量
    // =========================
    final hpDamage = defender.takeDamage(remainingDamage);

    // =========================
    // 8. 吸血
    // =========================
    var healed = 0;
    if (hpDamage > 0 && !attacker.isDead) {
      final healAmount = (hpDamage * attacker.stats.finalLifesteal).floor();
      healed = attacker.heal(healAmount);
    }

    // =========================
    // 9. 反伤
    // =========================
    var reflectedDamage = 0;
    if (hpDamage > 0 && !attacker.isDead) {
      final reflectAmount = (hpDamage * defender.stats.finalReflect).floor();
      reflectedDamage = attacker.takeDamage(reflectAmount);
    }

    // =========================
    // 10. 受伤无敌
    // =========================
    if (hpDamage > 0 && !defender.isDead) {
      defender.setInvulnerability(invulnerabilityDuration);
    }

    // =========================
    // 11. 返回结果
    // =========================
    return CombatResult(
      isHit: true,
      isCritical: damageResult.isCritical,
      isDodged: false,
      isInvulnerable: false,
      damage: damageResult.damage,
      shieldDamage: shieldDamage,
      hpDamage: hpDamage,
      healed: healed,
      reflectedDamage: reflectedDamage,
      targetDead: defender.isDead,
    );
  }

  CombatResult _emptyResult(Combatant defender) {
    return CombatResult(
      isHit: false,
      isCritical: false,
      isDodged: false,
      isInvulnerable: false,
      damage: 0,
      shieldDamage: 0,
      hpDamage: 0,
      healed: 0,
      reflectedDamage: 0,
      targetDead: defender.isDead,
    );
  }
}

/// 战斗计算
/*
class CombatCalculator {
  /// 防御系数
  final double defenseConstant;

  /// 最低伤害
  final int minimumDamage;

  final Random random;

  CombatCalculator({
    this.defenseConstant = 0,
    this.minimumDamage = 1,
    Random? random,
  }) : random = random ?? Random();

  /// 计算伤害
  /// - [attacker] 攻击方
  /// - [defender] 防御方
  DamageResult calculateDamage({
    required CombatStats attacker,
    required CombatStats defender,
  }) {
    final attack = attacker.attack;
    final defense = defender.defense;

    // 防御减伤
    final reduction = defense <= 0
        ? 0.0
        : defense / (defense + defenseConstant);

    // 普通伤害
    double damage = reduction >= 1
        ? max(attack - reduction, 0) //超过1, 表示直接减伤
        : attack * (1 - reduction); //比例减伤

    // 暴击判断
    final bool isCritical;
    final critChance = attacker.critChance;
    if (critChance > 0) {
      isCritical = random.nextDouble() < critChance;
      // 暴击伤害
      if (isCritical) {
        damage *= attacker.critDamage;
      }
    } else {
      isCritical = false;
    }

    // 最终伤害
    final finalDamage = max(minimumDamage, damage.floor());

    return DamageResult(
      damage: finalDamage,
      isCritical: isCritical,
      attack: attack,
      reduction: reduction,
    );
  }
}
*/
