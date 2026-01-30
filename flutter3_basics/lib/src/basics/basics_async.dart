part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/30
///
/// 异步

/// 等待[milliseconds]毫秒
///
/// - [wait]
/// - [sleep]
/// - [delayed]
@Alias("delayed")
Future wait([int milliseconds = 1]) =>
    Future.delayed(Duration(milliseconds: milliseconds));

/// - [wait]
/// - [sleep]
/// - [delayed]
@Alias("delayed")
Future sleep([int milliseconds = 1]) => wait(milliseconds);

/// 延迟执行
/// - [wait]
/// - [sleep]
/// - [delayed]
@Alias("Future.delayed")
Future delayed([Duration? duration]) =>
    Future.delayed(duration ?? Duration(milliseconds: 1));

/// [Future.wait]
Future<List<T>> waitAll<T>(
  Future<T>? f1,
  Future<T>? f2,
  Future<T>? f3,
  Future<T>? f4,
  Future<T>? f5,
  Future<T>? f6,
  Future<T>? f7,
  Future<T>? f8,
  Future<T>? f9,
) => Future.wait([f1, f2, f3, f4, f5, f6, f7, f8, f9].filterNull());

extension FutureEx<T> on Future<T> {
  /// 合并[Future.then]和[Future.catchError]方法
  /// - [throwError] [get]中遇到的错误是否重新抛出?
  Future get(
    ValueErrorCallback? get, {
    StackTrace? stack,
    bool? throwError,
    String? tag,
  }) {
    stack ??= StackTrace.current;
    return then(
      (value) {
        try {
          //debugger();
          final data = get?.call(value, null); //这一层的错误会被捕获
          return data ?? value;
        } catch (error, s) {
          //debugger();
          if (throwError == true) {
            rethrow;
          } else {
            assert(() {
              l.w('[$tag]FutureGet异常:$error↓');
              printError(error, stack /*s */ /*stack*/);
              return true;
            }());
          }
          get?.call(null, error); //这一层的错误可以走正常的Future异常处理
          return null;
        }
      },
      onError: (error, errorStack) {
        //debugger();
        //此处无法捕获[get]中的异常
        if (error is RCancelException) {
          assert(() {
            l.w('[$tag]操作被取消:$error');
            return true;
          }());
        } else if (error is FutureCancelException) {
          assert(() {
            l.w('[$tag]Future被取消:$error');
            return true;
          }());
        } else {
          if (throwError == true) {
            throw error;
          } else {
            assert(() {
              l.w('[$tag]Future异常:$error↓');
              //printError(error, stack ?? errorStack);
              return true;
            }());
          }
          get?.call(null, error);
        }
      },
    );
  }

  /// 支持类型的[FutureEx.get]方法
  Future getValue(
    dynamic Function(T? value, dynamic error)? get, {
    StackTrace? stack,
    bool? throwError,
    String? tag,
  }) => this.get(
    (value, error) {
      if (error != null) {
        get?.call(null, error);
        return null;
      } else {
        get?.call(value, null);
        return value;
      }
    },
    stack: stack,
    throwError: throwError,
    tag: tag,
  );

  /// 获取[Future]的错误信息, 有错误时, 才会触发[get]方法
  Future getError(
    dynamic Function(dynamic error)? get, {
    StackTrace? stack,
    bool? throwError,
    String? tag,
  }) => this.get(
    (value, error) {
      if (error != null) {
        get?.call(error);
      }
      return value;
    },
    stack: stack,
    throwError: throwError,
    tag: tag,
  );

  /// 等待[Future]完成
  Future<T> wait(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) {
    //Future.wait([this]).timeout(timeLimit);
    return timeout(timeLimit, onTimeout: onTimeout);
  }

  /// 此方法并不能立即出发[Future]
  /// 不需要等待当前的[Future]执行完成, 但是会报告错误
  /// [FutureExtensions.ignore] 完成和错误都被忽略
  void unAwait() {
    unawaited(this);
  }

  /// 忽略[Future]的错误
  Future ignoreError() async {
    try {
      await this;
    } catch (e) {
      // 忽略错误
    }
  }

  /// [initialData] 当初始化的值有值时, 则直接触发[builder]
  /// [FutureBuilder]
  /// [FutureOrBuilder]
  Widget toWidget(
    Widget Function(BuildContext context, T? value) builder, {
    Widget Function(BuildContext context, dynamic error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context)? emptyBuilder,
    T? initialData,
  }) {
    if (initialData != null) {
      return Builder(builder: (context) => builder.call(context, initialData));
    }
    return FutureBuilder<T>(
      future: this,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              GlobalConfig.of(
                context,
              ).errorPlaceholderBuilder(context, snapshot.error);
        }
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return emptyBuilder?.call(context) ??
                GlobalConfig.of(context).emptyPlaceholderBuilder(context, null);
          } else {
            return builder.call(context, snapshot.data);
          }
        }
        return loadingBuilder?.call(context) ??
            GlobalConfig.of(
              context,
            ).loadingIndicatorBuilder(context, this, null, null);
      },
    );
  }
}
