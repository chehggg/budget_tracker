import 'package:budget_tracker/data/repos/cost_item_repository.dart';
import 'package:budget_tracker/data/services/local_data_service.dart';
import 'package:budget_tracker/models/currency_model.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providers => [
  Provider(
    create: (context) => LocalDataServices(),
  ),
  Provider(
    create: (context) => CostItemRepository(localDataServices: context.read()),
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
  //  ChangeNotifierProvider(
  //     create: (context) => ListModel(costItemRepo: context.read()),
  // )
];
