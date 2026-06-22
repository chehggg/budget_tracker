import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SavedItemModel extends ChangeNotifier {
  SavedItemModel({
    CostItemFormResult? formData,
    SavedItem? initItem,
    required CostItemCategory category,
    required SavedItemRepository savedItemRepository,
  }) : _savedItemRepository = savedItemRepository,
       _initItem = initItem,
       _formData = formData,
       _category = category {
    init();
  }

  final SavedItem? _initItem;
  final CostItemFormResult? _formData;
  final SavedItemRepository _savedItemRepository;
  final CostItemCategory _category;

  void init() async {
    _isLoaded = false;

    // edit existing item
    if (isEditMode) {
      _id = _initItem!.id!;
      _title = _initItem.title ?? "Untitled";
      _description = _initItem.description;
      _amount = _initItem.amount;
      _date = _initItem.date;
      _keepDesc = _description != null;
      _keepAmount = _amount != null;
      _keepDate = _date != null;
    } else {
      _id = Uuid().v4();
      _description = _formData?.name;
      _amount = _formData?.amount;
      _date = _formData?.date;
    }

    await _savedItemRepository.ready;

    _isLoaded = true;
    notifyListeners();
  }

  bool get isEditMode => _initItem != null;

  CostItemCategory get selectedCategory => _category;

  bool _isLoaded = false;
  bool get ready => _isLoaded;

  String _title = "";
  String get title => _title;

  late String _id;

  String? _description;
  String? get description => _description;

  double? _amount = 0;
  double? get amount => _amount;

  DateTime? _date = DateTime.now().standard;
  DateTime? get date => _date;

  bool _keepDesc = true;
  bool get keepDesc => _keepDesc;

  bool _keepAmount = true;
  bool get keepAmount => _keepAmount;

  bool _keepDate = false;
  bool get keepDate => _keepDate;

  void toggleKeepValue(bool? value, String metric) {
    if (value == null) return;
    switch (metric) {
      case "description":
        _keepDesc = value;
      case "amount":
        _keepAmount = value;
      case "date":
        _keepDate = value;
    }
    notifyListeners();
  }

  void updateAmount(String value) {
    _amount = double.tryParse(value) ?? 0;
    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    _date = newDate;
    notifyListeners();
  }

  void updateDesc(String desc) {
    _description = desc;
    notifyListeners();
  }

  void updateTitle(String value) {
    _title = value;
    notifyListeners();
  }

  SavedItem get curSavedItem => SavedItem(
    id: _id,
    title: _title.isNotEmpty ? _title : "Untitled",
    category: _category.id,
    costType: _category.costType,
    description: _keepDesc ? _description : null,
    date: _keepDate ? _date : null,
    amount: _keepAmount ? _amount : null,
    lastModified: DateTime.now(),
  );

  Future<void> updateSavedItem() async {
    if (_initItem != null) {
      await _savedItemRepository.updateSaved(curSavedItem);
      notifyListeners();
    }
  }

  Future<void> deleteSavedItem() async {
    if (_initItem != null) {
      await _savedItemRepository.removeSaved(_initItem);
      notifyListeners();
    }
  }

  Future<void> saveItem() async {
    await _savedItemRepository.addToSaved(curSavedItem);
    notifyListeners();
  }
}
