part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/09/15
///
/// 打分小部件
class RatingBarWidget extends StatefulWidget {
  /// 初始分数
  final double initialRating;

  /// 最小分数
  final double minRating;

  /// 最大分数
  final int itemCount;

  /// 是否允许半星
  final bool allowHalfRating;

  /// 分数更新回调
  final ValueChanged<double>? onRatingUpdate;

  /// 边距
  final EdgeInsetsGeometry? tileInsets;

  const RatingBarWidget({
    super.key,
    this.initialRating = 0,
    this.minRating = 1,
    this.itemCount = 5,
    this.allowHalfRating = true,
    this.onRatingUpdate,
    //--
    this.tileInsets,
  });

  @override
  State<RatingBarWidget> createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return RatingBar.builder(
      initialRating: widget.initialRating,
      minRating: widget.minRating,
      direction: Axis.horizontal,
      allowHalfRating: widget.allowHalfRating,
      itemCount: widget.itemCount,
      itemPadding: EdgeInsets.symmetric(horizontal: kL),
      itemBuilder: (context, _) =>
          Icon(Icons.star, color: globalTheme.accentColor /*Colors.amber*/),
      onRatingUpdate:
          widget.onRatingUpdate ??
          (rating) {
            assert(() {
              l.d("打分分数->$rating");
              return true;
            }());
          },
    ).paddingOnly(horizontal: kX, vertical: kL, insets: widget.tileInsets);
  }
}
