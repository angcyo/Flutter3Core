part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/08/11
///
/// 字符串一行一行读取的迭代器, 只在读取时, 才进行分行处理, 而不是一开始就直接分行
///
/// - [LineScanner]
/// - [StringScanner]
///
class StringLineIterator implements Iterator<String> {
  final String _source;

  //--

  int _position = 0;

  String? _current;

  StringLineIterator(this._source);

  @override
  String get current => _current!;

  @override
  bool moveNext() {
    if (_position >= _source.length) {
      _current = null;
      return false;
    } else {
      final buffer = StringBuffer();
      while (_position < _source.length &&
          !_newlineRegExp.hasMatch(_source[_position])) {
        buffer.write(_source[_position]);
        _position++;
      }
      _position++;
      _current = buffer.toString();
      return true;
    }
  }
}

final _newlineRegExp = RegExp(r'\n|\r\n|\r(?!\n)');

extension StringLineIteratorEx on String {
  /// 字符串一行一行读取的迭代器
  StringLineIterator get linesIterator => StringLineIterator(this);

  /// 遍历每一行
  /// - [callback] 返回true, 中断枚举
  void eachLine(dynamic Function(String line) callback) {
    final lines = linesIterator;
    while (lines.moveNext()) {
      final line = lines.current;
      final result = callback(line);
      if (result is bool && result) {
        break;
      }
    }
  }
}
