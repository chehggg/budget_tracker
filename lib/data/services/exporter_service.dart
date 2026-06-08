import 'dart:convert';
import 'dart:typed_data';

import 'package:budget_tracker/data/services/cost_item_service.dart';
import 'package:budget_tracker/data/services/saved_item_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class ExporterServices {
  ExporterServices({
    required SavedItemServices savedItemServices,
    required CostItemServices costItemServices,
  }) : _savedItemServices = savedItemServices,
       _costItemServices = costItemServices;

  // _final CategoryServices\
  final SavedItemServices _savedItemServices;
  final CostItemServices _costItemServices;

  Future<Result<void>?> createConfigOutput() async {
    final savedItemResult = await _savedItemServices.loadSavedItems();
    final configJson = {};
    switch (savedItemResult) {
      case Ok():
        configJson['saved'] = savedItemResult.value.map((el) => el.toJson());
      case Error():
    }

    final costItemResult = await _costItemServices.loadFileCostItems();
    switch (costItemResult) {
      case Ok():
        configJson['items'] = costItemResult.value.map((el) => el.toJson());
      case Error():
    }

    try {
      final encoded = jsonEncode(configJson);
      final String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'nomi-config-${Uuid().v4().split('-').first}.json',
        allowedExtensions: ['json'],
        bytes: utf8.encode(encoded),
      );
      if (outputFile == null) return null;
      return Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
