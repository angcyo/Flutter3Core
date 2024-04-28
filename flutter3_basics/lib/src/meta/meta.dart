part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///
/// 元数据/注解
/// [Target]
class AnnotationMeta {
  final String des;

  const AnnotationMeta([this.des = '注解']);

  @override
  String toString() {
    return 'Annotation{des: $des}';
  }
}

//region---单位

const unit = AnnotationMeta('当前的值根据设置的Unit自动适配');
const pixel = AnnotationMeta('像素单位');
const dp = AnnotationMeta('Dp单位');
const mm = AnnotationMeta('Mm单位');
const pt = AnnotationMeta('磅单位');
const inch = AnnotationMeta('in英寸单位');

//endregion---单位

//region---base

/// 用于标记, 该方法是一个dsl方法, 推荐的调用方式
/// [reason] 用于标记dsl方法的原因
const dsl = AnnotationMeta('dsl方法');
const callPoint = AnnotationMeta('调用点');
const overridePoint = AnnotationMeta('覆盖点');
const testPoint = AnnotationMeta('测试点');
const experimental = AnnotationMeta('测试功能, 不稳定');
const api = AnnotationMeta('api');
const httpMask = AnnotationMeta('包含网络请求');
const globalInstance = AnnotationMeta('描述当前对象是全局单例对象');
const updateMark = AnnotationMeta('当前的方法会调用[setState]方法, 用来刷新界面');
const private = AnnotationMeta('私有化的方法, 不建议外部调用');
const implementation = AnnotationMeta('当前功能, 正在实现中...');
const entryPoint = AnnotationMeta('当前类的关键入口点');
const output = AnnotationMeta('当前的数据用来输出');
const property = AnnotationMeta('可以被操作的属性');
const configProperty = AnnotationMeta('当前属性用来配置');
const flagProperty = AnnotationMeta('标记属性, 不参与底层的逻辑运算');
const initialize = AnnotationMeta('必要的初始化操作');
const streamMark = AnnotationMeta('当前操作会触发流的通知, 包含流的操作');
const updateSignalMark = AnnotationMeta('一个更新信号通知,监听此通知实现界面更新');

//endregion---base
