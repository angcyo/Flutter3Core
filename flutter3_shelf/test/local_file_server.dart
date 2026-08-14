import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/14
///
/// 本地文件服务
void main() async {
  // 3. 构建请求处理管道 (Pipeline)
  // logRequests() 是一个内置中间件，用于在控制台打印请求的访问日志 (IP、时间、状态码)
  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsHeaders()) // 注入跨域中间件
      .addMiddleware(_bandwidthLimiter()) // 注入限速中间件
      .addHandler(_fileHandler);

  // 4. 启动 HTTP 服务器
  // InternetAddress.anyIPv4 允许局域网内的其他设备通过你的局域网 IP 访问
  final port = 8080;
  final server = await io.serve(pipeline, InternetAddress.anyIPv4, port);

  print('=========================================');
  print('本地文件服务已启动 🚀');
  //print('本地访问: http://localhost:${server.port}');
  print('本地访问: http://${server.address.host}:${server.port}');
  //print('目录映射: 物理路径 "./$publicFolderPath" -> 路由 "/"');
  print('请求路径: /?path=xxx&speed=1048576');
  print('按 Ctrl+C 停止服务');
  print('=========================================');

  //print('start local file server');
  await Future.delayed(Duration(days: 1));
}

Future<Response> _fileHandler(Request request) async {
  final path = request.requestedUri.queryParameters["path"];
  if (path == null) {
    return Response.notFound('请指定文件路径');
  }
  File file = File(path);
  if (!file.existsSync()) {
    return Response.notFound('Not Found');
  }
  return _handleFile(request, file, () async {
    return MimeTypeResolver().lookup(file.path);
  });
}

/// 自定义 CORS 中间件
Middleware _corsHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      // 拦截预检请求 (OPTIONS)
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type',
          },
        );
      }

      // 处理正常请求并追加 Header
      final response = await innerHandler(request);
      return response.change(headers: {'Access-Control-Allow-Origin': '*'});
    };
  };
}

//MARK: - shelf_static

/// Serves the contents of [file] in response to [request].
///
/// This handles caching, and sends a 304 Not Modified response if the request
/// indicates that it has the latest version of a file. Otherwise, it calls
/// [getContentType] and uses it to populate the Content-Type header.
Future<Response> _handleFile(
  Request request,
  File file,
  FutureOr<String?> Function() getContentType,
) async {
  final stat = file.statSync();
  final ifModifiedSince = request.ifModifiedSince;

  if (ifModifiedSince != null) {
    final fileChangeAtSecResolution = toSecondResolution(stat.modified);
    if (!fileChangeAtSecResolution.isAfter(ifModifiedSince)) {
      return Response.notModified();
    }
  }

  final contentType = await getContentType();
  final headers = {
    HttpHeaders.lastModifiedHeader: formatHttpDate(stat.modified),
    HttpHeaders.acceptRangesHeader: 'bytes',
    HttpHeaders.contentTypeHeader: ?contentType,
  };

  return _fileRangeResponse(request, file, headers) ??
      Response.ok(
        request.method == 'HEAD' ? null : file.openRead(),
        headers: headers..[HttpHeaders.contentLengthHeader] = '${stat.size}',
      );
}

final _bytesMatcher = RegExp(r'^bytes=(\d*)-(\d*)$');

/// Serves a range of [file], if [request] is valid 'bytes' range request.
///
/// If the request does not specify a range, specifies a range of the wrong
/// type, or has a syntactic error the range is ignored and `null` is returned.
///
/// If the range request is valid but the file is not long enough to include the
/// start of the range a range not satisfiable response is returned.
///
/// Ranges that end past the end of the file are truncated.
Response? _fileRangeResponse(
  Request request,
  File file,
  Map<String, Object> headers,
) {
  final range = request.headers[HttpHeaders.rangeHeader];
  if (range == null) return null;
  final matches = _bytesMatcher.firstMatch(range);
  // Ignore ranges other than bytes
  if (matches == null) return null;

  final actualLength = file.lengthSync();
  final startMatch = matches[1]!;
  final endMatch = matches[2]!;
  if (startMatch.isEmpty && endMatch.isEmpty) return null;

  int start; // First byte position - inclusive.
  int end; // Last byte position - inclusive.
  if (startMatch.isEmpty) {
    start = actualLength - int.parse(endMatch);
    if (start < 0) start = 0;
    end = actualLength - 1;
  } else {
    start = int.parse(startMatch);
    end = endMatch.isEmpty ? actualLength - 1 : int.parse(endMatch);
  }

  // If the range is syntactically invalid the Range header
  // MUST be ignored (RFC 2616 section 14.35.1).
  if (start > end) return null;

  if (end >= actualLength) {
    end = actualLength - 1;
  }
  if (start >= actualLength) {
    return Response(HttpStatus.requestedRangeNotSatisfiable, headers: headers);
  }
  return Response(
    HttpStatus.partialContent,
    body: request.method == 'HEAD' ? null : file.openRead(start, end + 1),
    headers: headers
      ..[HttpHeaders.contentLengthHeader] = (end - start + 1).toString()
      ..[HttpHeaders.contentRangeHeader] = 'bytes $start-$end/$actualLength',
  );
}

DateTime toSecondResolution(DateTime dt) {
  if (dt.millisecond == 0) return dt;
  return dt.subtract(Duration(milliseconds: dt.millisecond));
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Return a HTTP-formatted string representation of [date].
///
/// This follows [RFC 822](http://tools.ietf.org/html/rfc822) as updated by
/// [RFC 1123](http://tools.ietf.org/html/rfc1123).
String formatHttpDate(DateTime date) {
  date = date.toUtc();
  final buffer = StringBuffer()
    ..write(_weekdays[date.weekday - 1])
    ..write(', ')
    ..write(date.day <= 9 ? '0' : '')
    ..write(date.day.toString())
    ..write(' ')
    ..write(_months[date.month - 1])
    ..write(' ')
    ..write(date.year.toString())
    ..write(date.hour <= 9 ? ' 0' : ' ')
    ..write(date.hour.toString())
    ..write(date.minute <= 9 ? ':0' : ':')
    ..write(date.minute.toString())
    ..write(date.second <= 9 ? ':0' : ':')
    ..write(date.second.toString())
    ..write(' GMT');
  return buffer.toString();
}

//MARK: throttle

/// 限制带宽的中间件
/// - 限制/s
Middleware _bandwidthLimiter() {
  return (Handler innerHandler) {
    return (Request request) async {
      final speed =
          request.requestedUri.queryParameters["speed"] ??
          request.headers["speed"] ??
          request.headers["throttle"];
      final bytesPerSecond = int.parse(speed ?? "0");
      if (bytesPerSecond > 0) {
        // 获取正常处理后的响应（此时文件流准备就绪，但并未开始真正读取和传输）
        final response = await innerHandler(request);

        // 拦截 Response 的数据流 (read() 方法返回 Stream<List<int>>)
        final throttledBody = _throttleStream(response.read(), bytesPerSecond);

        // 用限速后的新流替换掉原来的 body
        return response.change(body: throttledBody);
      }
      return innerHandler(request);
    };
  };
}

/// 将原始流转换为限速流
/// [source] 原始的数据流
/// [maxBytesPerSec] 每秒最大允许传输的字节数
Stream<List<int>> _throttleStream(
  Stream<List<int>> source,
  int maxBytesPerSec,
) async* {
  final stopwatch = Stopwatch()..start();
  int totalBytes = 0;

  // 为了让限速更加平滑，我们需要对底层可能传来的大块数据(如 64KB)进行切片
  // 这里我们设定每次 yield 的最大数据块大小约为每秒限额的 1/10，且保证最小切片为 1KB
  final maxChunkSize = max(1024, maxBytesPerSec ~/ 10);

  await for (var chunk in source) {
    int offset = 0;
    while (offset < chunk.length) {
      // 提取子块
      final takeCount = min(maxChunkSize, chunk.length - offset);
      final subChunk = chunk.sublist(offset, offset + takeCount);
      offset += takeCount;

      totalBytes += subChunk.length;

      // 计算当前传输量理论上应该耗时多少毫秒
      final expectedMs = (totalBytes * 1000) ~/ maxBytesPerSec;
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // 如果传得太快，则挂起等待
      if (elapsedMs < expectedMs) {
        await Future.delayed(Duration(milliseconds: expectedMs - elapsedMs));
      }

      yield subChunk;
    }
  }
}
