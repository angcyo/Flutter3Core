///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/15
///

// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';

void main([List<String>? args]) async {
  print(Directory.current);
  final parser = _getParser();

  int port;
  bool logging;
  bool listDirectories;

  try {
    final result = parser.parse(args ?? []);
    port = int.parse(result['port'] as String);
    logging = result['logging'] as bool;
    listDirectories = result['list-directories'] as bool;
  } on FormatException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln(parser.usage);
    // http://linux.die.net/include/sysexits.h
    // #define EX_USAGE	64	/* command line usage error */
    exit(64);
  }

  var pipeline = const shelf.Pipeline();

  if (logging) {
    pipeline = pipeline.addMiddleware(shelf.logRequests());
  }

  String? defaultDoc = _defaultDoc;
  if (listDirectories) {
    defaultDoc = null;
  }

  final handler = pipeline.addHandler(createStaticHandler('test/files',
      defaultDocument: defaultDoc, listDirectories: listDirectories));

  io.serve(handler, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

  //等待进程结束
  await Future.delayed(const Duration(days: 1));
}

ArgParser _getParser() => ArgParser()
  ..addFlag('logging', abbr: 'l', defaultsTo: true)
  ..addOption('port', abbr: 'p', defaultsTo: '8081')
  ..addFlag('list-directories',
      abbr: 'f',
      negatable: false,
      help: 'List the files in the source directory instead of serving the '
          'default document - "$_defaultDoc".');

const _defaultDoc = 'index.html';
