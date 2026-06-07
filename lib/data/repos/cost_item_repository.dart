import 'dart:collection';

import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/data/services/local_data_service.dart';
import 'package:budget_tracker/utils/result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CostItemRepository {
  CostItemRepository({required LocalDataServices localDataServices})
    : _localDataService = localDataServices {
    _initFuture = _init();
  }

  Future<void> _init() async {
    await _getCostItems();
    debugPrint("repo init done");
  }

  final LocalDataServices _localDataService;

  late final Future<void> _initFuture;
  Future<void> get ready => _initFuture;

  List<CostItem> _costItems = List<CostItem>.empty(growable: true);
  List<CostItem> get costItems => UnmodifiableListView(_costItems);

  Map<DateTime, List<CostItem>> _gbDateCostItems = {};
  Map<DateTime, List<CostItem>> get gbDateCostItems => UnmodifiableMapView(_gbDateCostItems);

  Map<DateTime, CostMetric> _daySummary = {};
  Map<DateTime, CostMetric> get daySummary => UnmodifiableMapView(_daySummary);

  Map<DateTime, CostMetric> _monthSummary = {};
  Map<DateTime, CostMetric> get monthSummary => UnmodifiableMapView(_monthSummary);

  Map<DateTime, CostMetric> _yearSummary = {};
  Map<DateTime, CostMetric> get yearSummary => UnmodifiableMapView(_yearSummary);

  Future<void> _getCostItems() async {
    _costItems.clear();
    debugPrint('repo call service load data');
    final Result<List<CostItem>> result = await _localDataService.loadFileCostItems();
    switch (result) {
      case Ok():
        _costItems.addAll(result.value);

        final Map<DateTime, List<CostItem>> gbMonthCostItems = {};
        final Map<DateTime, List<CostItem>> gbYearCostItems = {};

        for (CostItem item in _costItems) {
          (_gbDateCostItems[item.date] ??= []).add(item);
          (gbMonthCostItems[item.date.startOfMonth] ??= []).add(item);
          (gbYearCostItems[DateTime(item.date.year)] ??= []).add(item);
        }

        _daySummary = _gbDateCostItems.map(
          (key, value) => MapEntry(key, CostMetric.fromCostItemList(value)),
        );

        _monthSummary = gbMonthCostItems.map(
          (key, value) => MapEntry(key, CostMetric.fromCostItemList(value)),
        );

        _yearSummary = gbYearCostItems.map(
          (key, value) => MapEntry(key, CostMetric.fromCostItemList(value)),
        );
      case Error():
        debugPrint(result.error.toString());
    }
  }

  Future deleteCostItem(CostItem deletedItem) async {
    _costItems.removeWhere((item) => item.uuid == deletedItem.uuid);
    _gbDateCostItems[deletedItem.date]!.removeWhere((item) => item.uuid == deletedItem.uuid);

    _localDataService.writeCostItemsToFile(_costItems);
  }

  Future updateCostItem() async {
    _localDataService.writeCostItemsToFile(_costItems);
  }

  Future createCostItem(CostItem item) async {
    (_gbDateCostItems[item.date] ??= []).add(item);
    _costItems.add(item);

    _localDataService.writeCostItemsToFile(_costItems);
  }

  Future<void> clearCostItem() async {
    _costItems.clear();
    _localDataService.writeCostItemsToFile(_costItems);
  }
}
