// import 'dart:convert';

// import 'package:budget_tracker/data/services/saved_item_service.dart';
// import 'package:budget_tracker/utils/result.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'dart:io';

import 'package:budget_tracker/utils/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExporterServices {
  ExporterServices();

  final pref = SharedPreferencesAsync();
  final fileNames = ['costItems', 'goals', 'categories'];
  Future<Result<void>> exportData() async {
    final prefParam = await pref.getAll();
    // final jsonString = jsonEncode(prefParam);

    Map<String, dynamic> map = {};
    map.addEntries([MapEntry('pref', prefParam)]);
    for (final file in fileNames) {
      final result = await _loadFile(file);
      final jsonString = result?.readAsStringSync();
      map.addEntries([MapEntry(file, jsonString ?? [])]);
    }
    final jsonString = jsonEncode(map);
    debugPrint(jsonString);

    return Result.ok(null);
    // try {
    //   final pickerResult = await FilePicker.saveFile(
    //     fileName: "Nomi-export.json",
    //     allowedExtensions: ['json'],
    //     bytes: utf8.encode(jsonString),
    //   );
    //   if (pickerResult != null) {
    //     return Result.ok(null);
    //   } else {
    //     return Result.error(Exception("No file selected"));
    //   }
    // } on Exception catch (e) {
    //   return Result.error(e);
    // }
  }

  Future<File?> _loadFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');
    final fileExists = await file.exists();

    return fileExists ? file : null;
  }

  Future<void> _writeFile(String fileName, dynamic json) async {
    final jsonString = jsonEncode(json);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');

    file.writeAsStringSync(jsonString);
  }

  Future<Result<void>> loadData() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['json'],
        type: FileType.custom,
        withData: true,
      );
      if (result != null) {
        final jsonString = utf8.decode(result.files.first.bytes?.toList() ?? []);
        debugPrint(jsonString);

        
        // final map = jsonDecode(jsonString) as Map<String, dynamic>;
        // final Map<String, Object?> prefMap = map['pref'];
        // for (final entry in prefMap.entries) {
        //   if (entry.value.runtimeType is bool) {
        //     pref.setBool(entry.key, entry.value as bool);
        //   } else if (entry.value.runtimeType is String) {
        //     pref.setString(entry.key, entry.value as String);
        //   } else if (entry.value.runtimeType is int) {
        //     pref.setInt(entry.key, entry.value as int);
        //   }
        // }

        // for (final file in fileNames) {
        //   final json = map.entries.firstWhere((entry) => entry.key == file).value;
        //   await _writeFile(file, json);
        // }
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
    return Result.ok(null);
  }
  // ExporterServices({
  //   required SavedItemServices savedItemServices,
  // }) : _savedItemServices = savedItemServices;

  // // _final CategoryServices\
  // final SavedItemServices _savedItemServices;

  // Future<Result<void>?> createConfigOutput() async {
  //   final savedItemResult = await _savedItemServices.loadSavedItems();
  //   final configJson = {};
  //   switch (savedItemResult) {
  //     case Ok():
  //       configJson['saved'] = savedItemResult.value.map((el) => el.toJson());
  //     case Error():
  //   }

  //   final costItemResult = await _costItemServices.loadFileCostItems();
  //   switch (costItemResult) {
  //     case Ok():
  //       configJson['items'] = costItemResult.value.map((el) => el.toJson());
  //     case Error():
  //   }

  //   try {
  //     final encoded = jsonEncode(configJson);
  //     final String? outputFile = await FilePicker.saveFile(
  //       dialogTitle: 'Please select an output file:',
  //       fileName: 'nomi-config-${Uuid().v4().split('-').first}.json',
  //       allowedExtensions: ['json'],
  //       bytes: utf8.encode(encoded),
  //     );
  //     if (outputFile == null) return null;
  //     return Result.ok(null);
  //   } on Exception catch (e) {
  //     return Result.error(e);
  //   }
  // }
}
