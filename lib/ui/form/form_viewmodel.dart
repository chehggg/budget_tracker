import 'dart:async';

import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FormViewModel extends ChangeNotifier {
  FormViewModel({
    required CostItemRepository costItemRepo,
    required SavedItemRepository savedItemRepo,
    required CategoryRepository categoryRepo,
    required CurrencyRepository currencyRepo,
    required SharedElementRepository sharedElRepo,
    CostItem? initCostItem,
  }) : _costItemRepo = costItemRepo,
       _savedItemRepo = savedItemRepo,
       _initCostItem = initCostItem,
       _currencyRepo = currencyRepo,
       _sharedElRepo = sharedElRepo,
       _categoryRepo = categoryRepo {
    init();
  }

  final CostItem? _initCostItem;
  final CostItemRepository _costItemRepo;
  final SavedItemRepository _savedItemRepo;
  final CategoryRepository _categoryRepo;
  final CurrencyRepository _currencyRepo;
  final SharedElementRepository _sharedElRepo;

  Future<void> init() async {
    _isLoaded = false;
    _populateInitValue();

    await _categoryRepo.ready;
    await _costItemRepo.ready;
    await _savedItemRepo.ready;
    await _currencyRepo.ready;

    _updateControllerValue();

    _descriptionController.addListener(() => updateName(_descriptionController.text));
    _amountController.addListener(() {
      updateAmount(double.tryParse(_amountController.text) ?? 0);
    });

    _subscription = _categoryRepo.categoryStream.listen((value) {
      debugPrint('category repo trigger form change');
      notifyListeners();
    });
    _isLoaded = true;
    notifyListeners();
  }

  StreamSubscription<List<CostItemCategory>>? _subscription;

  void _populateInitValue() {
    debugPrint('initializing form model');

    if (_initCostItem != null) {
      _draftedItem = _initCostItem;
      _formGroup =
          _initCostItem.costType == CostType.expense ? FormGroup.expense : FormGroup.income;
    } else {
      _draftedItem = CostItem(uuid: Uuid().v4(), date: DateTime.now().standard);
    }
  }

  String? validateFormResult() {
    if (_draftedItem.categoryId == null) {
      return "No category selected!";
    }
    if (double.tryParse(_amountController.text) == null) {
      return "Amount is invalid!";
    }
    if (_draftedItem.amount == 0 || _draftedItem.amount == null) {
      return "Amount cannot be 0!";
    }
    return null;
  }

  CostItem _draftedItem = CostItem();
  CostItem get draft => _draftedItem;

  FormGroup _formGroup = FormGroup.expense;
  FormGroup get formGroup => _formGroup;

  List<CostItemCategory> get categories =>
      _categoryRepo.categories
          .where(
            (category) =>
                _formGroup.costType == null ? true : (category.costType == _formGroup.costType),
          )
          .toList();

  bool _isLoaded = false;
  bool get ready => _isLoaded;

  bool get inEditMode => _initCostItem != null;

  UnmodifiableListView<SavedItem> get savedItems => _savedItemRepo.savedItems;

  CostItemCategory getSavedItemCatById(SavedItem item) {
    return _categoryRepo.categories.firstWhereOrNull((el) => el.id == item.category) ??
        CostItemCategory.error();
  }

  // CostItemCategory? _selectedCategory;
  CostItemCategory? get selectedCategory =>
      _categoryRepo.categories.firstWhereOrNull((cat) => _draftedItem.categoryId == cat.id);

  String _savedTitle = "";
  String get savedTitle => _savedTitle;

  bool _utilityRefresh = false;
  bool get refreshed => _utilityRefresh;

  bool _editCategory = false;
  bool get editCategory => _editCategory;

  // description controller to be used in form
  // need to be here because the saved item need to be able to update this
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController get descriptionController => _descriptionController;

  final TextEditingController _amountController = TextEditingController();
  TextEditingController get amountController => _amountController;

  void _updateControllerValue() {
    _descriptionController.value = _descriptionController.value.copyWith(text: _draftedItem.name);
    if (_draftedItem.amount != null) {
      _amountController.value = _amountController.value.copyWith(
        text: _draftedItem.amount?.formatRoundedString(),
      );
    }
  }

  void toggleEditCategory([bool? value]) {
    _editCategory = value ?? !_editCategory;

    // if (_editCategory) {
    //   _draftedItem = _draftedItem.copyWith(categoryId: null);
    //   notifyListeners();
    // }
    notifyListeners();
  }

  void updateCategory(CostItemCategory newCategory) {
    _draftedItem = _draftedItem.copyWith(
      categoryId: newCategory.id,
      costType: newCategory.costType,
    );
    _editCategory = false;
    notifyListeners();
  }

  void updateFormGroup(FormGroup group) {
    _formGroup = group;
    notifyListeners();
  }

  void selectSavedItem(SavedItem item) {
    _draftedItem = _draftedItem.copyWith(
      name: item.description,
      categoryId: item.category,
      costType: item.costType,
      date: item.date,
      amount: item.amount,
    );

    _updateControllerValue();

    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    _draftedItem = _draftedItem.copyWith(date: newDate);
    notifyListeners();
  }

  void updateAmount(double newAmount) {
    _draftedItem = _draftedItem.copyWith(amount: newAmount);
    notifyListeners();
  }

  void updateAmountFromString(String amountText) {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {}
  }

  void applyExchangedValue(double newAmount) {
    _draftedItem = _draftedItem.copyWith(amount: newAmount);
    _updateControllerValue();
    notifyListeners();
  }

  void updateName(String newName) {
    _draftedItem = _draftedItem.copyWith(name: newName);
    notifyListeners();
  }

  void updateSavedItemTitle(String value) {
    _savedTitle = value;
    notifyListeners();
  }

  Future<void> deleteItem() async {
    if (_initCostItem == null) return;
    await _costItemRepo.deleteCostItem(_initCostItem);
    notifyListeners();
  }

  Future<void> deleteSavedItem(SavedItem item) async {
    await _savedItemRepo.removeSaved(item);
    notifyListeners();
  }

  Future<void> submitForm() async {
    final finalItem = _draftedItem.copyWith(
      lastModified: DateTime.now(),
      lastCreated: inEditMode ? null : DateTime.now(),
    );
    if (inEditMode) {
      await _costItemRepo.updateCostItem(finalItem);
    } else {
      await _costItemRepo.createCostItem(finalItem);
    }
  }

  Future<void> duplicateForm() async {
    final finalItem = _draftedItem.copyWith(
      lastModified: DateTime.now(),
      lastCreated: DateTime.now(),
    );
    await _costItemRepo.createCostItem(finalItem);
  }

  void refresh() {
    _utilityRefresh = _utilityRefresh;
    notifyListeners();
  }

  String get currencySymbol => _currencyRepo.currency.symbol;
  bool get symbolOnLeft => _currencyRepo.currency.symbolOnLeft;
  String Function(
    double value, {
    bool abbreviated,
    bool alwaysShowSign,
    bool compact,
    int? decimalDigits,
  })
  get currencyFormat => _currencyRepo.formatCurrency;

  KeyboardSettings get settings => _sharedElRepo.keyboardSettings;
  String get customButtonText =>
      settings.layout == KeyboardLayout.simple &&
              _sharedElRepo.keyboardButton == SimpleKeyboardButtonType.doubleZero
          ? "00"
          : _currencyRepo.currency.decimalSeparator;

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _subscription?.cancel();
  }
}
