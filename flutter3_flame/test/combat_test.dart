import 'package:flutter3_flame/src/combat/combat_stats.dart';
import 'package:flutter3_flame/src/combat/combat_system.dart';
import 'package:flutter3_flame/src/combat/combatant.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/09
///
/// 战斗测试
void main() {
  //test1();
  test2();
}

void test2() {
  final playerStats = CombatStats(
    baseAttack: 200,
    baseDefense: 100,
    baseHP: 2000,

    baseCritChance: 0.1,
    critDamage: 1.5,

    accuracy: 0.95,
    dodgeChance: 0.1,

    penetration: 20,

    damageBonus: 0.2,
    damageReduction: 0.1,

    critResistance: 0.1,
    critDamageReduction: 0.2,

    lifesteal: 0.2,
    reflect: 0.1,

    baseShield: 300,
  );

  final player = Combatant(id: 'player', stats: playerStats);

  final enemyStats = CombatStats(
    baseAttack: 100,
    baseDefense: 50,
    baseHP: 1000,

    baseCritChance: 0.05,
    critDamage: 1.5,

    accuracy: 0.9,
    dodgeChance: 0.05,

    penetration: 0,

    damageBonus: 0,
    damageReduction: 0.1,

    critResistance: 0,
    critDamageReduction: 0,

    lifesteal: 0,
    reflect: 0,

    baseShield: 100,
  );

  final enemy = Combatant(id: 'enemy_001', stats: enemyStats);

  final calculator = CombatCalculator();

  for (int i = 0; i < 10; i++) {
    print('\n->回合: $i');
    final result = calculator.attackTarget(attacker: player, defender: enemy);

    print('命中: ${result.isHit}');
    print('暴击: ${result.isCritical}');
    print('闪避: ${result.isDodged}');
    print('伤害: ${result.damage}');
    print('护盾损失: ${result.shieldDamage}');
    print('血量损失: ${result.hpDamage}');
    print('吸血: ${result.healed}');
    print('反伤: ${result.reflectedDamage}');
    print('敌机死亡: ${result.targetDead}');
  }
}

/*
void test1(){
  // 玩家属性
  const playerStats = CombatStats(
    baseAttack: 200,
    baseDefense: 100,
    baseCritChance: 0.5,
    critDamage: 1.5,
    baseHP: 2000,
  );

  // 敌人属性
  const enemyStats = CombatStats(
    baseAttack: 100,
    baseDefense: 50,
    baseCritChance: 0.3,
    critDamage: 1.5,
    baseHP: 1000,
  );

  final playerHP = Health(maxHP: playerStats.maxHP);
  final enemyHP = Health(maxHP: enemyStats.maxHP);
  final calculator = CombatCalculator(defenseConstant: 100);

  for (int i = 0; i < 10; i++) {
    print('\n->回合: $i');

    // 玩家攻击敌人
    final result = calculator.calculateDamage(
      attacker: playerStats,
      defender: enemyStats,
    );

    // 扣除敌人血量
    final actualDamage = enemyHP.takeDamage(result.damage);

    print('攻击力: ${playerStats.attack}');
    print('敌人防御: ${enemyStats.defense}');
    print('暴击: ${result.isCritical}');
    print('伤害: $actualDamage');
    print('敌人剩余血量: ${enemyHP.hp}');
    print('敌人死亡: ${enemyHP.isDead}');

    // 敌人反击
    final enemyResult = calculator.calculateDamage(
      attacker: enemyStats,
      defender: playerStats,
    );

    playerHP.takeDamage(enemyResult.damage);

    print('玩家剩余血量: ${playerHP.hp}');
  }
}*/
