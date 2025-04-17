part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/23
///
/// 如果是[String]数据, 参数就是发送的字符长度
/// [startTime] 数据发送开始的时间, 用于
/// [progress] [0~1]
@immutable
final class DataChunkInfo {
  /// 数据发送开始的时间, 毫秒
  final int startTime;

  /// 总共需要发送的字节数
  /// 如果是[String]数据, 参数就是发送的字符长度
  final int total;

  /// 已经发送的字节数
  final int count;

  DataChunkInfo({
    this.startTime = -1,
    this.total = 0,
    this.count = 0,
  });

  /// 当前传输的进度[0~1]
  double get progress => (count / total).clamp(0, 1);

  /// 当前传输的进度[0~100]
  int get progressInt => (progress * 100).toInt();

  /// 计算速率 bytes/s
  int get speed {
    final time = nowTime();
    final dTime = time - startTime;
    return dTime >= 1000 ? (count * 1000 / (time - startTime)).round() : count;
  }

  /// 是否传输完成
  bool get isFinish => startTime > 0 && count >= total;

  String get speedStr => '${speed.toSizeStr()}/s';

  /// 使用指定的时间, 计算出速度
  String getSpeedStr([int? time]) {
    time ??= nowTime();
    final dTime = time - startTime;
    int speed =
        dTime >= 1000 ? (count * 1000 / (time - startTime)).round() : count;
    return '${speed.toSizeStr()}/s';
  }

  int? _endTime;

  String time([int? endTime]) {
    if (isFinish) {
      _endTime = nowTime();
    }
    return LTime.diffTime(startTime, endTime: _endTime ?? endTime ?? nowTime());
  }

  @override
  String toString() {
    return 'DataChunkInfo{[$count/$total]B, speed: $speedStr progress: $progress time: ${time()}}';
  }
}
