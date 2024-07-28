part of '../../flutter3_basics.dart';

/// 抖动处理, 防止多次调用, 只执行最后一次
/// A utility class for debouncing function calls.
///
/// The `Debounce` class allows you to debounce function calls, ensuring that a function is only executed after a specified delay, and resetting the timer with each call. This can be useful in scenarios where you want to delay the execution of a function until after a user has finished a series of rapid inputs, such as in search bars or input fields.
///
/// Example Usage:
/// ```dart
/// // Create a debounce instance with a 500 milliseconds delay.
/// final debounce = Debounce(Duration(milliseconds: 500));
///
/// // Call a function and debounce its execution.
/// debounce(() {
///   // Your function logic here.
/// });
///
/// // Dispose of the debounce timer when no longer needed.
/// debounce.dispose();
/// ```
/// [Throttle]
/// [Debounce]
class Debounce {
  /// The duration of the debounce delay.
  final Duration delay;

  Timer? _timer;

  /// Creates a debounce instance with the specified delay duration.
  ///
  /// The `delay` parameter specifies the duration to wait before executing the debounced function.
  ///
  /// Example Usage:
  /// ```dart
  /// // Create a debounce instance with a 500 milliseconds delay.
  /// final debounce = Debounce(Duration(milliseconds: 500));
  /// ```
  Debounce(
    this.delay,
  );

  /// Calls the provided callback function with debouncing.
  ///
  /// The `callback` parameter is a function that you want to debounce. The debounced function will be called after the specified delay has passed, and if subsequent calls are made within the delay period, the timer will be reset.
  ///
  /// Example Usage:
  /// ```dart
  /// // Call a function and debounce its execution.
  /// debounce(() {
  ///   // Your function logic here.
  /// });
  /// ```
  call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Disposes of the debounce timer, preventing any further calls.
  ///
  /// Call this method when you no longer need to debounce function calls to clean up resources.
  ///
  /// Example Usage:
  /// ```dart
  /// // Dispose of the debounce timer when no longer needed.
  /// debounce.dispose();
  /// ```
  dispose() {
    _timer?.cancel();
  }
}

/// https://pub.dev/packages/dev_prokit
extension DebounceFunction on Function {
  /// No parameter button debouncing,
  /// Default parameter 200 milliseconds.
  ///
  /// Example :
  /// ```
  /// GestureDetector(
  ///   onTap:(){
  ///     print('Other events!');
  ///   }.debounce();
  /// )
  /// ```
  Function() debounce([int millisecond = 200]) {
    Timer? debounceTimer;
    return () {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(Duration(milliseconds: millisecond), () {
        this.call();
        debounceTimer = null;
      });
    };
  }

  /// Button debounce event with one event parameter,
  /// Default parameter 200 milliseconds.
  ///
  /// Example :
  /// ```
  /// GestureDetector(
  ///   onTapUp: (details) {
  ///     print('one param');
  ///   }.debounceParam(),
  ///   child: Text('Debounce'),
  /// )
  /// ```
  Function(T) debounceParam<T>([int millisecond = 200]) {
    Timer? debounceTimer;
    return (t) {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(Duration(milliseconds: millisecond), () {
        this.call(t);
        debounceTimer = null;
      });
    };
  }

  /// Button debounce event with two event parameter,
  /// Default parameter 200 milliseconds.
  ///
  /// Example :
  /// ```
  /// // Define :
  /// class MethodWidget extends StatelessWidget {
  ///   const MethodWidget({super.key, this.itemMethod});
  ///   final Function(String, int)? itemMethod;
  /// }
  /// // Use :
  /// MethodWidget(
  ///   itemMethod:(name,index) {
  ///     print('$name-$index');
  ///   }.debounceParam2(),
  /// )
  /// ```
  Function(T, K) debounceParam2<T, K>([int millisecond = 200]) {
    Timer? debounceTimer;
    return (t, k) {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(Duration(milliseconds: millisecond), () {
        this.call(t, k);
        debounceTimer = null;
      });
    };
  }
}
