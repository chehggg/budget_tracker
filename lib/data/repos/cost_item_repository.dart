// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/utils/result.dart';

class CostItemRepository {
  CostItemRepository({required LocalServices localServices}) : _localServices = localServices {
    _initFuture = _init();
  }

  Future<void> _init() async {
    await getCostItem();

  }

  final LocalServices _localServices;

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

  CostItemRepoDataStream get dataStream => CostItemRepoDataStream(
    items: _costItems,
    daySummary: _daySummary,
    monthSummary: _monthSummary,
  );

  final StreamController<CostItemRepoDataStream> _dataStreamController =
      StreamController<CostItemRepoDataStream>.broadcast();
  Stream<CostItemRepoDataStream> get valueStream => _dataStreamController.stream;

  Future<void> getCostItem({bool customFile = false}) async {
    debugPrint('repo call service load data');

    Result<List<CostItem>>? result;
    result = await _localServices.loadCostItemFile(isDefault: !customFile);

    switch (result) {
      case Ok():
        _costItems = [];
        _gbDateCostItems = {};
        _daySummary = {};
        _monthSummary = {};
        _yearSummary = {};

        _costItems.addAll(result.value);

        final Map<DateTime, List<CostItem>> gbMonthCostItems = {};
        final Map<DateTime, List<CostItem>> gbYearCostItems = {};

        for (CostItem item in _costItems) {
          (_gbDateCostItems[item.date] ??= []).add(item);
          (gbMonthCostItems[item.date.startOfMonth] ??= []).add(item);
          (gbYearCostItems[item.date.startOfYear] ??= []).add(item);
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

        if (customFile) {
          await _localServices.writeCostItemFile(_costItems);
          // debugPrint("write custom file to default file");
        }
      case Error():
        debugPrint(result.error.toString());
    }
  }

  Future<Result<void>> deleteCostItem(CostItem deletedItem) async {
    _costItems.removeWhere((item) => item.uuid == deletedItem.uuid);
    _gbDateCostItems[deletedItem.date]!.removeWhere((item) => item.uuid == deletedItem.uuid);
    (_daySummary[deletedItem.date] ??= CostMetric()).minusFromMetric(deletedItem);
    (_monthSummary[deletedItem.date.startOfMonth] ??= CostMetric()).minusFromMetric(deletedItem);
    (_yearSummary[deletedItem.date.startOfYear] ??= CostMetric()).minusFromMetric(deletedItem);

    if (_gbDateCostItems[deletedItem.date]!.isEmpty) {
      debugPrint('remove item');
      _gbDateCostItems.remove(deletedItem.date);
    }

    _dataStreamController.add(dataStream);
    return await _localServices.writeCostItemFile(_costItems);
  }

  Future<Result<void>> updateCostItem(CostItem newItem) async {
    await deleteCostItem(_costItems.firstWhere((item) => item.uuid == newItem.uuid));
    await createCostItem(newItem);

    return await _localServices.writeCostItemFile(_costItems);
  }

  Future<Result<void>> createCostItem(CostItem item) async {
    _costItems.add(item);
    (_gbDateCostItems[item.date] ??= []).insert(0, item);
    (_daySummary[item.date] ??= CostMetric()).addToMetric(item);
    (_monthSummary[item.date.startOfMonth] ??= CostMetric()).addToMetric(item);
    (_yearSummary[item.date.startOfYear] ??= CostMetric()).addToMetric(item);
    
    _dataStreamController.add(dataStream);
    return await _localServices.writeCostItemFile(_costItems);
  }

  // Future<void> loadDataFromFile() async{
  //   _costItemService.loadCostItemJson();
  // }

  Future<void> clearCostItem() async {
    _costItems.clear();
    _daySummary = {};
    _monthSummary = {};
    _yearSummary = {};
    _dataStreamController.add(dataStream);
    _localServices.writeCostItemFile(_costItems);
  }

  Future<void> exportCostItem() async {
    _localServices.exportCostItemJson(_costItems);
  }
}

class CostItemRepoDataStream {
  CostItemRepoDataStream({
    required this.items,
    required this.daySummary,
    required this.monthSummary,
  });

  List<CostItem> items;
  Map<DateTime, CostMetric> daySummary;
  Map<DateTime, CostMetric> monthSummary;
}
