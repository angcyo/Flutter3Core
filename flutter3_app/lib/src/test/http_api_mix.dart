part of '../../flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/09
///
/// 网络请求测试日志混入
mixin HttpApiLogStateMixin<T extends StatefulWidget>
    on LogMessageStateMixin<T>, HookMixin, HookStateMixin<T> {
  //MARK: - api

  final TextFieldConfig hostConfig = TextFieldConfig(
    text: "_api_host".hiveGet(),
    onChanged: (text) {
      "_api_host".hivePut(text);
    },
  );
  final TextFieldConfig pathConfig = TextFieldConfig(
    text: "_api_path".hiveGet(),
    onChanged: (text) {
      "_api_path".hivePut(text);
    },
  );
  final TextFieldConfig headerConfig = TextFieldConfig(
    text: "_api_header".hiveGet(),
    onConfigChanged: (config, text) {
      "_api_header".hivePut(config.formatIfJson());
    },
  );
  final TextFieldConfig bodyConfig = TextFieldConfig(
    text: "_api_body".hiveGet(),
    onConfigChanged: (config, text) {
      "_api_body".hivePut(config.formatIfJson());
    },
  );

  HttpMethod get method => HttpMethod.fromName("_api_method".hiveGet());

  set method(HttpMethod value) {
    "_api_method".hivePut(value.name);
  }

  /// 请求地址
  String get url => hostConfig.text.connectUrl(pathConfig.text);

  //MARK: - build

  @override
  void initState() {
    hookAny(
      LogFileInterceptor.requestLogOnceLive.listen((log) {
        if (log != null) {
          addLastMessage(log, isReceived: false);
        }
      }),
    );
    hookAny(
      LogFileInterceptor.responseLogOnceLive.listen((log) {
        if (log != null) {
          addLastMessage(log, isReceived: true);
        }
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return [
      buildLogMessageListWidget(context, globalTheme).expanded(),
      buildApiTest(
        context,
        globalTheme,
      ).card().animatedContainer(width: $ecwBp()),
    ].row()!;
  }

  /// 构建api测试主体
  @overridePoint
  Widget buildApiTest(BuildContext context, GlobalTheme globalTheme) {
    return empty;
  }

  //MARK: - input

  /// 构建测试输入头部小部件
  @api
  WidgetList buildApiTestHeader(BuildContext context, GlobalTheme globalTheme) {
    return [
      //MARK: - host
      SingleInputWidget(
        config: hostConfig,
        labelText: "服务器地址",
        hintText: "服务器地址",
      ).paddingItem(),
      //MARK: - path
      [
        DropdownButtonTile(
          dropdownValue: method,
          dropdownValueList: HttpMethod.values,
          onChanged: (value) {
            method = value;
            updateState();
          },
        ).size(width: 100),
        SingleInputWidget(
          config: pathConfig,
          labelText: "请求路径",
          hintText: "请求路径",
        ).expanded(),
      ].row()!.paddingItem(),
      //MARK: - header
      SingleInputWidget(
        config: headerConfig,
        labelText: "请求头",
        hintText: "请求头jsonArray",
        maxLines: 5,
      ).paddingItem(),
      //MARK: - body
      SingleInputWidget(
        config: bodyConfig,
        labelText: "请求体",
        hintText: "请求体json",
        maxLines: 10,
      ).paddingItem(),
      //MARK: - button
      [
        GradientButton.normal(clearLogData, child: "清屏".text()),
        GradientButton.normal(() {
          try {
            url.fetch((options) {
              options
                ..method = method.label
                ..headers = headerConfig.text.toJson()
                ..data = bodyConfig.text.toJson();
            });
          } catch (e) {
            assert(() {
              l.w(e);
              return true;
            }());
            addLastMessage("$e", isReceived: false);
          }
        }, child: "Send".text()),
      ].flowLayout(childGap: kL)!.insets(all: kL),
    ];
  }
}

enum HttpMethod {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH"),
  head("HEAD"),
  options("OPTIONS");

  const HttpMethod(this.label);

  final String label;

  @override
  String toString() => label;

  /// fromName
  static HttpMethod fromName(String? name) {
    for (final item in values) {
      if (item.name == name) {
        return item;
      }
    }
    return .get;
  }
}
