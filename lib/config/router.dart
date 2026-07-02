import 'package:budget_tracker/config/router_component.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/classes/class.dart';
import 'package:budget_tracker/custom/classes/goal_category.dart';
import 'package:budget_tracker/custom/classes/goal_class.dart';
import 'package:budget_tracker/reusable/category_selection_screen.dart';
import 'package:budget_tracker/reusable/category_selection_viewmodel.dart';
// import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/screens/settings/currency_screen.dart';
import 'package:budget_tracker/screens/settings/ex_rate_screen.dart';
import 'package:budget_tracker/screens/settings/ex_rate_viewmodel.dart';
import 'package:budget_tracker/ui/category_form/category_form_screen.dart';
import 'package:budget_tracker/ui/category_form/category_form_viewmodel.dart';
import 'package:budget_tracker/ui/category_form/category_icon_selection_screen.dart';
import 'package:budget_tracker/ui/chart/chart_screen.dart';
import 'package:budget_tracker/ui/form/form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_screen.dart';
import 'package:budget_tracker/ui/goal/goal_form_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_info_screen.dart';
import 'package:budget_tracker/ui/goal/goal_info_viewmodel.dart';
import 'package:budget_tracker/ui/goal/goal_list_screen.dart';
import 'package:budget_tracker/ui/list/main_list_screen.dart';
import 'package:budget_tracker/ui/list/main_list_viewmodel.dart';
import 'package:budget_tracker/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final _rootNavigator = GlobalKey<NavigatorState>();
final _navigatorA = GlobalKey<NavigatorState>();
final _navigatorB = GlobalKey<NavigatorState>();
final _navigatorC = GlobalKey<NavigatorState>();
final _navigatorD = GlobalKey<NavigatorState>();

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
                  child: const CostListScreenWrapper(
                    // key: state.extra != null ? ValueKey(state.extra) : ValueKey('home-root'),
                  ),
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
              builder: (context, state) => const ChartScreenWrapper(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalScreenWrapper(),
              routes: [
                GoRoute(
                  path: '/form',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => GoalFormViewmodel(
                              categoryRepo: context.read(),
                              goalRepository: context.read(),
                              goalCategory: state.extra as GoalCategory,
                            ),
                        child: const GoalFormInfoScreen(),
                      ),
                ),
                GoRoute(
                  path: '/new-goal',
                  parentNavigatorKey: _rootNavigator,
                  builder: (context, state) => const GoalTypeSelectionScreenState(),
                ),
                GoRoute(
                  path: '/details',
                  builder:
                      (context, state) => ChangeNotifierProvider(
                        create:
                            (context) => GoalInfoViewmodel(
                              goalRepos: context.read(),
                              costItemRepo: context.read(),
                              categoryRepo: context.read(),
                              goal: state.extra as Goal,
                            ),
                        child: const GoalDetailsScreen(),
                      ),
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
                  path: '/currencies',
                  builder:
                      (context, state) => const CurrencySelectionScreenWrapper(
                        currencyExchange: false,
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
                      currencyRepo: context.read()
                    ),
                child: const CategoryFormScreen(),
              ),
          routes: [
            GoRoute(path: '/category-icon', builder: (context, state) {
              return const CategoryIconSelectionScreen();
            },)
          ]
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
              (context, state) => CostFormScreenWrapper(
                arg: state.extra as FormArgument?,
              ),
        ),
      ],
      builder: (context, state) {
        // debugPrint('trigger build form');
        return CostFormScreenWrapper(
          arg: state.extra as FormArgument?,
        );
      },
    ),
  ],
);
