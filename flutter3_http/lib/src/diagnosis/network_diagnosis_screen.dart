part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// 网络诊断页面
class NetworkDiagnosisScreen extends StatefulWidget {
  /// 诊断模型
  @defInjectMark
  final NetworkDiagnosisModel? model;

  const NetworkDiagnosisScreen({super.key, this.model});

  @override
  State<NetworkDiagnosisScreen> createState() => _NetworkDiagnosisScreenState();
}

class _NetworkDiagnosisScreenState extends State<NetworkDiagnosisScreen> {
  @property
  late NetworkDiagnosisModel model;

  @property
  bool isStarted = false;

  @override
  void initState() {
    model =
        widget.model ??
        NetworkDiagnosisModel(
          actions: [
            LocalDnsDiagnosisAction(),
            UniversalDnsDiagnosisAction(),
            WifiLoginDiagnosisAction(),
            DownloadSpeedTestDiagnosisAction(),
            UploadSpeedTestDiagnosisAction(),
          ],
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return [
          for (final action in model.actions)
            NetworkDiagnosisActionTile(action, isStarted: isStarted),
        ].scrollVertical()?.expanded().columnOf(
          FilledButton(
            onPressed: isStarted
                ? null
                : () {
                    if (isStarted) {
                      return;
                    }
                    isStarted = true;
                    updateState();
                    int count = 0;
                    for (final action in model.actions) {
                      action.reset();
                      action.call().then((value) {
                        count++;
                        if (count >= model.actions.length) {
                          isStarted = false;
                        }
                        updateState();
                      });
                    }
                  },
            child: isStarted ? "正在诊断...".text() : "开始诊断".text(),
          ).insets(all: kX),
        ) ??
        empty;
  }
}

/// 诊断步骤tile
class NetworkDiagnosisActionTile extends StatelessWidget {
  /// 步骤
  final NetworkDiagnosisAction action;

  /// 是否开始了诊断
  final bool isStarted;

  const NetworkDiagnosisActionTile(
    this.action, {
    super.key,
    this.isStarted = false,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final isStarted = this.isStarted;
    final isDone = action.isDone;
    final isError = action.isError;
    return [
          action.label.text().expanded(),
          if (isStarted && !isDone)
            const CircularProgressIndicator().size(size: 14),
          if (isDone)
            action.duration!.toString().text(
              textStyle: globalTheme.textPlaceStyle,
            ),
          if (isDone && isError)
            Icon(Icons.close, color: globalTheme.errorColor),
          if (isDone && !isError)
            Icon(Icons.check, color: globalTheme.successColor),
        ]
        .row()!
        .columnOf(
          isDone
              ? (action.error ?? action.result)?.text(
                  textAlign: .start,
                  textStyle: globalTheme.textDesStyle,
                )
              : null,
          crossAxisAlignment: .start,
        )
        .insets(all: kX);
  }
}
