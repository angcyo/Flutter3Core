part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///
/// 元数据/注解
/// [Target]
/*@Target({
  TargetKind.field,
  TargetKind.function,
  TargetKind.getter,
  TargetKind.method,
  TargetKind.setter,
  TargetKind.classType,
  TargetKind.extension,
  TargetKind.topLevelVariable,
  TargetKind.parameter,
  TargetKind.enumType,
  TargetKind.extensionType,
  TargetKind.library,
  TargetKind.typedefType,
})*/
class AnnotationMeta {
  final String des;

  const AnnotationMeta([this.des = '注解']);

  @override
  String toString() {
    return 'Annotation{des: $des}';
  }
}

/// 当前方法由谁负责调用
class CallFrom {
  const CallFrom([dynamic from = '当前方法由谁负责调用']);

  @override
  String toString() {
    return 'CallFrom';
  }
}

const callFrom = CallFrom();

/// 当前方法由谁负责初始化调用
class CallInitFrom {
  const CallInitFrom([dynamic from = '当前方法由谁负责初始化调用']);

  @override
  String toString() {
    return 'CallInitFrom';
  }
}

const callInitFrom = CallInitFrom();

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
@experimental
const implementation = AnnotationMeta('当前功能, 正在实现中...');
const entryPoint = AnnotationMeta('当前类的关键入口点');
const output = AnnotationMeta('当前的数据用来输出');
const property = AnnotationMeta('可以被操作的属性');
const configProperty = AnnotationMeta('当前属性用来配置');
const flagProperty = AnnotationMeta('标记属性, 不参与底层的逻辑运算');
const indirectProperty = AnnotationMeta('标记间接属性, 间接属性不参与直接计算,而是创建确实的直接属性');
const initialize = AnnotationMeta('必要的初始化操作');
const streamMark = AnnotationMeta('当前操作会触发流的通知, 包含流的操作');
const updateSignalMark = AnnotationMeta('一个更新信号通知,监听此通知实现界面更新');
const autoInjectMark = AnnotationMeta('标识当前方法/属性会在框架内自动注入');
const minifyProguardFlag = AnnotationMeta('标识当前的代码需要注意混淆后是否正常运行');
const notify = AnnotationMeta('标识这只是一个通知,需要具体手动实现逻辑');
const defInjectMark = AnnotationMeta('标识当前属性不指定时,也有注入默认值');
const autoDispose = AnnotationMeta('标识当前操作会自动释放');
const clipFlag = AnnotationMeta('Canvas Clip 操作, 消耗资源');
const fromFramework = AnnotationMeta('表示当前代码来自框架');
//endregion---base
