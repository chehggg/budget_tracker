import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class SavedItemRepository {
  SavedItemRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = _init();
  }

  final LocalServices _localServices;

  final List<SavedItem> _savedItems = [];
  UnmodifiableListView<SavedItem> get savedItems => UnmodifiableListView(_savedItems);

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  void restart() {
    _initFuture = _init();
  }
  
  Future<void> _init() async {
    final Result<List<SavedItem>> result = await _localServices.loadSavedItems();
    switch (result) {
      case Ok():
        _savedItems.clear();
        _savedItems.addAll(result.value);
      case Error():
        debugPrint("error in code");
    }
  }

  Future<void> addToSaved(SavedItem item) async {
    _savedItems.add(item);
    debugPrint('saved item length: ${_savedItems.length}');
    await _localServices.writeSavedItems(_savedItems);
  }

  Future<void> removeSaved(SavedItem deletedItem) async {
    _savedItems.removeWhere((item) => item.id == deletedItem.id);
    await _localServices.writeSavedItems(_savedItems);
  }

  Future<void> updateSaved(SavedItem updatedItem) async {
    await removeSaved(updatedItem);
    await addToSaved(updatedItem);

    await _localServices.writeSavedItems(_savedItems);
  }
}
