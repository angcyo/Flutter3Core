library flutter3_http;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_http/src/discovery/discovery_utils.dart';
import 'package:http/http.dart' as http;

import 'src/dio/log_interceptor.dart';

export 'package:dio/dio.dart';
export 'src/dio/log_interceptor.dart';

// @formatter:off
part 'src/http.dart';
part 'src/network_string_loader.dart';
part 'src/dio/dio_ex.dart';
part 'src/dio/http_result.dart';
part 'src/dio/r_dio.dart';
part 'src/dio/r_http_exception.dart';
part 'src/dio/token_interceptor.dart';
part 'src/discovery/network_address.dart';
part 'src/discovery/network_discovery.dart';
part 'src/discovery/host_scanner.dart';
part 'src/discovery/port_scanner.dart';
part 'src/doh/r_doh.dart';
// @formatter:on
