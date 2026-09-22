import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/group_repository.dart';
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

    _isInit = true;

    notifyListeners();
  }

  Currency get targetCurrency => _currencyRepo.currency;
  bool get exRateRequired => group.currency != _currencyRepo.currency.isoCode;

  double _defaultRate = 1;
  double _customExRate = 1;

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
      return _costItemRepo.costItems.where((item) => item.group == group.id).toList();
    } else {
      return _selectedCostItems;
    }
  }

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

  void submitForm() async {
    final items =
        _addGroupType == AddGroupType.all
            ? _costItemRepo.costItems.where((e) => e.group == group.id)
            : _selectedCostItems;

    for (final item in items) {
      String newName = _addGroupRename.rename(
        item.name ?? "",
        prefixText: _prefixText,
        suffixText: _suffixText,
      );
      String newCategory;

      CostItem newItem = item.copyWith(
        uuid: Uuid().v4(),
        name: newName,
        lastCreated: DateTime.now(),
        lastModified: DateTime.now(),
        group: _deleteItemAfter ? () => null : null,
        amount: exRateRequired ? (item.baseAmount ?? 1) * useExRate : null,
      );

      if (_deleteItemAfter) {
        await _costItemRepo.deleteCostItem(item);
      }
      await _costItemRepo.createCostItem(newItem);

      if (deleteGroupAfter) {
        _groupRepo.deleteGroup(group);
      }
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
