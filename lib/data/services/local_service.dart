import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalServices {
  final pref = SharedPreferencesAsync();

  Future<String?> _loadSharedPref(String key) async {
    final prefString = await pref.getString(key);
    return prefString;
  }

  Future<void> _writeStringToSharedPref(String key, String value) async {
    await pref.setString(key, value);
  }

  Future<void> _writeToFile(String fileName, dynamic json) async {
    final jsonString = jsonEncode(json);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');

    file.writeAsStringSync(jsonString);
  }

  Future<String?> _exportFile(String fileName, dynamic json) async {
    final jsonString = jsonEncode(json);
    return await FilePicker.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'nomi-$fileName.json',
      allowedExtensions: ['json'],
      bytes: utf8.encode(jsonString),
    );
  }

  Future<File?> _loadDefaultFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');
    final fileExists = await file.exists();

    return fileExists ? file : null;
  }

  Future<File?> _loadUserFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['json'],
      type: FileType.custom,
    );

    return result != null ? File(result.files.single.path!) : null;
  }

  /// cost item file
  Future<Result<List<CostItem>>> parseCostItemJson(File file) async {
    try {
      final jsonString = file.readAsStringSync();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      final List<CostItem> items = decodedData.map((item) => CostItem.fromJson(item)).toList();
      return Result.ok(items);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> writeCostItemFile(List<CostItem> items) async {
    try {
      final List<Map<String, dynamic>> json = List.generate(
        items.length,
        (i) => items[i].toJson(),
      );
      await _writeToFile('costItems', json);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<CostItem>>> loadCostItemFile({bool isDefault = true}) async {
    try {
      final fileResult = isDefault ? await _loadDefaultFile('costItems') : await _loadUserFile();
      if (fileResult == null) {
        return Result.ok([]);
      } else {
        return await parseCostItemJson(fileResult);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<String?>> exportCostItemJson(List<CostItem> items) async {
    try {
      final List<Map<String, dynamic>> json = List.generate(
        items.length,
        (i) => items[i].toJson(),
      );
      final export = await _exportFile("costItems-${Uuid().v4().split('-').first}", json);

      return Result.ok(export);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// goals file
  Future<Result<List<Goal>>> parseGoalsJson(File file) async {
    try {
      final jsonString = file.readAsStringSync();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      final List<Goal> items = decodedData.map((item) => Goal.fromJson(item)).toList();
      return Result.ok(items);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Goal>>> loadGoalsFile() async {
    try {
      final fileResult = await _loadDefaultFile('goals');
      if (fileResult == null) {
        return Result.ok([]);
      } else {
        return await parseGoalsJson(fileResult);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> writeGoalsFile(List<Goal> items) async {
    try {
      final List<Map<String, dynamic>> json = List.generate(
        items.length,
        (i) => items[i].toJson(),
      );
      await _writeToFile('goals', json);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// saved item
  Future<Result<List<SavedItem>>> loadSavedItems() async {
    try {
      String? itemString = await _loadSharedPref("savedItems");
      if (itemString == null) return Result.ok([]);

      debugPrint("saved items: $itemString");
      if (itemString.startsWith('"') && itemString.endsWith('"')) {
        itemString = itemString.substring(1, itemString.length - 1);
      }
      final results =
          (jsonDecode(itemString) as List<dynamic>)
              .map((el) => SavedItem.fromJson(el as Map<String, dynamic>))
              .toList();
      return Result.ok(results);
    } on Exception catch (e) {
      debugPrint("error in getting saved item, $e");
      return Result.error(e);
    }
  }

  Future<Result<void>> writeSavedItems(List<SavedItem> items) async {
    try {
      final json = items.map((SavedItem el) => el.toJson()).toList();
      await _writeStringToSharedPref("savedItems", jsonEncode(json));
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  ///category
  Future<Result<List<CostItemCategory>>> parseCategoryJson(File file) async {
    try {
      final jsonString = file.readAsStringSync();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      final List<CostItemCategory> items =
          decodedData.map((item) => CostItemCategory.fromJson(item)).toList();
      return Result.ok(items);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<CostItemCategory>>> loadCategoriesFile() async {
    try {
      final fileResult = await _loadDefaultFile('categories');
      if (fileResult == null) {
        await writeCategoriesFile(defaultCostItemCategories);
        return Result.ok(defaultCostItemCategories);
      } else {
        return await parseCategoryJson(fileResult);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> writeCategoriesFile(List<CostItemCategory> items) async {
    try {
      final List<Map<String, dynamic>> json = List.generate(
        items.length,
        (i) => items[i].toJson(),
      );
      await _writeToFile('categories', json);
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> writeCurrency(Currency currency) async {
    try {
      await _writeStringToSharedPref("currency", jsonEncode(currency.toJson()));
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<Currency?>> getCurrency() async {
    try {
      final jsonString = await _loadSharedPref("currency");
      if (jsonString != null) {
        return Result.ok(Currency.fromJson(jsonDecode(jsonString)));
      } else {
        return Result.ok(null);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> writeRecentlyUsedCurrency(List<Currency> currency) async {
    try {
      await _writeStringToSharedPref(
        "recentCurrencies",
        currency.map((currency) => currency.isoCode).join(','),
      );
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Currency>?>> getRecentlyUsedCurrency() async {
    try {
      final result = await _loadSharedPref("recentCurrencies");
      if (result != null) {
        return Result.ok(result.split(",").map((isoCode) => Currencies().find(isoCode)?? CommonCurrencies().usd).toList());
      } else {
        return Result.ok(null);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
