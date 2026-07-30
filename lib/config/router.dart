import 'package:budget_tracker/config/router_component.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/custom/classes/saved_item_class.dart';
import 'package:budget_tracker/reusable/category_selection_screen.dart';
import 'package:budget_tracker/reusable/category_selection_viewmodel.dart';
import 'package:budget_tracker/reusable/text_selection_screen.dart';
import 'package:budget_tracker/reusable/text_selection_viewmodel.dart';
// import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/screens/settings/currency_screen.dart';
import 'package:budget_tracker/screens/settings/ex_rate_screen.dart';
import 'package:budget_tracker/screens/settings/ex_rate_viewmodel.dart';
import 'package:budget_tracker/ui/category_form/category_form_screen.dart';
import 'package:budget_tracker/ui/category_form/category_form_viewmodel.dart';
import 'package:budget_tracker/ui/category_form/category_icon_selection_screen.dart';
import 'package:budget_tracker/ui/chart/details/chart_avg_cumulative_details_screen.dart';
import 'package:budget_tracker/ui/chart/details/chart_cumulative_details_screen.dart';
import 'package:budget_tracker/ui/chart/details/chart_category_breakdown_screen.dart';
import 'package:budget_tracker/ui/chart/chart_mtd_compare_screen.dart';
import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/ui/chart/chart_viewmodel.dart';
import 'package:budget_tracker/ui/chart/details/chart_daily_spend_details_screen.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/form/form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_info_screen.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_list_screen.dart';
import 'package:budget_tracker/ui/goal/goal_list_viewmodel.dart';
import 'package:budget_tracker/ui/list/main_list_screen.dart';
import 'package:budget_tracker/ui/list/main_list_viewmodel.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_screen.dart';
import 'package:budget_tracker/ui/saved_item/saved_item_viewmodel.dart';
import 'package:budget_tracker/ui/settings/additional_currency_settings_screen.dart';
import 'package:budget_tracker/ui/settings/additional_currency_settings_viewmodel.dart';
import 'package:budget_tracker/ui/settings/display/global_display_settings_screen.dart';
import 'package:budget_tracker/ui/settings/keyboard_settings_screen.dart';
import 'package:budget_tracker/ui/settings/language_settings_screen.dart';
import 'package:budget_tracker/ui/settings/display/list_display_settings_screen.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final _rootNavigator = GlobalKey<NavigatorState>();
final _navigatorA = GlobalKey<NavigatorState>();
// final _navigatorB = GlobalKey<NavigatorState>();
// final _navigatorC = GlobalKey<NavigatorState>();
// final _navigatorD = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigator,
  // refreshListenable: ,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Return your app's main layout scaffold here
        return CustomMainScaffold(shell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _navigatorA,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                return ChangeNotifierProvider(
                  create:
                      (context) => ListViewModel(
                        costItemRepo: context.read(),
                        categoryRepo: context.read(),
                        currencyRepo: context.read(),
                        sharedRepo: context.read(),
                      ),
                  child: CostListScreenWrapper(),
                );
              },
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigator,
                  path: '/categories',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => CategorySelectionViewModel(
                              categoryRepo: context.read(),
                              initSelection: state.extra as List<CostItemCategory>?,
                            ),
                        child: const CategorySelectionScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chart',
              builder:
                  (context, state) => ChangeNotifierProvider(
                    create:
                        (context) => ChartViewModel(
                          sharedRepo: context.read(),
                          costItemRepo: context.read(),
                          currencyRepo: context.read(),
                          categoryRepo: context.read(),
                        ),
                    child: const ChartScreen(),
                  ),
              routes: [
                GoRoute(
                  path: '/category-breakdown',
                  builder:
                      (context, state) => ChangeNotifierProvider.value(
                        value: state.extra as ChartViewModel,
                        child: ChartCategoryBreakdownScreen(),
                      ),
                ),
                GoRoute(
                  path: '/cumulative-balance',
                  builder:
                      (context, state) => ChangeNotifierProvider.value(
                        value: state.extra as ChartViewModel,
                        child: CumulativeBalanceDetailScreen(),
                      ),
                ),
                GoRoute(
                  path: '/daily-spend',
                  builder:
                      (context, state) => ChangeNotifierProvider.value(
                        value: state.extra as ChartViewModel,
                        child: DailySpendDetailsScreen(),
                      ),
                ),
                GoRoute(
                  path: '/cumulative-avg',
                  builder:
                      (context, state) => ChangeNotifierProvider.value(
                        value: state.extra as ChartViewModel,
                        child: AvgCumulativeBalanceDetailScreen(),
                      ),
                ),
                GoRoute(
                  path: '/balance-compare',
                  builder:
                      (context, state) => ChangeNotifierProvider.value(
                        value: state.extra as ChartViewModel,
                        child: ChartMtdCompareScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder:
                  (context, state) => ChangeNotifierProvider(
                    create: (context) {
                      return GoalViewModel(
                        costItemRepo: context.read(),
                        goalRepo: context.read(),
                        sharedElementRepo: context.read(),
                      );
                    },
                    child: const GoalScreen(),
                  ),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigator,
                  path: '/goal-amount',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => GoalFormViewModel(
                              categoryRepo: context.read(),
                              goalRepo: context.read(),
                              goalCategory: state.extra as GoalCategory?,
                              initGoal: null,
                            ),
                        child: const GoalFormAmountPage(),
                      ),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigator,
                  path: '/new-goal-detail',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => GoalFormViewModel(
                              categoryRepo: context.read(),
                              goalRepo: context.read(),
                              goalCategory: state.extra as GoalCategory?,
                              initGoal: null,
                            ),
                        child: const GoalFormInfoScreen(),
                      ),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigator,
                  path: '/category',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => CategorySelectionViewModel(
                              categoryRepo: context.read(),
                              initSelection: state.extra as List<CostItemCategory>?,
                            ),
                        child: const CategorySelectionScreen(),
                      ),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigator,
                  path: '/text-filter',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => TextSelectionViewmodel(
                              itemRepo: context.read(),
                              categoryRepo: context.read(),
                              initFilter: state.extra as StringFilter?,
                            ),
                        child: const TextSelectionBody(),
                      ),
                ),
                GoRoute(
                  parentNavigatorKey: _rootNavigator,
                  path: '/edit-goal',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => GoalFormViewModel(
                              categoryRepo: context.read(),
                              goalRepo: context.read(),
                              goalCategory: null,
                              initGoal: state.extra as Goal,
                            ),
                        child: const GoalFormInfoScreen(),
                      ),
                ),
                GoRoute(
                  path: '/new-goal',
                  parentNavigatorKey: _rootNavigator,
                  builder:
                      (context, state) => GoalTypeSelectionScreen(),
                ),
                GoRoute(
                  // parentNavigatorKey: _rootNavigator,
                  path: '/details',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => GoalInfoViewModel(
                              goalRepos: context.read(),
                              costItemRepo: context.read(),
                              categoryRepo: context.read(),
                              currencyRepo: context.read(),
                              sharedElementRepo: context.read(),
                              goal: state.extra as Goal,
                            ),
                        child: const GoalDetailsScreen(),
                      ),
                ),
                GoRoute(
                  path: '/details-past',
                  builder: (context, state) {
                    return ChangeNotifierProvider.value(
                      value: state.extra as GoalInfoViewModel,
                      child: GoalPastDetailsScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreenWrapper(),
              routes: [
                GoRoute(
                  path: '/list',
                  builder: (context, state) => const ListDisplaySettingsScreen(),
                ),
                GoRoute(
                  path: '/global',
                  builder: (context, state) => const GlobalDisplaySettingsScreen(),
                ),
                GoRoute(
                  path: '/languages',
                  builder: (context, state) => const LanguageSettingsScreen(),
                ),
                GoRoute(
                  path: '/currencies',
                  builder:
                      (context, state) => const CurrencySelectionScreenWrapper(
                        currencyExchange: false,
                      ),
                ),
                GoRoute(
                  path: '/keyboard',
                  builder: (context, state) => const KeyboardSettingsScreen(),
                ),
                GoRoute(
                  path: '/currency-setting',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) =>
                                AdditionalCurrencySettingsViewModel(currencyRepo: context.read()),
                        child: const AdditionalCurrencySettingScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/form',
      parentNavigatorKey: _rootNavigator,
      routes: [
        GoRoute(
          path: '/currencies',
          builder:
              (context, state) => const CurrencySelectionScreenWrapper(
                currencyExchange: true,
              ),
        ),
        GoRoute(
          path: '/edit-category',
          builder:
              (context, state) => ChangeNotifierProvider(
                create:
                    (context) => CategoryFormViewModel(
                      initCategory: state.extra as CostItemCategory?,
                      categoryRepo: context.read(),
                      costItemRepo: context.read(),
                      currencyRepo: context.read(),
                    ),
                child: const CategoryFormScreen(),
              ),
          routes: [
            GoRoute(
              path: '/category-icon',
              builder: (context, state) {
                return const CategoryIconSelectionScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: '/exchange',
          builder:
              (context, state) => ChangeNotifierProvider(
                create:
                    (context) => ExRateViewModel(
                      currencyRepo: context.read(),
                      baseCurrency: (state.extra as Map)['base'],
                      targetCurrency: (state.extra as Map)['target'],
                    ),
                child: const CurrencyExchangeScreen(),
              ),
        ),
        GoRoute(
          path: '/edit-saved-item',
          parentNavigatorKey: _rootNavigator,
          // routes: [
          //   GoRoute(
          //     path: '/currencies',
          //     builder:
          //         (context, state) => const CurrencySelectionScreenWrapper(
          //           currencyExchange: true,
          //         ),
          //   ),
          // ],
          builder:
              (context, state) => ChangeNotifierProvider(
                create:
                    (_) => SavedItemViewModel(
                      initItem: (state.extra as Map?)?['initSavedItem'] as SavedItem?,
                      initCostData: (state.extra as Map?)?['initCostItem'] as CostItem?,
                      categoryRepo: context.read(),
                      savedItemRepo: context.read(),
                    ),
                child: const EditSavedItemScreen(),
              ),
        ),
      ],
      builder: (context, state) {
        final arg = state.extra as FormArgument?;
        return ChangeNotifierProvider(
          create:
              (context) => FormViewModel(
                sharedElRepo: context.read(),
                initCostItem: arg?.selectedCostItem,
                costItemRepo: context.read(),
                savedItemRepo: context.read(),
                categoryRepo: context.read(),
                currencyRepo: context.read(),
              ),
          child: CostFormScreen(arg: arg),
        );
      },
    ),
  ],
);
