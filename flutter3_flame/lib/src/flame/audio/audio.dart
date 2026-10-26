import 'package:flame_audio/flame_audio.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/26
///
/// 音效播放
/// https://pub.dev/packages/flame_audio
class Audio {
  Audio();

  /// 初始化音效缓存
  Future initAudioCache({
    String? fileName,
    List<String>? fileNames,
    String? prefix = "",
  }) async {
    if (prefix != null) {
      FlameAudio.updatePrefix(prefix);
    }

    // cache single track
    if (fileName != null) {
      await FlameAudio.audioCache.load(fileName);
    }

    // cache multiple tracks
    if (fileNames != null) {
      await FlameAudio.audioCache.loadAll(fileNames);
    }
  }

  /// 清理缓存
  Future clearAudioCache({String? fileName}) async {
    if (fileName != null) {
      await FlameAudio.audioCache.clear(fileName);
    } else {
      await FlameAudio.audioCache.clearAll();
    }
  }

  /// 播放音效
  Future playAudio(
    String? fileName, {
    double volume = 1.0,
    String? package,
    //--
    bool? loop,
    bool? long,
  }) async {
    if (fileName != null) {
      try {
        if (loop == true) {
          //循环播放
          if (long == true) {
            await FlameAudio.loopLongAudio(
              fileName,
              volume: volume,
              package: package,
            );
          } else {
            await FlameAudio.loop(fileName, volume: volume, package: package);
          }
        } else {
          //单次播放
          if (long == true) {
            await FlameAudio.playLongAudio(
              fileName,
              volume: volume,
              package: package,
            );
          } else {
            await FlameAudio.play(fileName, volume: volume, package: package);
          }
        }
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
      }
    }
  }
}

@globalInstance
final $audio = Audio();
