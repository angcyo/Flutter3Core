part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/26
///
/// 调试界面, 包含很多调试相关的功能
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> with AbsScrollPage {
  @override
  String? getTitle(BuildContext context) => "调试界面";

  @override
  WidgetList? buildScrollBody(BuildContext context) {
    return [
      [
        GradientButton.normal(
            onTap: () {
              context.pushWidget(const DebugFilePage()).get((value, error) {
                l.i("返回结果:$value");
              });
            },
            child: "文本管理".text()),
        GradientButton.normal(
            onTap: () async {
              final path = await cacheFilePath("ScreenCapture${nowTime()}.png");
              final image = await saveScreenCapture(path);
              if (image == null) {
                toastInfo('截屏失败');
              } else {
                toastInfo('截屏成功:$path');
              }
            },
            child: "截屏".text()),
      ].wrap()!.paddingAll(kX),
    ];
  }

  @override
  Widget build(BuildContext context) => buildScaffold(context);
}
