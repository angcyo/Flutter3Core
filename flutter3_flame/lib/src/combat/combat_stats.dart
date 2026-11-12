import 'dart:math';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 战斗属性
///
/// - [Combatant] 角色
///   - [CombatStats] 属性
/// - [CombatCalculator] 计算
class CombatStats {
  //MARK: 基础属性

  // =========================
  // 基础属性
  // =========================

  /// 基础攻击力
  double baseAttack;

  /// 固定攻击加成
  /// - 在 [baseAttack] 上直接加成
  /// 0: 无加成
  double flatAttack;

  /// 攻击百分比加成
  /// - 在最终攻击力上比例加成
  /// 0: 无加成
  double attackBonus;

  /// 基础防御力
  double baseDefense;

  /// 固定防御加成
  /// - 在 [baseDefense] 上直接加成
  /// 0: 无加成
  double flatDefense;

  /// 防御百分比加成
  /// - 在最终防御力上比例加成
  /// 0: 无加成
  double defenseBonus;

  /// 基础血量
  double baseHP;

  /// 固定血量加成
  /// - 在 [baseHP] 上直接加成
  /// 0: 无加成
  double flatHP;

  /// 血量百分比加成
  /// - 在最终血量上比例加成
  /// 0: 无加成
  double hpBonus;

  //MARK: 暴击属性

  // =========================
  // 暴击属性
  // =========================

  /// 基础暴击率 [0~1]
  double baseCritChance;

  /// 暴击率额外加成
  /// - 在 [baseCritChance] 上加成
  /// 0: 无加成
  double bonusCritChance;

  /// 暴击伤害倍率
  /// - 在最终暴击伤害上比例加成
  /// 1: 无加成
  double critDamage;

  /// 暴击概率抵抗
  /// - 在最终暴击概率上比例减成
  /// 0: 无抵抗
  double critResistance;

  /// 暴击伤害减免
  /// - 在最终暴击伤害上比例减成
  /// 0: 无减免
  double critDamageReduction;

  //MARK: 命中与闪避

  // =========================
  // 命中与闪避
  // =========================

  /// 命中率
  double accuracy;

  /// 闪避率
  double dodgeChance;

  //MARK: 防御穿透

  // =========================
  // 防御穿透
  // =========================

  /// 防御穿透
  /// - 直接需要减去的防御值
  double penetration;

  //MARK: 伤害属性

  // =========================
  // 伤害属性
  // =========================

  /// 伤害加成
  ///
  /// - [finalDamageBonus]
  double damageBonus;

  /// 伤害减免比例
  ///
  /// - [finalDamageReduction]
  double damageReduction;

  //MARK: 吸血与反伤

  // =========================
  // 吸血与反伤
  // =========================

  /// 吸血比例
  /// - 造成伤害时, 血量恢复比例
  ///
  /// - [finalLifesteal]
  double lifesteal;

  /// 反伤比例
  /// - 造成伤害时, 反弹伤害的比例
  ///
  /// - [finalReflect]
  double reflect;

  //MARK: 护盾

  // =========================
  // 护盾
  // =========================

  /// 基础护盾
  double baseShield;

  /// 固定护盾加成
  double flatShield;

  CombatStats({
    //--
    this.baseAttack = 100,
    this.flatAttack = 0,
    this.attackBonus = 0,
    //--
    this.baseDefense = 20,
    this.flatDefense = 0,
    this.defenseBonus = 0,
    //--
    this.baseHP = 1000,
    this.flatHP = 0,
    this.hpBonus = 0,
    //--
    this.baseCritChance = 0 /*0.05*/,
    this.bonusCritChance = 0,
    this.critDamage = 1.5,
    //--
    this.critResistance = 0,
    this.critDamageReduction = 0,
    //--命中率
    this.accuracy = 1,
    //--闪避率
    this.dodgeChance = 0,
    //--防御穿透
    this.penetration = 0,
    //--
    this.damageBonus = 0,
    this.damageReduction = 0,
    //--吸血
    this.lifesteal = 0,
    //--反伤
    this.reflect = 0,
    //--
    this.baseShield = 0,
    this.flatShield = 0,
  });

  // =========================
  // 最终攻击力
  // =========================

  double get attack {
    return max(0, (baseAttack + flatAttack) * (1 + attackBonus));
  }

  // =========================
  // 最终防御力
  // =========================

  double get defense {
    return max(0, (baseDefense + flatDefense) * (1 + defenseBonus));
  }

  // =========================
  // 暴击概率
  // =========================

  double get critChance {
    return _clamp01(baseCritChance + bonusCritChance);
  }

  // =========================
  // 暴击伤害倍率
  // =========================

  double get finalCritDamage {
    return max(1, critDamage);
  }

  // =========================
  // 命中率
  // =========================

  double get finalAccuracy {
    return _clamp01(accuracy);
  }

  // =========================
  // 闪避率
  // =========================

  double get finalDodgeChance {
    return _clamp01(dodgeChance);
  }

  // =========================
  // 防御穿透
  // =========================

  double get finalPenetration {
    return max(0, penetration);
  }

  // =========================
  // 暴击抵抗
  // =========================

  double get finalCritResistance {
    return _clamp01(critResistance);
  }

  // =========================
  // 暴击伤害减免
  // =========================

  double get finalCritDamageReduction {
    return _clamp01(critDamageReduction);
  }

  // =========================
  // 伤害加成
  // =========================

  double get finalDamageBonus {
    return max(-1, damageBonus);
  }

  // =========================
  // 伤害减免
  // =========================

  double get finalDamageReduction {
    return _clamp01(damageReduction);
  }

  // =========================
  // 吸血
  // =========================

  double get finalLifesteal {
    return max(0, lifesteal);
  }

  // =========================
  // 反伤
  // =========================

  double get finalReflect {
    return max(0, reflect);
  }

  // =========================
  // 最大血量
  // =========================

  int get maxHP {
    return max(1, ((baseHP + flatHP) * (1 + hpBonus)).round());
  }

  // =========================
  // 初始护盾
  // =========================

  int get initialShield {
    return max(0, (baseShield + flatShield).round());
  }

  static double _clamp01(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }
}

/*class CombatStats {
  /// 基础攻击力
  final double baseAttack;

  /// 固定攻击加成
  /// - 在 [baseAttack] 上直接加成
  /// 0: 无加成
  final double flatAttack;

  /// 攻击百分比加成
  /// - 在最终攻击力上比例加成
  /// 0: 无加成
  final double attackBonus;

  /// 基础防御力
  final double baseDefense;

  /// 固定防御加成
  /// - 在 [baseDefense] 上直接加成
  /// 0: 无加成
  final double flatDefense;

  /// 防御百分比加成
  /// - 在最终防御力上比例加成
  /// 0: 无加成
  final double defenseBonus;

  /// 基础暴击率
  final double baseCritChance;

  /// 暴击率额外加成
  /// - 在 [baseCritChance] 上加成
  /// 0: 无加成
  final double bonusCritChance;

  /// 暴击伤害倍率
  final double critDamage;

  /// 基础最大血量
  final double baseHP;

  /// 固定血量加成
  /// - 在 [baseHP] 上直接加成
  /// 0: 无加成
  final double flatHP;

  /// 血量百分比加成
  /// - 在最终血量上比例加成
  /// 0: 无加成
  final double hpBonus;

  const CombatStats({
    this.baseAttack = 100,
    this.flatAttack = 0,
    this.attackBonus = 0,
    this.baseDefense = 20,
    this.flatDefense = 0,
    this.defenseBonus = 0,
    this.baseCritChance = 0 */ /*0.05*/ /*,
    this.bonusCritChance = 0,
    this.critDamage = 1.5,
    //--
    this.baseHP = 1000,
    this.flatHP = 0,
    this.hpBonus = 0,
  });

  /// 最终攻击力
  double get attack {
    return max(0, (baseAttack + flatAttack) * (1 + attackBonus));
  }

  /// 最终防御力
  double get defense {
    return max(0, (baseDefense + flatDefense) * (1 + defenseBonus));
  }

  /// 最终暴击概率
  double get critChance {
    return (baseCritChance + bonusCritChance).clamp(0.0, 1.0).toDouble();
  }

  /// 最终最大血量
  int get maxHP {
    return max(1, ((baseHP + flatHP) * (1 + hpBonus)).round());
  }
}*/

/// 血量管理
class Health {
  int _maxHP;
  int _hp;

  Health({required int maxHP, int? currentHP})
    : _maxHP = max(1, maxHP),
      _hp = (currentHP ?? maxHP).clamp(0, max(1, maxHP));

  int get maxHP => _maxHP;

  int get hp => _hp;

  bool get isAlive => _hp > 0;

  bool get isDead => _hp <= 0;

  double get percentage {
    return _hp / _maxHP;
  }

  /// 受到伤害
  int takeDamage(int damage) {
    if (isDead || damage <= 0) {
      return 0;
    }

    final actualDamage = min(_hp, damage);
    _hp -= actualDamage;
    return actualDamage;
  }

  /// 恢复血量
  int heal(int amount) {
    if (isDead || amount <= 0) {
      return 0;
    }

    final actualHeal = min(amount, _maxHP - _hp);
    _hp += actualHeal;
    return actualHeal;
  }

  /// 设置最大血量
  void setMaxHP(int value, {bool fill = false}) {
    _maxHP = max(1, value);

    if (fill) {
      _hp = _maxHP;
    } else {
      _hp = min(_hp, _maxHP);
    }
  }

  /// 复活
  void revive({int? hp}) {
    _hp = (hp ?? _maxHP).clamp(1, _maxHP);
  }
}
