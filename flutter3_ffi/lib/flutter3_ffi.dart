library flutter3_ffi;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

part 'src/ffi_ex.dart';
part 'src/ffi_struct.dart';

/// 用于内存分配
const ffiCalloc = calloc;
