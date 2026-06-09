import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/category_class.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CategoryServices {
  Future<Result<List<CostItemCategory>>> parseCategoryJson(File file) async {
    try {
      final jsonString = file.readAsStringSync();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      final List<CostItemCategory> items =
          decodedData.map((item) => CostItemCategory.fromJson(item)).toList();
      // debugPrint("service parse json data done");
      return Result.ok(items);
    } on Exception catch (e) {
      // debugPrint('error reading json data: $e');
      return Result.error(e);
    }
  }

  Future<Result<void>> writeCategoryJsonToFile(List<CostItemCategory> items) async {
    final List<Map<String, dynamic>> result = List.generate(
      items.length,
      (i) => items[i].toJson(),
    );

    try {
      final jsonString = jsonEncode(result);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/categories.json');

      file.writeAsStringSync(jsonString);
      // debugPrint("write to json done");
      return Result.ok(null);
    } on Exception catch (e) {
      // debugPrint("error writing data to file, $e");
      return Result.error(e);
    }
  }

  Future<Result<List<CostItemCategory>>> loadDefaultCategoryJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/categories.json');
    final fileExists = await file.exists();

    if (fileExists) {
      return await parseCategoryJson(file);
    } else {
      await writeCategoryJsonToFile(defaultCostItemCategories);
      return Result.ok(defaultCostItemCategories);
    }
  }

  Future<Result<String>?> exportCategoryJson(List<CostItemCategory> items) async {
    final List<Map<String, dynamic>> result = List.generate(
      items.length,
      (i) => items[i].toJson(),
    );

    // debugPrint(result.toString());

    try {
      final jsonString = jsonEncode(result);
      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'nomi-categories-${Uuid().v4().split('-').first}.json',
        allowedExtensions: ['json'],
        bytes: utf8.encode(jsonString),
      );

      if (outputFile == null) return null;
      return Result.ok(outputFile);
    } on Exception catch (e) {
      // debugPrint("error writing data to file, $e");
      return Result.error(e);
    }
  }
}
