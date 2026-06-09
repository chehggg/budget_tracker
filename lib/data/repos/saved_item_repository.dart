import 'package:budget_tracker/custom/saved_item_class.dart';
import 'package:budget_tracker/data/services/saved_item_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SavedItemRepository {
  SavedItemRepository({required SavedItemServices savedItemServices})
    : _savedItemServices = savedItemServices {
    _initFuture = _init();
  }

  final SavedItemServices _savedItemServices;

  List<SavedItem> _savedItems = [];
  UnmodifiableListView<SavedItem> get savedItems => UnmodifiableListView(_savedItems);

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  Future<void> _init() async {
    // final Result<List<SavedItem>> result = await _savedItemServices.loadSavedItems();
    // switch (result) {
    //   case Ok():
    //     _savedItems.clear();
    //     _savedItems.addAll(result.value);
    //   case Error():
    //     debugPrint("error in code");
    // }
  }

  Future<void> addToSaved(SavedItem item) async {
    _savedItems.add(item);
    await _savedItemServices.writeSavedItems(_savedItems);
  }
  
  Future<void> removeSaved(SavedItem item) async {
    // _savedItems.add(item);
    await _savedItemServices.writeSavedItems(_savedItems);
  }
}
