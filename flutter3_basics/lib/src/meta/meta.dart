part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///

//region---单位

class _Pixel {
  final String reason;

  const _Pixel([this.reason = '像素单位']);
}

const pixel = _Pixel();

class _Dp {
  final String reason;

  const _Dp([this.reason = 'Dp单位']);
}

const dp = _Dp();

class _Mm {
  final String reason;

  const _Mm([this.reason = 'Mm单位']);
}

const mm = _Mm();

//endregion---单位

//region---base

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

const callPoint = _CallPoint();

/// 测试点
class _TestPoint {
  final String reason;

  const _TestPoint([this.reason = '测试点']);
}

const testPoint = _TestPoint();

/// 可以被调用的api接口
class _Api {
  final String des;

  const _Api([this.des = 'api']);
}

const api = _Api();

//endregion---base
