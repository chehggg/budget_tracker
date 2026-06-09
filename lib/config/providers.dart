import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/data/services/category_service.dart';
import 'package:budget_tracker/data/services/cost_item_service.dart';
import 'package:budget_tracker/data/services/saved_item_service.dart';
import 'package:budget_tracker/models/currency_model.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/ui/list/list_viewmodel.dart';
import 'package:budget_tracker/ui/settings/setting_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providers => [
  Provider(
    create: (context) => CostItemServices(),
  ),
  Provider(
    create: (context) => SavedItemServices(),
  ),
  Provider(
    create: (context) => CategoryServices(),
  ),
  Provider(
    create: (context) => CostItemRepository(costItemServices: context.read()),
  ),
  Provider(
    create: (context) => CategoryRepository(categoryServices: context.read()),
  ),
  Provider(
    create: (context) => SavedItemRepository(savedItemServices: context.read()),
  ),
  ChangeNotifierProvider<ThemeModel>(
    create: (context) => ThemeModel(),
  ),
  ChangeNotifierProvider<CurrencyModel>(
    create: (context) => CurrencyModel(),
  ),
  ChangeNotifierProvider<NavigationModel>(
    create: (context) => NavigationModel(),
  ),
  ChangeNotifierProvider<AppModel>(
    create: (context) => AppModel(costItemRepository: context.read()),
  ),
  ChangeNotifierProvider<ListModel>(
    create: (context) => ListModel(costItemRepo: context.read(),categoryRepo: context.read()),
  ),
  ChangeNotifierProvider<SettingsViewModel>(
    create:
        (context) => SettingsViewModel(
          costItemRepository: context.read(),
          categoryRepository: context.read(),
        ),
  ),
  //  ChangeNotifierProvider(
  //     create: (context) => ListModel(costItemRepo: context.read()),
  // )
];
