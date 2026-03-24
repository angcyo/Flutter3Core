///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/23
///
///
/// https://juejin.cn/post/7578402574653112372
///
/// 先科普一下，什么叫零宽字符？
/// 在Unicode字符集中，有一类神奇的字符。它们存在，但不占用任何宽度，也不显示任何像素。
/// 简单说，它们是隐形的。
/// 最常见的几个：
///
/// - \u200b (Zero Width Space)：零宽空格
/// - \u200c (Zero Width Non-Joiner)：零宽非连字符
/// - \u200d (Zero Width Joiner)：零宽连字符
///
/// # 不可见格式控制符
///
/// https://www.unicode.org/versions/Unicode15.0.0/ch23.pdf
///
/// 2. 双向文本隔离与嵌入 (Bidi Controls)
///
/// 用于处理极其复杂的多种语言混排（如在英文句子中插入阿拉伯语）。
/// - U+202A (LRE): 左至右嵌入 (Left-to-Right Embedding)
/// - U+202B (RLE): 右至左嵌入 (Right-to-Left Embedding)
/// - U+202C (PDF): 结束定向格式化 (Pop Directional Formatting)
/// - U+202D (LRO): 左至右强制覆盖 (Left-to-Right Override)
/// - U+202E (RLO): 右至左强制覆盖 (Right-to-Left Override)
/// - U+2066 (LRI): 左至右隔离 (Left-to-Right Isolate)
/// - U+2067 (RLI): 右至左隔离 (Right-to-Left Isolate)
/// - U+2068 (FSI): 首个强方向隔离 (First Strong Isolate)
/// - U+2069 (PDI): 结束定向隔离 (Pop Directional Isolate)
///
/// - \u200e (Left-to-Right Mark, LRM): 强行指示后续文本按 LTR 处理。
/// - \u200f (Right-to-Left Mark, RLM): 强行指示后续文本按 RTL 处理。
/// - \u202a / \u202b / \u202c: 分别是嵌入式 LTR、嵌入式 RTL 以及定向重置符号（PDF）。
///
void main() {
  final t1 = "abcd";
  print("$t1->${t1.length}");
  final t2 = "ab\u200acd";
  print("$t2->${t2.length}");
  final t3 = "ab\u200bcd";
  print("$t3->${t3.length}");
  final t4 = "ab\u200ccd";
  print("$t4->${t4.length}");
  final t5 = "ab\u200dcd";
  print("$t5->${t5.length}");
  final t6 = "ab\u200ecd";
  print("$t6->${t6.length}");
  final t7 = "ab\u200fcd";
  print("$t7->${t7.length}");
  print("...end!");
}
