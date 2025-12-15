///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/15
///
///
/// https://dart.dev/language/branches
void main() {
  final command = 'OPEN';
  switch (command) {
    case 'CLOSED':
      executeClosed();
    case 'PENDING':
      executePending();
    case 'APPROVED':
      executeApproved();
    case 'DENIED':
      executeDenied();
    case 'OPEN':
      executeOpen();
    default:
      executeUnknown();
  }

  switch (command) {
    case 'OPEN':
      executeOpen();
      continue newCase; // Continues executing at the newCase label.

    case 'DENIED': // Empty case falls through.
    case 'CLOSED':
      executeClosed(); // Runs for both DENIED and CLOSED,

    newCase:
    case 'PENDING':
      executeNowClosed(); // Runs for both OPEN and PENDING.
  }

  /*var x = switch (y) { ... };
  print(switch (x) { ... });
  return switch (x) { ... };*/

  // Where slash, star, comma, semicolon, etc., are constant variables...
  /*switch (charCode) {
    case slash || star || plus || minus: // Logical-or pattern
      token = operator(charCode);
    case comma || semicolon: // Logical-or pattern
      token = punctuation(charCode);
    case >= digit0 && <= digit9: // Relational and logical-and patterns
      token = number();
    default:
      throw FormatException('Invalid');
  }*/

  /*token = switch (charCode) {
    slash || star || plus || minus => operator(charCode),
    comma || semicolon => punctuation(charCode),
    >= digit0 && <= digit9 => number(),
    _ => throw FormatException('Invalid'),
  };*/

  final s1 = 1;
  final s2 = 2;

  print(switch (s1) {
    String => "s1 is String",
    double => "s1 is double",
    int => "s1 is int",
    _ => "s1 is not int",
  });

  print(switch (null) {
    _ when s1 > s2 => "s1 > s2",
    _ when s1 < s2 => "s1 < s2",
    _ => "s1 == s2",
  });
}

/// 补齐错误的方法
void executeUnknown() {
  print('Unknown command.');
}

void executeOpen() {
  print('Opening.');
}

void executeClosed() {
  print('Closed.');
}

void executePending() {
  print('Pending.');
}

void executeApproved() {
  print('Approved.');
}

void executeDenied() {
  print('Denied.');
}

void executeNowClosed() {
  print('Now closed.');
}
