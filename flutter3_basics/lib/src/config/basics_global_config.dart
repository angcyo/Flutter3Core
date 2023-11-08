part of flutter3_basics;

///
/// 基类全局配置
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/08
///

typedef GlobalOpenUrlFn = void Function(BuildContext context, String? url);

final class BasicsGlobalConfig {
  BasicsGlobalConfig();

  /// 全局的打开url方法, 一般是跳转到web页面
  /// 打开url
  GlobalOpenUrlFn? openUrlFn = (context, url) {
    l.w("企图打开url:$url from:$context");
  };

  factory BasicsGlobalConfig.init() {
    return BasicsGlobalConfig();
  }
}

BasicsGlobalConfig basicsGlobalConfig = BasicsGlobalConfig.init();

/// 快速打开url
@dsl
openWebUrl(BuildContext context, String? url) =>
    basicsGlobalConfig.openUrlFn?.call(context, url);
