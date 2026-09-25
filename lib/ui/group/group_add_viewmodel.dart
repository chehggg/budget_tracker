import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:uuid/uuid.dart';

class GroupAddViewmodel extends ChangeNotifier {
  GroupAddViewmodel({
    required this.group,
    required GroupRepository groupRepo,
    required CostItemRepository costItemRepo,
    // required SharedElementRepository sharedRepo,
    required CurrencyRepository currencyRepo,
  }) : _groupRepo = groupRepo,
       _currencyRepo = currencyRepo,
       //  _sharedRepo = sharedRepo,
       _costItemRepo = costItemRepo {
    init();
  }

  void init() async {
    await _groupRepo.ready;
    await _costItemRepo.ready;
    await _currencyRepo.ready;

    if (exRateRequired) {
      await _currencyRepo.getExchangeRates();
      final initRate = _currencyRepo.exchangeRates[group.currency] ?? 1;
      final targetRate = _currencyRepo.exchangeRates[targetCurrency.isoCode] ?? 1;

      debugPrint(initRate.toString() + "" + targetRate.toString());
      _defaultRate = targetRate / initRate;
    }

    _groupName = group.name ?? "Item added from group";

    _isInit = true;

    notifyListeners();
  }

  Currency get targetCurrency => _currencyRepo.currency;
  bool get exRateRequired => group.currency != _currencyRepo.currency.isoCode;

  double _defaultRate = 1;
  double _customExRate = 1;

  String _groupName = "Item from group";
  String get groupName =>_groupName;

  DateTime _groupDate = DateTime.now().standard;
  DateTime get groupDate =>_groupDate;

  bool _useCustomRate = false;
  bool get useCustomRate => _useCustomRate;

  double get useExRate => _useCustomRate ? _customExRate : _defaultRate;

  double get exchangeRate => _defaultRate;
  bool _isInit = false;
  bool get isInit => _isInit;
  // CostGroup _group;
  CostGroup group;

  final GroupRepository _groupRepo;
  final CurrencyRepository _currencyRepo;
  final CostItemRepository _costItemRepo;

  AddGroupType _addGroupType = AddGroupType.all;
  AddGroupType get addGroupType => _addGroupType;

  CostItemCategory? _singleItemCategory;
  CostItemCategory? get singleItemCategory => _singleItemCategory;

  AddGroupItemAs _addGroupItemAs = AddGroupItemAs.individual;
  AddGroupItemAs get addGroupItemAs => _addGroupItemAs;

  AddGroupRename _addGroupRename = AddGroupRename.none;
  AddGroupRename get addGroupRename => _addGroupRename;

  bool _deleteItemAfter = false;
  bool get deleteItemAfter => _deleteItemAfter;

  bool _deleteGroupAfter = false;
  bool get deleteGroupAfter => _deleteGroupAfter;

  bool _useSingleCategory = false;
  bool get useSingleCategory => _useSingleCategory;

  String? _prefixText;
  String? get prefix => _prefixText;

  String? _suffixText;
  String? get suffix => _suffixText;

  List<CostItem> _selectedCostItems = [];
  List<CostItem> get selectedCostItems {
    if (_addGroupType == AddGroupType.all) {
      return initCostItem;
    } else {
      return _selectedCostItems;
    }
  }

  List<CostItem> get initCostItem => _costItemRepo.costItems.where((item) => item.group == group.id).toList();

  CostMetric get metric => CostMetric.fromCostItemList(selectedCostItems);
  double get convertedBalance => metric.balance * useExRate;

  // List<CostItem>

  String get sampleText {
    final words = [
      "travel1",
      "food2",
      "medicine3",
    ];

    final newWords = words
        .map((word) {
          return _addGroupRename.rename(word, prefixText: _prefixText, suffixText: _suffixText);
        })
        .join(", ");

    return "Example output: $newWords...";
  }

  void updateGroupDate(DateTime newDate) {
    _groupDate = newDate;
    notifyListeners();
  }

  void updateGroupName(String newName) {
    _groupName = newName;
    notifyListeners();
  }
  
  void updateCategory(CostItemCategory newCat) {
    _singleItemCategory = newCat;
    notifyListeners();
  }

  void updatePrefix(String text) {
    if (text.isEmpty) {
      _prefixText = null;
    } else {
      _prefixText = text;
    }
    notifyListeners();
  }

  void updateSuffix(String text) {
    if (text.isEmpty) {
      _suffixText = null;
    } else {
      _suffixText = text;
    }
    notifyListeners();
  }

  void updateAddGroupType(AddGroupType value) {
    _addGroupType = value;
    notifyListeners();
  }

  void updateAddGroupItemAs(AddGroupItemAs value) {
    _addGroupItemAs = value;
    notifyListeners();
  }

  void updateAddGroupRename(AddGroupRename value) {
    _addGroupRename = value;
    notifyListeners();
  }

  void updateCostItems(List<CostItem> costItems) {
    _selectedCostItems = costItems;
    notifyListeners();
  }

  void toggleUseSingleCategory(bool value) {
    _useSingleCategory = value;
    notifyListeners();
  }

  void updateCustomRate(double value) {
    _customExRate = value;
    notifyListeners();
  }

  void toggleCustomExRate(bool value) {
    _useCustomRate = value;
    notifyListeners();
  }

  void toggleDeleteItem(bool value) {
    _deleteItemAfter = value;
    notifyListeners();
  }

  void toggleDeleteGroup(bool value) {
    _deleteGroupAfter = value;
    notifyListeners();
  }

  String? validateForm() {
    if ((_addGroupItemAs == AddGroupItemAs.individual &&  _useSingleCategory && _singleItemCategory == null) || (_addGroupItemAs != AddGroupItemAs.individual &&  _singleItemCategory != null)) {
      return "Category must be selected if \"Use same category\" is selected";
    } 
    if (_useCustomRate && _customExRate == 0) {
      return "exchange rate cannot be 0";
    }
    return null;
  } 
  Future<void> submitForm() async {
    // final items =
    //     _addGroupType == AddGroupType.all
    //         ? _costItemRepo.costItems.where((e) => e.group == group.id)
    //         : _selectedCostItems;
    List<CostItem> items;
    switch (_addGroupItemAs) {
      case AddGroupItemAs.individual:
        items =
            selectedCostItems
                .map(
                  (item) => item.copyWith(
                    name: _addGroupRename.rename(
                      item.name ?? "",
                      prefixText: _prefixText,
                      suffixText: _suffixText,
                    ),
                    uuid: Uuid().v4(),
                    categoryId: _useSingleCategory ? _singleItemCategory?.id : item.categoryId,
                    amount: (item.amount ?? 0) * useExRate,
                    lastCreated: DateTime.now(),
                    lastModified: DateTime.now(),
                  ),
                )
                .toList();
      case AddGroupItemAs.daily:
        items =
            selectedCostItems
                .groupFoldBy<DateTime, CostMetric>(
                  (item) => item.date!,
                  (CostMetric? prev, CostItem item) => (prev ?? CostMetric()).add(item),
                )
                .entries
                .map(
                  (entry) => CostItem(
                    uuid: Uuid().v4(),
                    date: entry.key,
                    categoryId: _singleItemCategory?.id,
                    name: group.name,
                    costType: entry.value.balance <= 0 ? CostType.expense : CostType.income,
                    baseAmount: entry.value.balance.abs(),
                    currencyIso: group.currency,
                    amount: entry.value.balance.abs() * useExRate,
                    lastCreated: DateTime.now(),
                    lastModified: DateTime.now(),
                  ),
                )
                .toList();

      case AddGroupItemAs.overall:
        final metrics = selectedCostItems.fold<CostMetric>(
          CostMetric(),
          (CostMetric prev, CostItem item) => prev.add(item),
        );
        items = [
          CostItem(
            uuid: Uuid().v4(),
            date: _groupDate, // TODO: update date
            categoryId: _singleItemCategory?.id,
            name: group.name,
            costType: metrics.balance <= 0 ? CostType.expense : CostType.income,
            baseAmount: metrics.balance.abs(),
            currencyIso: group.currency,
            amount: metrics.balance.abs() * useExRate,
            lastCreated: DateTime.now(),
            lastModified: DateTime.now(),
          ),
        ];
      // items = selectedCostItems;
    }
    for (final item in items) {
      await _costItemRepo.createCostItem(item);
    }

    for (final item in selectedCostItems) {
      if (_deleteItemAfter) {
        await _costItemRepo.deleteCostItem(item);
      }
    }
    if (deleteGroupAfter) {
      _groupRepo.deleteGroup(group);
    }
  }

  String Function(
    double value, {
    String? customIso,
    bool abbreviated,
    bool alwaysShowSign,
    bool showSymbol,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;
}

enum AddGroupType { all, partial }

enum AddGroupItemAs { individual, daily, overall }

enum AddGroupRename {
  none,
  prefix,
  suffix;

  String rename(String word, {String? prefixText, String? suffixText}) {
    switch (this) {
      case none:
        return word;
      case prefix:
        return (prefixText ?? "") + word;
      case suffix:
        return word + (suffixText ?? "");
    }
  }
}
