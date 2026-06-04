import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/constants/categories.dart';
import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/enum.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:budget_tracker/models/currency_model.dart';
import 'package:budget_tracker/models/form_model.dart';
import 'package:budget_tracker/models/model.dart';
import 'package:budget_tracker/models/navigation_model.dart';
import 'package:budget_tracker/models/theme_model.dart';
import 'package:budget_tracker/screens/settings/budget_settings_screen.dart';
import 'package:budget_tracker/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// screen for user to input a new cost item
// or edit a existing cost item
class CostItemFormScreen extends StatelessWidget {
  const CostItemFormScreen({
    super.key,
    required this.arg,
  });
  final FormArgument arg;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FormModel(costItem: arg.selectedCostItem),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(arg.selectedCostItem == null ? "New item" : "Edit item"),
          leading: BackButton(
            onPressed: () {
              context.navMod.popFormToMain();
              // if (arg.oriRoute != null) {
              //   Navigator.of(context).pushNamed("/recurring");
              // }
            },
          ),
        ),
        bottomSheet: const FormSheet(),
        body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CostItemForm(
                  costItem: arg.selectedCostItem,
                  recurring: arg.oriRoute != null),
            )),
        // bottomNavigationBar: bottom,
      ),
    );
  }
}

class FormSheet extends StatefulWidget {
  const FormSheet({super.key});

  @override
  State<FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<FormSheet> {
  bool _isKeyboardOpen = false;
  bool _isFormExpanded = false;
  bool _isFormOpened = false;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;

  // CostItemFormResult saveResult() {
  // final double actualAmount = _amountController.text == ""
  //     ? 0
  //     : _amountController.text.parseCustomDecimalPlace(2);
  // return CostItemFormResult(
  //     name: _descController.text,
  //     date: _selectedDate,
  //     costType: _selectedCategory!.costType,
  //     category: _selectedCategory!.name,
  //     amount: actualAmount);
  // }

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _amountController = TextEditingController();
    _descController = TextEditingController();

    if (context.formMod.selectedCategory != null) {
      _selectedDate = context.formMod.date;
      _amountController.value = _amountController.value
          .copyWith(text: context.formMod.amount.toString());
      _descController.value =
          _descController.value.copyWith(text: context.formMod.itemDesc);
    }

    _amountController.addListener(() => context.formMod
        .updateAmount(double.tryParse(_amountController.text) ?? 0));
    _descController
        .addListener(() => context.formMod.updateDesc(_descController.text));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void selectDate() async {
    DateTime now = DateTime.now();
    final response = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      currentDate: _selectedDate,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5, now.month, 1),
      lastDate: DateTime(now.year + 5, now.month, 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
              datePickerTheme: DatePickerThemeData(
                  backgroundColor: context.cs.surface,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.cs.primary.withAlpha(50)),
                      borderRadius: BorderRadiusGeometry.circular(30)),
                  dayStyle: context.customTt.numberFontSmall,
                  weekdayStyle: context.customTt.numberFontSmall,
                  yearStyle: context.customTt.numberFontSmall,
                  toggleButtonTextStyle: context.customTt.numberFontSmall,
                  headerHeadlineStyle:
                      context.customTt.dateLabel!.copyWith(fontSize: 40))),
          child: child!,
        );
      },
    );
    if (response == null) return;
    setState(() {
      _selectedDate = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    CostItemCategory? selectedCategory = context.select((FormModel state) {
      if (state.selectedCategory != null) {
        Future.delayed(
            Duration(microseconds: 10),
            () => setState(() {
                  if (!_isFormOpened) {
                    _isFormOpened = true;
                    _isFormExpanded = true;
                  }
                }));
      }
      return state.selectedCategory;
    });
    String itemDesc = context.select((FormModel state) => state.itemDesc);
    double amount = context.select((FormModel state) => state.amount);

    if (selectedCategory == null) {
      return SizedBox.shrink();
    }

    return GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dy > 10) {
            // swipe down
            if (_isKeyboardOpen) {
              FocusManager.instance.primaryFocus
                  ?.unfocus(); //unfocus on screen keyboard
            } else {
              setState(() => _isFormExpanded = false);
            }
          }
          if (details.delta.dy < -10) {
            // swipe up
            setState(() => _isFormExpanded = true);
          }
        },
        child: AnimatedContainer(
          // padding: EdgeInsets.only(top: 20),
          duration: Durations.medium1,
          curve: Curves.easeInOutExpo,
          width: context.mq.size.width,
          height: !_isFormOpened
              ? 0
              : _isFormExpanded
                  ? 510
                  : 120,
          decoration: BoxDecoration(
              color: context.cs.primary,
              // border: BoxBorder.all(color: context.cs.primary.withAlpha(10)),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: Durations.medium1,
                curve: Curves.easeInOutExpo,
                height: _isFormExpanded ? 70 : 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    AnimatedScale(
                      scale: _isFormExpanded ? 0.7 : 1,
                      duration: Durations.medium1,
                      child: selectedCategory.createIcon(
                          40, ThemeMode.dark, context.cs.onPrimary),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              [
                                selectedCategory.name!.capitalize(),
                                ...[
                                  if (!_isFormExpanded)
                                    amount.customCurrencyFormat(
                                      "RM",
                                    ),
                                ]
                              ].join(' • '),
                              style: context.customTt.dateLabel!.copyWith(
                                  color: context.cs.onPrimary,
                                  fontSize: 30,
                                  height: 1.2)),
                          if (!_isFormExpanded)
                            Text(
                                [
                                  _selectedDate.formatPretty(),
                                  itemDesc.isEmpty ? "No Desc" : itemDesc
                                ].join(' • '),
                                style: context.customTt.numberFontSmall!
                                    .copyWith(
                                        color: context.cs.onPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight(200))),
                        ],
                      ),
                    ),
                    if (context.formMod.costItem != null)
                    IconButton(
                        onPressed: () { context.appMod.deleteCostItem(context.formMod.costItem!.uuid!);},
                        icon: Icon(
                          Icons.delete,
                          color: context.cs.error,
                        ))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: context.mq.size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(color: context.cs.surface),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("RM",
                                style: context.customTt.numberFontLarge!
                                    .copyWith(
                                        fontSize: 60,
                                        color: context.cs.primary)),
                            Expanded(
                              child: _amountController.text.isEmpty
                                  ? Text("0.00",
                                      textAlign: TextAlign.end,
                                      style: context.customTt.numberFontLarge!
                                          .copyWith(
                                              fontSize: 60,
                                              color: context.cs.primary
                                                  .withAlpha(100)))
                                  : Text(_amountController.text,
                                      textAlign: TextAlign.end,
                                      style: context.customTt.numberFontLarge!
                                          .copyWith(
                                              fontSize: 60,
                                              color: context.cs.primary)),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: context.cs.primary.withAlpha(50),
                      ),
                      TextFormField(
                        controller: _descController,
                        style: context.tt.bodyMedium!,
                        minLines: 3,
                        maxLines: 3,
                        decoration: InputDecoration(
                            visualDensity: VisualDensity(vertical: -4),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                            hintText: "Write your description here...",
                            hintStyle: context.tt.bodyMedium!.copyWith(
                                color: context.cs.primary.withAlpha(100)),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            border: InputBorder.none),
                      ),
                      Expanded(
                        child: CustomKeyboard(
                            controller: _amountController,
                            onDone: () {
                              final result = context.formMod.formResult;
                              debugPrint(result.toString());
                              if (result != null) {
                                if (context.formMod.costItem != null) {
                                  context.appMod.updateCostItem(
                                      result, context.formMod.costItem!.uuid!);
                                } else {
                                  context.appMod.createCostItem(result);
                                }
                                context.navMod.popFormToMain();
                              }
                            },
                            selectedDate: _selectedDate,
                            onDateTapped: selectDate),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class CostItemForm extends StatefulWidget {
  const CostItemForm({super.key, this.recurring = false, this.costItem});

  final CostItem? costItem;
  final bool recurring;
  @override
  State<CostItemForm> createState() => _CostItemFormState();
}

class _CostItemFormState extends State<CostItemForm> {
  final _formKey = GlobalKey<FormState>();

  // earlist selectable date is 2000
  final DateTime _earliestDate = DateTime(DateTime.now().year - 5, 1, 1);

  // last selectable date is 5 years from now
  final DateTime _latestDate = DateTime(DateTime.now().year + 5, 12, 31);

  // DateTime _selectedDate =
  //     DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // final _nameController = TextEditingController();
  // final _amountController = TextEditingController();
  // final _dateController =
  //     TextEditingController(text: DateFormat('dd MMM').format(DateTime.now()));

  // // bool _isEditted = false; // use to determine if alert should be shown when user discards current entry

  // CostItemCategory? _selectedCategory;

  // double _bottomSheetHeight = 0;
  // bool _isKeyboardOpen = false;
  // bool _isFormExpanded = true;

  late FocusNode textFocusNode;

  String? _imageString;
  final double _messageOpacity = 0;

  // Widget titleLabel(String labelText, IconData icon, ColorScheme colorScheme) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //     child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         spacing: 8,
  //         children: [
  //           Icon(
  //             icon,
  //             size: 20,
  //             color: colorScheme.onPrimaryContainer,
  //           ),
  //           Text(
  //             labelText,
  //             style: Theme.of(context)
  //                 .textTheme
  //                 .labelMedium!
  //                 .copyWith(color: colorScheme.onPrimaryContainer),
  //           ),
  //           SizedBox(
  //             width: 50,
  //           ),
  //           if (labelText == "Amount")
  //             Icon(Icons.settings,
  //                 size: 20, color: colorScheme.onPrimaryContainer),
  //         ]),
  //   );
  // }

  // InputDecoration customInputDecoration() {
  //   return InputDecoration(
  //       border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(0),
  //           borderSide: BorderSide.none),
  //       filled: true,
  //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       fillColor: Theme.of(context).colorScheme.surfaceDim);
  // }

  // void changeDate(DateTime date) {
  //   setState(() {
  //     _selectedDate = date;
  //   });
  //   _dateController.value =
  //       _dateController.value.copyWith(text: DateFormat('dd MMM').format(date));
  // }

  // void updateCategory(CostItemCategory category) {
  //   setState(() {
  //     _selectedCategory = category;
  //     _isFormExpanded = true;
  //   });

  //   textFocusNode.requestFocus(); // focus on text field
  // }

  @override
  void initState() {
    super.initState();

    textFocusNode = FocusNode();

    // update controller value when user edits the budget
    // final costItem = widget.costItem;
    // if (costItem != null) {
    //   final categories = context.read<AppModel>().categories;
    //   _nameController.value =
    //       _nameController.value.copyWith(text: costItem.name);
    //   _amountController.value = _amountController.value
    //       .copyWith(text: costItem.getCurrencyValue('', false));
    //   _selectedDate = costItem.date;
    //   _selectedCategory = categories[categories
    //       .indexWhere((category) => category.name == costItem.category)];
    //   _dateController.value = _dateController.value
    //       .copyWith(text: DateFormat('dd MMM').format(_selectedDate));
    //   _isFormExpanded = true;
    // } else {}
  }

  Flushbar<dynamic> saveErrorFlushbar(String message) {
    return Flushbar(
      title: "Cannot save current entry",
      message: message,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      // isDismissible: true,
      duration: Duration(seconds: 4),
      animationDuration: Durations.long1,
      backgroundColor: Colors.orange.shade900,
    );
  }

  OverlayEntry warningOverlay() {
    return OverlayEntry(
      builder: (context) {
        return AnimatedOpacity(
          duration: Durations.extralong4,
          opacity: _messageOpacity,
          // opacity: 0,
          child: Center(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 50,
                  width: 200,
                  alignment: Alignment.center,
                  child: Text("Input a amount to save"),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const CostItemCategoryGrid();
  }

  // Widget detailsBottomSheet() {
  //   final appState = context.watch<AppModel>();
  //   final selectedThemeMode = context.select((ThemeModel state) => state.theme);
  //   final currentTextTheme = Theme.of(context).textTheme;
  //   final CostItemCategory localCategory;

  //   if (_selectedCategory != null) {
  //     localCategory = _selectedCategory!;
  //   } else {
  //     localCategory = CostItemCategory(
  //         // placeholder
  //         name: "Placeholder",
  //         color: Colors.brown,
  //         imagePath: "assets/images/placeholder.png",
  //         costType: CostType.expense);
  //   }

  //   final categoryColorScheme = localCategory.colorScheme;

  //   final Widget? subtitle;

  //   if (_isFormExpanded) {
  //     subtitle = null;
  //   } else {
  //     final amount =
  //         '| ${appState.currencySymbol} ${_amountController.text == "" ? "0" : _amountController.text}';
  //     final description =
  //         _nameController.text == "" ? '' : '| ${_nameController.text}';
  //     subtitle = Text(
  //       '${_dateController.text} $amount $description',
  //       maxLines: 3,
  //       overflow: TextOverflow.ellipsis,
  //       style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12),
  //     );
  //   }

  // return Theme(
  //   data: Theme.of(context).copyWith(
  //       colorScheme: categoryColorScheme(selectedThemeMode),
  //       textSelectionTheme: TextSelectionThemeData(
  //           cursorColor:
  //               categoryColorScheme(selectedThemeMode).onPrimaryContainer),
  //       inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
  //             fillColor: Colors.amber,
  //             filled: true,
  //           )),
  //   child: Container(
  //     color: categoryColorScheme(selectedThemeMode).surface,
  //     child: GestureDetector(
  //       onPanUpdate: (details) {
  //         if (details.delta.dy > 10) {
  //           if (_isKeyboardOpen) {
  //             FocusManager.instance.primaryFocus
  //                 ?.unfocus(); //unfocus on screen keyboard
  //           } else {
  //             setState(() => _isFormExpanded = false);
  //           }
  //         }
  //         if (details.delta.dy < -10) {
  //           setState(() => _isFormExpanded = true);
  //         }
  //       },
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Material(
  //             child: GestureDetector(
  //               behavior: HitTestBehavior.opaque,
  //               onTap: () {
  //                 setState(() => _isFormExpanded = !_isFormExpanded);
  //               },
  //               child: AnimatedContainer(
  //                 duration: Durations.medium1,
  //                 curve: Curves.fastOutSlowIn,
  //                 height: _bottomSheetHeight == 120 ? 120 : 60,
  //                 decoration: BoxDecoration(
  //                     color: categoryColorScheme(selectedThemeMode)
  //                         .primaryContainer
  //                         .withAlpha(200),
  //                     borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(12),
  //                         topRight: Radius.circular(12))),
  //                 alignment: Alignment.center,
  //                 child: ListTile(
  //                   shape: RoundedRectangleBorder(
  //                       side: BorderSide(width: 0),
  //                       borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(12),
  //                           topRight: Radius.circular(12))),
  //                   contentPadding:
  //                       EdgeInsets.only(left: 16, top: 4, bottom: 4),
  //                   title: Text(
  //                     localCategory.name,
  //                     style: Theme.of(context)
  //                         .textTheme
  //                         .headlineMedium!
  //                         .copyWith(fontSize: 24),
  //                   ),
  //                   leading: localCategory.createIcon(
  //                       _isFormExpanded ? 24 : 34, selectedThemeMode),
  //                   subtitle: subtitle,
  //                   trailing: actionIcons(
  //                       appState, categoryColorScheme(selectedThemeMode)),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Column(
  //             spacing: 0,
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               TextFormField(
  //                 readOnly: true,
  //                 // focusNode: textFocusNode,
  //                 textInputAction: TextInputAction.next,
  //                 controller: _amountController,
  //                 keyboardType: TextInputType.numberWithOptions(),
  //                 decoration: customInputDecoration().copyWith(
  //                     contentPadding:
  //                         EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                     // prefixIcon: Text(appState.currencySymbol, style: currentTextTheme.headlineLarge),
  //                     prefixIcon: Padding(
  //                       padding: const EdgeInsets.only(left: 16.0),
  //                       child: Text(appState.currencySymbol,
  //                           style: Theme.of(context).textTheme.displayMedium),
  //                     ),
  //                     // prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
  //                     hintText: "0",
  //                     isDense: true,
  //                     fillColor:
  //                         categoryColorScheme(selectedThemeMode).surface,
  //                     filled: true
  //                     // hintStyle: currentTextTheme.headlineLarge!.copyWith(
  //                     //   color: categoryColorScheme.onPrimaryContainer.withAlpha(150)
  //                     // ),
  //                     ),
  //                 style: currentTextTheme.displayMedium,
  //                 textAlign: TextAlign.right,
  //                 inputFormatters: [
  //                   // only allow number
  //                   FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
  //                 ],
  //                 // validator: (value) {
  //                 //   if (value == "") {
  //                 //     return "This must be more than 0";
  //                 //   } else {
  //                 //     return null;
  //                 //   }
  //                 // },
  //               ),
  //               // Divider(),
  //               TextFormField(
  //                 controller: _nameController,
  //                 textInputAction: TextInputAction.done,
  //                 decoration: customInputDecoration().copyWith(
  //                     fillColor:
  //                         categoryColorScheme(selectedThemeMode).surface,
  //                     filled: true,
  //                     hintText: "Add a note/description for the item..",
  //                     hintStyle: currentTextTheme.titleLarge!.copyWith(
  //                         fontSize: 14,
  //                         color: Theme.of(context)
  //                             .colorScheme
  //                             .onSurface
  //                             .withAlpha(100))),
  //                 minLines: 2,
  //                 maxLines: 2,
  //                 style: currentTextTheme.titleLarge!.copyWith(
  //                     fontSize: 14,
  //                     height: 1.7,
  //                     color:
  //                         categoryColorScheme(selectedThemeMode).onSurface),
  //               ),
  //             ],
  //           ),
  //           if (appState.notes(_selectedCategory?.name).isNotEmpty)
  //             SizedBox(
  //               height: 40,
  //               child: SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
  //                 child: Row(
  //                   spacing: 8,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: appState
  //                       .notes(_selectedCategory?.name)
  //                       .map((note) => FilterChip(
  //                           label: Text(note.note),
  //                           onSelected: (bool isSelected) {
  //                             if (isSelected) {
  //                               _nameController.clear();
  //                               _nameController.value = _nameController.value
  //                                   .copyWith(text: note.note);
  //                             }
  //                           }))
  //                       .toList(),
  //                 ),
  //               ),
  //             ),
  //           Expanded(
  //             child: Padding(
  //                 padding: const EdgeInsets.all(12.0),
  //                 child: CustomKeyboard(
  //                     controller: _amountController,
  //                     // onDone: () => saveResultAndPop(context),
  //                     onDone: () => {},
  //                     selectedDate: _selectedDate,
  //                     onDateTapped: () async {
  //                       final response = await pickDate(
  //                           context, categoryColorScheme(selectedThemeMode));
  //                       if (response == null) return;
  //                       setState(() {
  //                         _selectedDate = response;
  //                       });
  //                     })),
  //           )
  //         ],
  //       ),
  //     ),
  //   ),
  // );
  // }

  Future deleteDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete this item?"),
          content: Text("Warning: You cannot undo this action."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel")),
            TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  // iconColor: Theme.of(context).colorScheme.onError
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Delete",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.redAccent),
                )),
          ],
        );
      },
    );
  }

  Future currencyExchangeDialog() async {
    final dropdownMenuWidth = MediaQuery.of(context).size.width * 0.64;
    final textFieldBg = Colors.black.withAlpha(100);
    final textFieldDisabledBg = Colors.white.withAlpha(20);

    List<Widget> labelTitle(String title, {bool useSpacing = true}) => [
          useSpacing
              ? SizedBox(
                  height: 20,
                )
              : SizedBox.shrink(),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(
            height: 8,
          )
        ];

    List<Widget> customDivider = [
      Divider(),
      SizedBox(
        height: 8,
      ),
    ];

    TextEditingController _amountController = TextEditingController(text: "0");
    TextEditingController _rateController = TextEditingController(text: "0");
    TextEditingController _convertedAmountController =
        TextEditingController(text: "");
    String _currentCurrency = "MYR";
    String _exchangedCurrency = "";
    ExchangeRateType _currentExchangeType = ExchangeRateType.current;
    double _currentExchangeRate = 1;

    Future<String> sendRequest(BuildContext context) async {
      await context.read<CurrencyModel>().getCurrencyList();
      await context.read<CurrencyModel>().getExchangeRate();
      return "data loaded";
    }

    final Future<String> initRequest = sendRequest(context);

    return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
            future: initRequest,
            builder: (context, asyncSnapshot) {
              return StatefulBuilder(builder: (context, setState) {
                final Map<String, dynamic> currencies =
                    context.select((CurrencyModel state) => state.currencies);
                final Map<String, dynamic> exchange =
                    context.select((CurrencyModel state) => state.rates);
                _convertedAmountController.text =
                    (double.parse(_amountController.text) /
                            double.parse(_rateController.text))
                        .toStringAsFixed(2);
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                          // constraints: BoxConstraints(maxWidth: dropdownMenuWidth, maxHeight:  dropdownMenuWidth),
                          ),
                    ),
                  );
                } else {
                  return AlertDialog(
                    title: const Text("Convert currencies"),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...labelTitle('Exchange Rate', useSpacing: false),
                        Row(
                          children: [
                            Radio(
                                visualDensity: VisualDensity(horizontal: -2),
                                value: ExchangeRateType.current,
                                groupValue: _currentExchangeType,
                                onChanged: (value) {
                                  setState(() => _currentExchangeType = value!);
                                }),
                            Text(ExchangeRateType.current.name),
                            SizedBox(
                              width: 10,
                            ),
                            Radio(
                                visualDensity: VisualDensity(horizontal: -2),
                                value: ExchangeRateType.custom,
                                groupValue: _currentExchangeType,
                                onChanged: (value) {
                                  setState(() => _currentExchangeType = value!);
                                }),
                            Text(ExchangeRateType.custom.name)
                          ],
                        ),
                        ...customDivider,
                        ...labelTitle('Convert from', useSpacing: false),
                        Row(
                          spacing: 8,
                          children: [
                            SizedBox(
                              width: dropdownMenuWidth,
                              child: DropdownMenu(
                                enableSearch: true,
                                enableFilter: true,
                                inputDecorationTheme: InputDecorationTheme(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide.none),
                                  fillColor: textFieldBg,
                                  filled: true,
                                ),
                                textStyle:
                                    Theme.of(context).textTheme.titleMedium,
                                width: dropdownMenuWidth,
                                menuHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                                dropdownMenuEntries: currencies
                                    .map((key, value) => MapEntry(
                                        key,
                                        DropdownMenuEntry(
                                            value: key,
                                            label: value,
                                            trailingIcon: Text(key))))
                                    .values
                                    .toList(),
                                onSelected: (value) {
                                  debugPrint("Selected value: $value");
                                  setState(() {
                                    _exchangedCurrency = value ?? "";
                                    _currentExchangeRate =
                                        (exchange[_exchangedCurrency]
                                                as double) /
                                            (exchange[_currentCurrency]
                                                as double);
                                    _rateController.text =
                                        _currentExchangeRate.toStringAsFixed(2);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        ...labelTitle('Amount'),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            prefix: Text(_exchangedCurrency),
                            hintText: "0",
                            fillColor: textFieldBg,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(100),
                              // borderSide: BorderSide.none
                            ),
                          ),
                        ),
                        ...customDivider,
                        ...labelTitle('Rate', useSpacing: false),
                        TextField(
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          readOnly:
                              _currentExchangeType == ExchangeRateType.custom
                                  ? false
                                  : true,
                          enabled:
                              _currentExchangeType == ExchangeRateType.custom
                                  ? true
                                  : false,
                          decoration: InputDecoration(
                            fillColor:
                                _currentExchangeType == ExchangeRateType.custom
                                    ? textFieldBg
                                    : textFieldDisabledBg,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        ...labelTitle('Converted Amount'),
                        TextField(
                          controller: _convertedAmountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "0",
                            prefix: Text(_currentCurrency),
                            fillColor: textFieldDisabledBg,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide.none),
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () {}, child: Text("Confirm"))
                    ],
                  );
                }
              });
            });
      },
    );
  }
}

class CostItemCategoryGrid extends StatefulWidget {
  const CostItemCategoryGrid({
    super.key,
  });

  @override
  State<CostItemCategoryGrid> createState() => _CostItemCategoryGridState();
}

class _CostItemCategoryGridState extends State<CostItemCategoryGrid> {
  String? _selectedCatId;
  // String? _selectedCatName;
  CostType _selectedCostType = CostType.expense;
  List<CostItemCategory> _filteredCostItemCategories = [];

  final gridSettings = {
    3: {
      "mainSpacing": 8.0,
      "crossSpacing": 12.0,
      "iconPadding": 20.0,
    },
    4: {
      "mainSpacing": 12.0,
      "crossSpacing": 12.0,
      "iconPadding": 20.0,
    },
    5: {
      "mainSpacing": 4.0,
      "crossSpacing": 4.0,
      "iconPadding": 16.0,
    },
  };

  @override
  void initState() {
    super.initState();

    if (context.formMod.selectedCategory != null) {
      _selectedCostType = context.formMod.type;
      _selectedCatId = context.formMod.selectedCategory!.id!;
    }

    _filteredCostItemCategories = defaultCostItemCategories
        .where((category) => category.costType == _selectedCostType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = context.mq.size;
    final selectedThemeMode = context.themeMod.theme;
    final gridSize = context.select((ThemeModel state) => state.gridSize);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: screenSize.width,
          child: SegmentedButton(
            style: SegmentedButton.styleFrom(
                selectedBackgroundColor: context.customCs.flipCardColor,
                selectedForegroundColor: context.customCs.onFlipCard,
                side: BorderSide(color: context.cs.primary.withAlpha(100)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12))),
            segments: CostType.values.map((costType) {
              return ButtonSegment(
                  value: costType,
                  icon: Icon(costType == CostType.expense
                      ? Icons.attach_money_rounded
                      : Icons.input_sharp),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      costType.name.capitalize(),
                      style: context.customTt.dateLabel!.copyWith(
                          color: _selectedCostType == costType
                              ? context.customCs.onFlipCard
                              : context.cs.primary),
                    ),
                  ));
            }).toList(),
            selected: {_selectedCostType},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedCostType = newSelection.first;
                _filteredCostItemCategories = defaultCostItemCategories
                    .where((category) => category.costType == _selectedCostType)
                    .toList();
              });
            },
          ),
        ),
        Expanded(
          child: CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 120),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4),
                itemCount: _filteredCostItemCategories.length,
                itemBuilder: (context, index) {
                  final CostItemCategory category =
                      _filteredCostItemCategories.elementAt(index);
                  final catId = category.id;
                  final isSelected = catId == _selectedCatId;
                  // final ColorScheme colorScheme =
                  //     category.colorScheme(ThemeMode.dark);

                  final bgColor =
                      context.cs.primary.withAlpha(isSelected ? 250 : 5);
                  // final bgColor = index == _selectedItem ? colorScheme.primary : null;
                  final fgColor =
                      isSelected ? context.cs.onPrimary : context.cs.primary;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCatId = catId);
                      context.formMod.selectNewCategory(category);
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1,
                      duration: Durations.short3,
                      curve: Curves.easeInOut,
                      child: Column(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: Durations.medium1,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                              border: BoxBorder.all(
                                  color: context.cs.primary.withAlpha(50)),
                              color: bgColor,
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(16),
                                child: category.createIcon(
                                    30, selectedThemeMode, fgColor)),
                          ),
                          Text(
                            category.name!.capitalize(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
