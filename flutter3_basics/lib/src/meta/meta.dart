part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///
/// 元数据/注解

//region---单位

class Pixel {
  final String des;

  const Pixel([this.des = '像素单位']);
}

const pixel = Pixel();

class Dp {
  final String des;

  const Dp([this.des = 'Dp单位']);
}

const dp = Dp();

class Mm {
  final String des;

  const Mm([this.des = 'Mm单位']);
}

const mm = Mm();

class Pt {
  final String des;

  const Pt([this.des = '磅单位']);
}

const pt = Pt();

class Inch {
  final String des;

  const Inch([this.des = '英寸单位']);
}

const inch = Inch();

class _Unit {
  final String des;

  const _Unit([this.des = '当前的值根据设置的Unit自动适配']);
}

const unit = _Unit();

//endregion---单位

//region---base

class Dsl {
  final String reason;

  const Dsl([this.reason = 'dsl方法']);
}

/// 用于标记, 该方法是一个dsl方法, 推荐的调用方式
/// [reason] 用于标记dsl方法的原因
const dsl = Dsl();

/// 调用点
class CallPoint {
  final String des;

  const CallPoint([this.des = '调用点']);
}

const callPoint = CallPoint();

/// 覆盖点
class OverridePoint {
  final String des;

  const OverridePoint([this.des = '覆盖点']);
}

const overridePoint = OverridePoint();

/// 测试功能
class Experimental {
  final String des;

  const Experimental([this.des = '测试功能']);
}

const experimental = Experimental();

/// 测试点
class TestPoint {
  final String des;

  const TestPoint([this.des = '测试点']);
}

const testPoint = TestPoint();

/// 可以被调用的api接口
class Api {
  final String des;

  const Api([this.des = 'api']);
}

const api = Api();

/// 包含网络请求的方法
class HttpMask {
  final String des;

  const HttpMask([this.des = '包含网络请求']);
}

const httpMask = HttpMask();

/// 描述当前对象是全局单例对象
class GlobalInstance {
  final String des;

  const GlobalInstance([this.des = '单例对象']);
}

const globalInstance = GlobalInstance();

class UpdateMark {
  final String des;

  const UpdateMark([this.des = '当前的方法会调用[setState]方法, 用来刷新界面']);
}

const updateMark = UpdateMark();

class Private {
  final String des;

  const Private([this.des = '私有化的方法, 不建议调用']);
}

const private = Private();

class Implementation {
  final String des;

  const Implementation([this.des = '当前功能, 正在实现中...']);
}

const implementation = Implementation();

class EntryPoint {
  final String des;

  const EntryPoint([this.des = '当前类的入口点']);
}

const entryPoint = EntryPoint();

class Output {
  final String des;

  const Output([this.des = '当前的数据用来输出']);
}

const output = Output();

/// 可以被操作的属性
class Property {
  final String des;

  const Property([this.des = '可以被操作的属性']);
}

const property = Property();

class ConfigProperty {
  final String des;

  const ConfigProperty([this.des = '当前属性用来配置']);
}

const configProperty = ConfigProperty();

class FlagProperty {
  final String des;

  const FlagProperty([this.des = '标记属性, 不参与底层的逻辑运算']);
}

const flagProperty = FlagProperty();

//endregion---base
