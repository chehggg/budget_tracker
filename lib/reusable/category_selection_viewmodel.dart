import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class CategorySelectionViewmodel extends ChangeNotifier {
  CategorySelectionViewmodel({
    required CategoryRepository categoryRepo,
    List<CostItemCategory>? initSelection,
    this.costType,
  }) : _categoryRepo = categoryRepo,
       _initSelection = initSelection {
    init();
  }

  final CategoryRepository _categoryRepo;
  final CostType? costType;
  final List<CostItemCategory>? _initSelection;

  void init() async {
    await _categoryRepo.ready;

    if (_initSelection != null) {
      _selectedCategories = List.from(_initSelection);
      _displayedCategories = generateDisplayCategories();
    } else {
      _selectedCategories = _baseCategories;
      _displayedCategories = generateDisplayCategories();
    }
    _isInit = true;
    notifyListeners();
  }

  bool _isInit = false;
  bool get ready => _isInit;
  String? _filterString;

  List<CostItemCategory> _selectedCategories = [];
  List<CostItemCategory> _displayedCategories = [];
  UnmodifiableListView<CostItemCategory> get selectedCategories =>
      UnmodifiableListView(_selectedCategories);
  UnmodifiableListView<CostItemCategory> get displayedCategories =>
      UnmodifiableListView(_displayedCategories);

  List<CostItemCategory> get _baseCategories =>
      _categoryRepo.categories
          .where(
            (cat) => costType != null ? cat.costType == costType : true,
          )
          .toList();

  UnmodifiableListView<CostItemCategory> generateDisplayCategories() {
    final unselectedCategories = _baseCategories.where(
      (category) =>
          !_selectedCategories.contains(category) &&
          category.name!.toLowerCase().contains(_filterString ?? ""),
    );
    final filteredSelected = selectedCategories.where(
      (category) =>
          category.name!.toLowerCase().contains(_filterString ?? ""),
    );

    return UnmodifiableListView(
      [
        ...filteredSelected.sorted((a, b) => a.name!.compareTo(b.name!)),
        ...unselectedCategories.sorted((a, b) => a.name!.compareTo(b.name!)),
      ],
    );
  }

  bool get areAllSelected => _baseCategories.length == selectedCategories.length;

  void selectCategory(CostItemCategory category) {
    _selectedCategories.add(category);
    notifyListeners();
  }

  void selectAllCategories() {
    _selectedCategories = List.from(_baseCategories);
    notifyListeners();
  }

  void removeAllCategories() {
    _selectedCategories = [];
    notifyListeners();
  }

  void removeCategory(CostItemCategory category) {
    _selectedCategories.removeWhere((item) => item.id == category.id);
    notifyListeners();
  }

  void updateFilterString(String filterText) {
    if (filterText.isEmpty) {
      _filterString = null;
    } else {
      debugPrint("filter text");
      _filterString = filterText;
      // _displayedCategories =
    }
    _displayedCategories = List.from(generateDisplayCategories());
    notifyListeners();
  }
}
