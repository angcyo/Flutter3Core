part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/05/14
///

/// This ID is independent of the time zone.
class TimeIdGen {
  /// See notes for [TimeIdType].
  const TimeIdGen([this.type = TimeIdType.microseconds]);

  /// Each call generate a new ID greater than previous.
  int get([dynamic source]) => next;

  int get next {
    int generate() => type == TimeIdType.milliseconds
        ? DateTime.now().millisecondsSinceEpoch
        : DateTime.now().microsecondsSinceEpoch;

    /// we need this for guarantee a next ID not equals to previous call [next]
    final prev = generate();
    for (;;) {
      final t = generate();
      if (t != prev) {
        return t;
      }
    }
  }

  final TimeIdType type;
}

enum TimeIdType {
  /// ID <= 8640000000000000
  milliseconds,

  /// ID <= 8640000000000000000
  /// ! This value does not fit into 53 bits (the size of a IEEE double).
  /// ! A JavaScript number is not able to hold this value.
  microseconds,
}
