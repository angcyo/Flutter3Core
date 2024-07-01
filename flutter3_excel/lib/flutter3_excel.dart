library flutter3_excel;

import 'dart:io';

import 'package:excel_dart/excel_dart.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/28
///
/// Excel 是一个 flutter 和 dart 库，用于读取、创建和更新 XLSX 文件的 Excel 工作表
/// https://pub.dev/packages/excel
///
/// 读取 XLSX 文件
/// `Excel format unsupported. Only .xlsx files are supported`
class ExcelHelper {
  ExcelHelper._();

  /// 读取Excel文档数据
  /// 返回结构: Sheet 对应的 行 列集合 数据
  /// ```
  /// sheet1: xxx
  ///         xxx
  ///         xxx
  /// sheet2: xxx
  ///         xxx
  ///         xxx
  /// sheet3: xxx
  ///         xxx
  ///         xxx
  /// ```
  static Map<String, List<List<dynamic>>> readExcel({
    List<int>? data,
    String? filePath,
  }) {
    final Map<String, List<List>> result = {};
    if (isNil(filePath)) {
      return result;
    }
    final excel =
        Excel.decodeBytes(data ?? (File(filePath!)).readAsBytesSync());
    excel.tables.forEach((key, sheet) {
      final sheetName = key;
      final List<List> sheetData = [];
      //debugger();
      for (final row in sheet.rows) {
        //每一行的数据集, 存储是各个列
        final List<dynamic> rowData = [];
        for (final data in row) {
          rowData.add(data?.value);
        }
        sheetData.add(rowData);
      }
      result[sheetName] = sheetData;
    });
    return result;
  }

  /// 保存数据到Excel
  /// [filePath] 文件路径
  static Future<File> writeExcel(
      String filePath, Map<String, List<List<dynamic>>> data) {
    // automatically creates 1 empty sheet: Sheet1;
    final excel = Excel.createExcel();
    data.forEach((key, list) {
      final sheet = excel[key];
      int rowIndex = 0;
      for (final row in list) {
        int colIndex = 0;
        for (final col in row) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(
              rowIndex: rowIndex, columnIndex: colIndex));
          cell.value = col;
          colIndex++;
        }
        rowIndex++;
      }
    });
    final bytes = excel.save(fileName: filePath);
    return File(filePath).writeAsBytes(bytes ?? []);
  }
}
