import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/23
///
/// 游戏文本小部件
class GameOutlineText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color strokeColor;
  final double strokeWidth;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final PaintingStyle? paintingStyle;
  final Color fillColor;

  //--

  /// 渐变类型
  final GradientType? gradientType;

  /// 渐变颜色列表
  final List<Color>? gradientColors;

  const GameOutlineText({
    super.key,
    required this.text,
    this.fontSize = 48.0,
    this.strokeColor = Colors.white,
    this.fillColor = Colors.black,
    this.strokeWidth = 2.0,
    this.letterSpacing = 4,
    this.fontWeight = FontWeight.bold,
    this.paintingStyle,
    //--
    this.gradientType = .legendGold,
    this.gradientColors,
  });

  const GameOutlineText.item({
    super.key,
    required this.text,
    this.fontSize = 30.0,
    this.strokeColor = Colors.white,
    this.fillColor = Colors.black,
    this.strokeWidth = 2.0,
    this.letterSpacing = 4,
    this.fontWeight,
    this.paintingStyle,
    //--
    this.gradientType = .polarIceBlue,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final paintingStyle =
        this.paintingStyle ?? (fontWeight == FontWeight.bold ? .stroke : .fill);
    final strokeTextWidget = wrapShaderMask(
      Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          fontWeight: fontWeight,
          foreground: Paint()
            ..style = paintingStyle
            ..strokeWidth = strokeWidth
            ..strokeJoin = .round
            ..isAntiAlias = true
            ..color = strokeColor,
        ),
      ),
    );

    if (paintingStyle == .fill) {
      return strokeTextWidget;
    }

    //stroke + fill 消除字形交叉线
    final fillTextWidget = Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        foreground: Paint()
          ..style = .fill
          ..strokeWidth = 0
          ..strokeJoin = .round
          ..isAntiAlias = true
          ..color = fillColor,
      ),
    );
    return Stack(children: [strokeTextWidget, fillTextWidget]);
  }

  Widget wrapShaderMask(Widget child) {
    final colors = gradientColors ?? gradientType?.colors;
    if (colors == null) {
      return child;
    }
    return ShaderMask(
      blendMode: .srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(colors: colors).createShader(bounds);
      },
      child: child,
    ) /*.transform(Matrix4.skewX(-0.25)..rotateZ(-0.04))*/;
  }
}

/// 渐变颜色类型
enum GradientType {
  /// 赛博霓虹
  /// 科幻、射击、未来科技、技能标题
  cyberNeon([
    Color(0xFF00F5FF),
    Color(0xFF00A3FF),
    Color(0xFF7B2CFF),
    Color(0xFFFF35D3),
  ]),

  /// 传奇金
  /// 传奇装备、金币、成就、稀有奖励
  legendGold([
    Color(0xFFFFF3A0),
    Color(0xFFFFC928),
    Color(0xFFFF8A00),
    Color(0xFFFFF0B0),
  ]),

  /// 深渊紫 — 魔法与史诗
  /// 魔法技能、史诗装备、神秘角色
  deepPurple([
    Color(0xFFF0ABFC),
    Color(0xFFC084FC),
    Color(0xFF8B5CF6),
    Color(0xFF4C1D95),
  ]),

  /// 烈焰红 — 战斗与暴击
  /// 战斗提示、暴击伤害、攻击技能
  fieryRed([
    Color(0xFFFFF066),
    Color(0xFFFFB020),
    Color(0xFFFF4D00),
    Color(0xFFFF1744),
  ]),

  /// 极地冰蓝 — 冷酷科技
  /// 冰系技能、科技面板、冷色主题
  polarIceBlue([
    Color(0xFFFFFFFF),
    Color(0xFFB9F3FF),
    Color(0xFF55DFFF),
    Color(0xFF397BFF),
  ]);

  final List<Color> colors;

  const GradientType(this.colors);
}
