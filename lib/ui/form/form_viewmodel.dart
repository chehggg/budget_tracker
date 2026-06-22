import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FormModel extends ChangeNotifier {
  FormModel({
    required CostItemRepository costItemRepo,
    required SavedItemRepository savedItemRepo,
    required CategoryRepository categoryRepo,
    CostItem? initCostItem,
  }) : _costItemRepository = costItemRepo,
       _savedItemRepository = savedItemRepo,
       _initCostItem = initCostItem,
       _categoryRepo = categoryRepo {
    initialize();
  }

  final CostItem? _initCostItem;
  final CostItemRepository _costItemRepository;
  final SavedItemRepository _savedItemRepository;
  final CategoryRepository _categoryRepo;

  CostItemFormResult get formResult {
    return CostItemFormResult(
      name: _itemDesc,
      date: _date,
      costType: _type,
      category: _selectedCategory!,
      amount: _amount ?? 0,
    );
  }

  String? validateFormResult() {
    if (_selectedCategory == null) {
      return "No category selected!";
    }
    if (double.tryParse(_amountController.text) == null) {
      return "Amount is invalid!";
    }
    if (_amount == null || _amount == 0) {
      return "Amount cannot be 0!";
    }
    return null;
  }

  FormGroup _formGroup = FormGroup.expense;
  FormGroup get formGroup => _formGroup;

  List<CostItemCategory> get categories =>
      _categoryRepo.categories.where((category) => category.costType == _type).toList();

  bool _isLoaded = false;
  bool get ready => _isLoaded;

  bool get editMode => _initCostItem != null;

  UnmodifiableListView<SavedItem> get savedItems => _savedItemRepository.savedItems;

  CostItemCategory getCatById(SavedItem item) {
    return _categoryRepo.categories.firstWhereOrNull((el) => el.id == item.category) ??
        CostItemCategory.error();
  }

  CostItemCategory? _selectedCategory;
  CostItemCategory? get selectedCategory => _selectedCategory;

  double? _amount;
  double? get amount => _amount;

  String _itemDesc = "";
  String get itemDesc => _itemDesc;

  CostType _type = CostType.expense;
  CostType get type => _type;

  DateTime _date = DateTime.now().standard;
  DateTime get date => _date;

  String _savedTitle = "";
  String get savedTitle => _savedTitle;

  bool _utilityRefresh = false;
  bool get refreshed => _utilityRefresh;

  // description controller to be used in form
  // need to be here because the saved item need to be able to update this
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController get descriptionController => _descriptionController;

  final TextEditingController _amountController = TextEditingController();
  TextEditingController get amountController => _amountController;

  void updateControllerValue() {
    _descriptionController.value = _descriptionController.value.copyWith(text: _itemDesc);
    if (amount != null) {
      _amountController.value = _amountController.value.copyWith(
        text: _amount!.toStringAsFixed(amount! % 1 == 0 ? 0 : 2),
      );
    }
  }

  Future<void> initialize() async {
    _isLoaded = false;

    populateInitValue();
    updateControllerValue();

    _descriptionController.addListener(() => updateDesc(_descriptionController.text));
    _amountController.addListener(() {
      updateAmount(double.tryParse(_amountController.text) ?? 0);
    });

    await _categoryRepo.ready;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> reloadCategory() async {
    await _categoryRepo.getCategory(revertToDefault: true);
  }

  void selectNewCategory(CostItemCategory category) {
    _selectedCategory = category;
    _type = category.costType!;
    notifyListeners();
  }

  void updateFormGroup(FormGroup group) {
    _formGroup = group;
    _type = group.costType ?? CostType.expense;
    notifyListeners();
  }

  void selectSavedItem(SavedItem item) {
    _selectedCategory = getCatById(item);
    _type = item.costType!;
    _amount = item.amount ?? _amount;
    _itemDesc = item.description ?? _itemDesc;

    updateControllerValue();

    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    debugPrint("date updated");
    _date = newDate;
    notifyListeners();
  }

  void updateAmount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  void updateDesc(String value) {
    _itemDesc = value;
    notifyListeners();
  }

  void updateSavedItemTitle(String value) {
    _savedTitle = value;
    notifyListeners();
  }

  void populateInitValue() {
    debugPrint('initializing form model');

    if (_initCostItem != null) {
      debugPrint('found cost item');
      _selectedCategory =
          categories.firstWhereOrNull(
            (cat) => cat.id == _initCostItem.categoryId,
          ) ??
          CostItemCategory(
            id: "0",
            name: "Category 404",
            costType: _initCostItem.costType,
            imagePath: "assets/images/warning.svg",
            color: Colors.white,
          );
      _amount = _initCostItem.amount;
      _itemDesc = _initCostItem.name;
      _date = _initCostItem.date;
      _type = _initCostItem.costType;
      _formGroup = _type == CostType.expense ? FormGroup.expense : FormGroup.income;
    }
    notifyListeners();
  }

  Future<void> deleteItem() async {
    if (_initCostItem == null) return;
    await _costItemRepository.deleteCostItem(_initCostItem);
    notifyListeners();
  }

  Future<void> deleteSavedItem(SavedItem item) async {
    await _savedItemRepository.removeSaved(item);
    notifyListeners();
  }

  Future<void> submitForm() async {
    if (_initCostItem != null) {
      await _costItemRepository.updateCostItem(
        CostItem.update(_initCostItem, formResult),
      );
    } else {
      await _costItemRepository.createCostItem(CostItem.fromForm(formResult, id: Uuid().v4()));
    }
  }

  void refresh() {
    _utilityRefresh = _utilityRefresh;
    notifyListeners();
  }
}
