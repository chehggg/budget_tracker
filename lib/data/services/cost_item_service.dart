import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CostItemServices {
  Future<Result<List<CostItem>>> parseCostItemCsv(File file) async {
    try {
      final csvString = file.readAsStringSync();
      final List<List<dynamic>> decodedData = csv.decode(csvString);
      decodedData.removeAt(0);
      final items =
          decodedData.map((List<dynamic> item) => CostItem.fromCsv(item, newId: true)).toList();
      debugPrint("service parse data done");
      return Result.ok(items);
    } on Exception catch (e) {
      debugPrint('error reading csv data: $e');
      return Result.error(e);
    }
  }

  // Future<Result<List<CostItem>>> loadFileCostItems() async {
  //   debugPrint("service load data done");

  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/budget.csv');
  //   return await parseCostItemCsv(file);
  // }

  // Future<Result<List<CostItem>>> parseCostItemCsvLegacy(File file) async {
  //   try {
  //     final csvString = file.readAsStringSync();
  //     final List<List<dynamic>> decodedData = csv.decode(csvString);
  //     decodedData.removeAt(0);
  //     final items =
  //         decodedData
  //             .map((List<dynamic> item) => CostItem.fromCsvLegacy(item, newId: true))
  //             .toList();
  //     debugPrint("service parse data done");
  //     return Result.ok(items);
  //   } on Exception catch (e) {
  //     debugPrint('error reading csv data: $e');
  //     return Result.error(e);
  //   }
  // }

  // Future<Result<List<CostItem>>?> loadCostItemsFromFileLegacy() async {
  //   final FilePickerResult? result = await FilePicker.pickFiles(
  //     allowMultiple: false,
  //     allowedExtensions: ['csv'],
  //     type: FileType.custom,
  //   );
  //   if (result == null) return null;

  //   final file = File(result.files.single.path!);
  //   return await parseCostItemCsvLegacy(file);
  // }

  // Future<Result<List<CostItem>>?> loadCostItemsFromFile() async {
  //   final FilePickerResult? result = await FilePicker.pickFiles(
  //     allowMultiple: false,
  //     allowedExtensions: ['csv'],
  //     type: FileType.custom,
  //   );
  //   if (result == null) return null;

  //   final file = File(result.files.single.path!);
  //   return await parseCostItemCsv(file);
  // }

  // Future<Result<void>> writeCostItemsToFile(List<CostItem> items) async {
  //   final List<List<dynamic>> result = List.generate(
  //     items.length,
  //     (i) => items[i].toCsv(),
  //   );

  //   const List<String> headers = [
  //     'uuid',
  //     'date',
  //     'costType',
  //     'category',
  //     'amount',
  //     'name',
  //     'last created',
  //     'last modified',
  //   ];

  //   final List<List<dynamic>> data = [headers, ...result];

  //   try {
  //     final csvString = csv.encode(data);
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/budget.csv');

  //     file.writeAsStringSync(csvString);
  //     return Result.ok(null);
  //   } on Exception catch (e) {
  //     debugPrint("error writing data to file, $e");
  //     return Result.error(e);
  //   }
  // }

  Future<Result<String>?> exportCostItemJson(List<CostItem> items) async {
    final List<Map<String, dynamic>> result = List.generate(
      items.length,
      (i) => items[i].toJson(),
    );

    debugPrint(result.toString());

    try {
      final jsonString = jsonEncode(result);
      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'nomi-costItems-${Uuid().v4().split('-').first}.json',
        allowedExtensions: ['json'],
        bytes: utf8.encode(jsonString),
      );

      if (outputFile == null) return null;
      return Result.ok(outputFile);
    } on Exception catch (e) {
      debugPrint("error writing data to file, $e");
      return Result.error(e);
    }
  }

  Future<Result<void>> writeCostItemJsonToFile(List<CostItem> items) async {
    final List<Map<String, dynamic>> result = List.generate(
      items.length,
      (i) => items[i].toJson(),
    );

    try {
      final jsonString = jsonEncode(result);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/costItems.json');

      file.writeAsStringSync(jsonString);
      debugPrint("write to json done");
      return Result.ok(null);
    } on Exception catch (e) {
      debugPrint("error writing data to file, $e");
      return Result.error(e);
    }
  }

  Future<Result<List<CostItem>>> loadDefaultCostItemJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/costItems.json');
    final fileExists = await file.exists();

    debugPrint("service load json data done");
    if (fileExists) {
      return await parseCostItemJson(file);
    } else {
      return Result.ok([]);
    }
  }

  Future<Result<List<CostItem>>?> loadCostItemJsonFromCustomFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['json'],
      type: FileType.custom,
    );
    if (result == null) return null;
    final file = File(result.files.single.path!);

    return await parseCostItemJson(file);
  }

  Future<Result<List<CostItem>>> parseCostItemJson(File file) async {
    try {
      final jsonString = file.readAsStringSync();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      final List<CostItem> items = decodedData.map((item) => CostItem.fromJson(item)).toList();
      debugPrint("service parse json data done");
      return Result.ok(items);
    } on Exception catch (e) {
      debugPrint('error reading json data: $e');
      return Result.error(e);
    }
  }

  // Future<Result<String>?> exportCostItem() async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/budget.csv');
  //     final jsonString = file.readAsStringSync();
  //     final List<int> list = jsonString.codeUnits;
  //     final String? outputFile = await FilePicker.saveFile(
  //       dialogTitle: 'Please select an output file:',
  //       fileName: 'nomi-output-${Uuid().v4().split('-').first}.csv',
  //       allowedExtensions: ['csv'],
  //       bytes: Uint8List.fromList(list),
  //     );

  //     if (outputFile == null) return null;
  //     return Result.ok(outputFile);
  //   } on Exception catch (e) {
  //     debugPrint("error exporting file: $e");
  //     return Result.error(e);
  //   }
  // }
}
