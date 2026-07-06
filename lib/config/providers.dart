import 'package:budget_tracker/data/repos/category_repository.dart';
import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/repos/currency_repository.dart';
import 'package:budget_tracker/data/repos/exchange_rate_repository.dart';
import 'package:budget_tracker/data/repos/goal_repository.dart';
import 'package:budget_tracker/data/repos/saved_item_repository.dart';
import 'package:budget_tracker/data/repos/shared_element_repository.dart';
import 'package:budget_tracker/data/services/api_service.dart';
import 'package:budget_tracker/data/services/local_service.dart';
import 'package:budget_tracker/models/currency_model.dart';
import 'package:budget_tracker/models/navigator_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providers => [
  Provider(
    create: (context) => LocalServices(),
  ),
  Provider(
    create: (context) => ApiServices(),
  ),
  Provider(
    create: (context) => CostItemRepository(localServices: context.read()),
  ),
  Provider(
    create: (context) => GoalRepository(localServices: context.read()),
  ),
  Provider(
    create: (context) => CategoryRepository(localServices: context.read()),
  ),
  Provider(
    create: (context) => SavedItemRepository(localServices: context.read()),
  ),
  Provider(
    create: (context) => ExchangeRateRepository(apiServices: context.read()),
  ),
  Provider(
    create:
        (context) => CurrencyRepository(localServices: context.read(), apiServices: context.read()),
  ),
  Provider(
    create: (context) => SharedElementRepository(localServices: context.read()),
  ),
  ChangeNotifierProvider<ThemeModel>(
    create: (context) => ThemeModel(),
  ),
  ChangeNotifierProvider<NavigatorModel>(
    create: (context) => NavigatorModel(),
  ),
];
