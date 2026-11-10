import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/10
///
/// 游戏属性颜色
class GameAttributeColors {
  GameAttributeColors._();

  /// 攻击
  static const Color attack = Color(0xFFFF4D4F);

  /// 防御
  static const Color defense = Color(0xFF3498DB);

  /// 生命
  static const Color health = Color(0xFF2ECC71);

  /// 暴击率
  static const Color criticalRate = Color(0xFFFFD700);

  /// 命中率
  static const Color hitRate = Color(0xFF5B8FF9);

  /// 闪避率
  static const Color dodgeRate = Color(0xFF00D2A0);

  /// 暴击伤害
  static const Color criticalDamage = Color(0xFFE056FD);

  /// 攻击速度
  static const Color attackSpeed = Color(0xFF00D2D3);

  /// 移动速度
  static const Color moveSpeed = Color(0xFFFF8C42);

  /// 能量值
  static const Color energy = Color(0xFFA78BFA);

  /// 金币
  static const Color gold = Color(0xFFF1C40F);

  /// 吸血
  static const Color lifesteal = Color(0xFFE84393);

  /// 反伤
  static const Color reflectDamage = Color(0xFFFF7043);

  /// 护盾
  static const Color shield = Color(0xFF00B8D9);

  /// 防御穿透
  static const Color defensePenetration = Color(0xFF9B59B6);
}

/// 游戏文本颜色
/// - 血量变化
/// - 攻击力变化
/// - 防御力变化
/// - 金币变化
/// - 能量变化
/// - 分数变化
/// - 倒计时变化
class GameTextColors {
  GameTextColors._();

  /// 属性颜色
  ///    属性	     主色	   HEX     	  RGB
  /// - 血量 HP	   ●    #FF4D6D	  255, 77, 109
  /// - 攻击 ATK	   ●    #FF9F43	  255, 159, 67
  /// - 防御 DEF	   ●    #56A8FF	  86, 168, 255
  /// - 金币 GOLD	  ●	  #FFD54F	  255, 213, 79
  /// - 能量 ENERGY	●	  #39D5FF	  57, 213, 255
  /// - 分数 SCORE  	●	  #B794FF	  183, 148, 255
  /// - 倒计时 TIME	●	  #62E6A7	  98, 230, 167
  static const Color hp = Color(0xFFFF4D6D);
  static const Color attack = Color(0xFFFF9F43);
  static const Color defense = Color(0xFF56A8FF);
  static const Color gold = Color(0xFFFFD54F);
  static const Color energy = Color(0xFF39D5FF);
  static const Color score = Color(0xFFB794FF);
  static const Color countdown = Color(0xFF62E6A7);

  /// 数值变化颜色
  static const Color increase = Color(0xFF52FF9A);
  static const Color decrease = Color(0xFFFF4757);
  static const Color normal = Color(0xFFFFFFFF);
  static const Color critical = Color(0xFFFFD700);
  static const Color healing = Color(0xFF42E8FF);
  static const Color warning = Color(0xFFFF8C42);
  static const Color danger = Color(0xFFFF334F);
}

/// 属性图标名称配置
class GameAttributeIcons {
  GameAttributeIcons._();

  static const IconData hp = Icons.favorite;
  static const IconData attack = Icons.flash_on;
  static const IconData defense = Icons.shield;
  static const IconData gold = Icons.monetization_on;
  static const IconData energy = Icons.bolt;
  static const IconData score = Icons.emoji_events;
  static const IconData countdown = Icons.timer;
}
