part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///
/// 元数据/注解

//region---单位

class _Pixel {
  final String des;

  const _Pixel([this.des = '像素单位']);
}

const pixel = _Pixel();

class _Dp {
  final String des;

  const _Dp([this.des = 'Dp单位']);
}

const dp = _Dp();

class _Mm {
  final String des;

  const _Mm([this.des = 'Mm单位']);
}

const mm = _Mm();

class _Unit {
  final String des;

  const _Unit([this.des = '当前的值根据设置的Unit自动适配']);
}

const unit = _Unit();

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
  final String des;

  const _CallPoint([this.des = '调用点']);
}

const callPoint = _CallPoint();

/// 覆盖点
class _OverridePoint {
  final String des;

  const _OverridePoint([this.des = '覆盖点']);
}

const overridePoint = _OverridePoint();

/// 测试功能
class _Experimental {
  final String des;

  const _Experimental([this.des = '测试功能']);
}

const experimental = _Experimental();

/// 测试点
class _TestPoint {
  final String des;

  const _TestPoint([this.des = '测试点']);
}

const testPoint = _TestPoint();

/// 可以被调用的api接口
class _Api {
  final String des;

  const _Api([this.des = 'api']);
}

const api = _Api();

/// 包含网络请求的方法
class _Http {
  final String des;

  const _Http([this.des = '包含网络请求']);
}

const http = _Http();

/// 描述当前对象是全局单例对象
class _GlobalInstance {
  final String des;

  const _GlobalInstance([this.des = '单例对象']);
}

const globalInstance = _GlobalInstance();

/// 可以被操作的属性
class _Property {
  final String des;

  const _Property([this.des = '可以被操作的属性']);
}

const property = _Property();

class _UpdateMark {
  final String des;

  const _UpdateMark([this.des = '当前的方法会调用[setState]方法, 用来刷新界面']);
}

const updateMark = _UpdateMark();

class _Private {
  final String des;

  const _Private([this.des = '私有化的方法, 不建议调用']);
}

const private = _Private();

class _Implemented {
  final String des;

  const _Implemented([this.des = '当前功能, 正在实现中...']);
}

const implemented = _Implemented();

//endregion---base
