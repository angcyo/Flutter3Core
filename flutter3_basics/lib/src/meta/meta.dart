part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///

class _Dsl {
  final String reason;

  const _Dsl([this.reason = 'dsl方法']);
}

/// 用于标记, 该方法是一个dsl方法, 推荐的调用方式
/// [reason] 用于标记dsl方法的原因
const dsl = _Dsl();

/// 调用点
class _CallPoint {
  final String reason;

  const _CallPoint([this.reason = '调用点']);
}

/// 调用点
const callPoint = _CallPoint();

class _TestPoint {
  final String reason;

  const _TestPoint([this.reason = '测试点']);
}

/// 测试点
const testPoint = _TestPoint();
