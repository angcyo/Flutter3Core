part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/03
///
/// 断点, 实现响应式布局
///
/// https://v5.bootcss.com/docs/layout/breakpoints/
///
/// ```
/// Breakpoint          | Class infix | Dimensions
/// --------------------|-------------|------------
/// Extra small         | None        | <576px
/// Small               | sm          | ≥576px
/// Medium              | md          | ≥768px
/// Large               | lg          | ≥992px
/// Extra large         | xl          | ≥1200px
/// Extra extra large   | xxl         | ≥1400px
/// ```
double $wXlBp({double min = 300, double max = 400}) =>
    $screenWidth >= 1200 ? max : min;

//mark: - 断点

/// end container Breakpoints
/// - 结束面板(右边的面板)容器宽度断点
/// - 使用[animatedContainer]动画改变大小
@dp
double $ecwBp() => switch ($screenWidth) {
  >= 1600 => 600,
  >= 1400 => 500,
  >= 1100 => 400,
  >= 700 => 300,
  >= 300 => 200,
  _ => 100,
};

/// 断点网格列数
/// - 根据不同的屏幕宽度, 返回不同的列数
int $gridBp() => switch ($screenWidth) {
  >= 1600 => 6,
  >= 1400 => 5,
  >= 1100 => 4,
  >= 700 => 3,
  >= 300 => 2,
  _ => 1,
};
