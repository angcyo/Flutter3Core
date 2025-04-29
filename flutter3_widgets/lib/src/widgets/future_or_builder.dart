part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/10
///
/// 支持[FutureOr]类型的[FutureBuilder]
class FutureOrBuilder extends StatefulWidget {
  /// 异步方法
  final FutureOr Function() futureOr;

  final Widget Function(BuildContext context, dynamic value) builder;

  /// [initialData] 当初始化的值有值时, 则直接触发[builder], 不会执行[futureOr]
  final dynamic initialData;

  final Widget Function(BuildContext context, dynamic error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  const FutureOrBuilder(
    this.futureOr,
    this.builder, {
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.initialData,
  });

  @override
  State<FutureOrBuilder> createState() => _FutureOrBuilderState();
}

class _FutureOrBuilderState extends State<FutureOrBuilder> {
  @override
  Widget build(BuildContext context) {
    if (widget.initialData != null) {
      return widget.builder.call(context, widget.initialData);
    }
    return FutureBuilder(
      future: () async {
        return widget.futureOr.call();
      }(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error) ??
              GlobalConfig.of(context)
                  .errorPlaceholderBuilder(context, snapshot.error);
        }
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return widget.emptyBuilder?.call(context) ??
                GlobalConfig.of(context).emptyPlaceholderBuilder(context, null);
          } else {
            return widget.builder.call(context, snapshot.data);
          }
        }
        return widget.loadingBuilder?.call(context) ??
            GlobalConfig.of(context)
                .loadingIndicatorBuilder(context, this, null, null);
      },
    );
  }
}
