part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/01
///
/// [WidgetState] 状态
/// [WidgetStateProperty]
/// [WidgetStatePropertyAll]
/// [WidgetStateColor]
class WidgetStatePropertyColorMap extends WidgetStateProperty<Color> {
  /// 每一种状态对应一种颜色
  final Map<WidgetState, Color>? colorMap;

  final Color defaultColor;

  WidgetStatePropertyColorMap(this.defaultColor, {this.colorMap});

  @override
  Color resolve(Set<WidgetState> states) {
    assert(() {
      l.v('小部件状态:$states');
      return true;
    }());
    Color? result;
    colorMap?.keys.forEach((key) {
      if (states.contains(key)) {
        result = colorMap?[key] ?? defaultColor;
        return;
      }
    });
    return result ?? colorMap?[states.first] ?? defaultColor;
  }
}
