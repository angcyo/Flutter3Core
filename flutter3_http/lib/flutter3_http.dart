library flutter3_http;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:http/http.dart' as http;

import 'src/dio/log_interceptor.dart';

export 'package:dio/dio.dart';
export 'package:json_annotation/json_annotation.dart';

part 'src/dio/dio_ex.dart';

part 'src/dio/http_result.dart';

part 'src/dio/r_dio.dart';

part 'src/dio/token_interceptor.dart';

part 'src/http.dart';
