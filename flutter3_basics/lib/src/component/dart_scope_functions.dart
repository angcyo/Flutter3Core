///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/27
///
/// [dart_scope_functions: ^0.1.4](https://pub.dev/packages/dart_scope_functions)
///
library;

/// Kotlin-inspired scope functions implemented in Dart with the goal of
/// executing a block of code within the context of an object.

/// Extensions that can be used on any type [T].
extension ScopeFunctionExt<T> on T {
  /// Calls the specified function [block] with this value as its argument and
  /// returns `this` value.
  T also(void Function(T it) block) {
    block.call(this);
    return this;
  }

  /// Calls the specified function [block] with `this` value as its argument and
  /// returns its result.
  R let<R>(R Function(T it) block) {
    return block.call(this);
  }

  /// Returns `this` value if it satisfies the given [predicament] or null if
  /// it doesn't.
  T? takeIf(bool Function(T it) predicament) {
    return predicament.call(this) ? this : null;
  }

  /// Returns `this` value if it does not satisfy the given [predicament] or
  /// null if it does.
  T? takeUnless(bool Function(T it) predicament) {
    return predicament.call(this) ? null : this;
  }

  T apply(void Function(T it) block) {
    block.call(this);
    return this;
  }
}

/// Extensions that can be used on any nullable type [T].
extension ScopeFunctionNullableExt<T> on T? {
  /// Calls the specified function [block] with `this` value as its argument and
  /// returns its result. In case `this` is null, it will return whatever is
  /// provided in [orElse].
  R letWithElse<R>(R Function(T it) block, {required R orElse}) {
    return this?.let((innerIt) => block.call(innerIt)) ?? orElse;
  }

  /// This extension is used to prevent using `??` (null-coalescing operator)
  /// in favor of a more functional approach. In case the provided value of type
  /// [T] is null, it will return provided [defaultValue].
  T withDefault(T defaultValue) {
    return this ?? defaultValue;
  }
}

/// Calls the specified function [block] and returns its result.
R run<R>(R Function() block) => block.call();
