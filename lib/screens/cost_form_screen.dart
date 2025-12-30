import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:budget_tracker/extensions.dart';
import 'package:budget_tracker/models/currency_model.dart';
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
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(arg.isNew ? 
          // AppLocalizations.of(context)!.newFormTitle :
          // AppLocalizations.of(context)!.editFormTitle
          "New item":
          "Edit item"
        ) ,
        leading: BackButton(
          onPressed: () {
            context.read<NavigationModel>().popFormToMain();
            if (arg.oriRoute != null) {
              Navigator.of(context).pushNamed("/recurring");
            }
          },
        ),

      ),
      body: SafeArea(
        bottom: false,
        // maintainBottomViewPadding: true,
        child: Padding(
          // padding: const EdgeInsets.all(20.0),
          padding: const EdgeInsets.all(0.0),
          child: CostItemForm(
            costItem: arg.selectedCostItem, 
            recurring: arg.oriRoute != null
          ),
        )
      ),
      // bottomNavigationBar: bottom,
    );
  }

  
}

class CostItemForm extends StatefulWidget {
  const CostItemForm({
    super.key,
    this.recurring = false,
    this.costItem
  });

  final CostItem? costItem;
  final bool recurring;
  @override
  State<CostItemForm> createState() => _CostItemFormState();
}

class _CostItemFormState extends State<CostItemForm> {
  final _formKey = GlobalKey<FormState>(); 

  // earlist selectable date is 2000
  final DateTime _earliestDate = DateTime(2000, 1, 1);

  // last selectable date is 5 years from now
  final DateTime _latestDate = DateTime(DateTime.now().year + 5, 12, 31);

  DateTime _selectedDate = DateTime.now();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(text: DateFormat('dd MMM').format(DateTime.now()));

  // bool _isEditted = false; // use to determine if alert should be shown when user discards current entry

  CostItemCategory? _selectedCategory;
  
  double _bottomSheetHeight = 0;
  bool _isKeyboardOpen = false;
  bool _isFormExpanded = true;

  late FocusNode textFocusNode;

  String? _imageString;
  final double _messageOpacity = 0;

  Widget titleLabel(String labelText, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          Icon(icon, size: 20, color: colorScheme.onPrimaryContainer,),
          Text(labelText, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: colorScheme.onPrimaryContainer),),
          SizedBox(width: 50,),
          if (labelText == "Amount") 
            Icon(Icons.settings, size: 20, color: colorScheme.onPrimaryContainer),
        ]
      ),
    );
  }

  InputDecoration customInputDecoration()  {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(0), borderSide: BorderSide.none),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      fillColor: Theme.of(context).colorScheme.surfaceDim

    );
  }

  void changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _dateController.value = _dateController.value.copyWith(
      text: DateFormat('dd MMM').format(date)
    );
  }
  
  void updateCategory(CostItemCategory category) {
    setState(() {
      _selectedCategory = category;
      _isFormExpanded = true;
    });

    textFocusNode.requestFocus(); // focus on text field
  }

  @override
  void initState() {
    super.initState();

    textFocusNode = FocusNode();

    // update controller value when user edits the budget
    final costItem = widget.costItem;
    if (costItem != null) {
      final categories = context.read<AppModel>().categories;
      _nameController.value = _nameController.value.copyWith(text:costItem.name);
      _amountController.value = _amountController.value.copyWith(text:costItem.getCurrencyValue('',false));
      _selectedDate = DateFormat('yyyy-MM-dd').parse(costItem.date);
      _selectedCategory = categories[categories.indexWhere((category) => category.name == costItem.category)];
      _dateController.value = _dateController.value.copyWith(
        text: DateFormat('dd MMM').format(_selectedDate)
      );
      _isFormExpanded = true;
    } else {

    }
  }

  CostItemFormResult saveResult() {
    final double actualAmount = _amountController.text == "" ? 
      0 : _amountController.text.parseCustomDecimalPlace(2);
    return CostItemFormResult(
      name: _nameController.text,
      date: _selectedDate.standardFormat(),
      costType: _selectedCategory!.costType,
      category: _selectedCategory!.name,
      amount: actualAmount
    );
  }


  void saveResultAndPop(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final result = saveResult();
      if (widget.recurring) {
        context.read<AppModel>().saveTempRecCostFromForm(result);        
        context.read<NavigationModel>().popFormToMain();
        Navigator.of(context).pushNamed("/recurring");
      } else {
        if (widget.costItem != null) {
          context.read<AppModel>().updateCostItem(result,widget.costItem!.uuid!);
        } else {
          context.read<AppModel>().createNewCostItem(result);
        }
        context.read<NavigationModel>().popFormToMain();
      } 
    }
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
      builder:(context) {
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
    final screenSize = MediaQuery.sizeOf(context);
    final bottomKeyboard = MediaQuery.viewInsetsOf(context).bottom;

    if (bottomKeyboard > 0) {
      debugPrint("keyboard: $bottomKeyboard");
      debugPrint("size: $screenSize");
      setState(() {
        _isKeyboardOpen = true;
      });
    } else {
      if (_isKeyboardOpen) {
        setState(() {
          _isKeyboardOpen = false;
        });
      }
    }
    if (_selectedCategory == null) {
      _bottomSheetHeight = 0;
    } else if (_isFormExpanded && _isKeyboardOpen) {
      _bottomSheetHeight = 580;
      if (context.select((AppModel state) => state.notes(_selectedCategory?.name).isEmpty)) {
        _bottomSheetHeight -= 40;
      }
    } else if (_isFormExpanded) {
      _bottomSheetHeight = 520;
      if (context.select((AppModel state) => state.notes(_selectedCategory?.name).isEmpty)) {
        _bottomSheetHeight -= 40;
      }
    } else {
      _bottomSheetHeight = 120;
    }
    // debugPrint("height: ${(screenSize.height * _bottomSheetHeight)}");
    return Form(
      key: _formKey,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            child: CostItemCategoryGrid(
              onCategorySelected: updateCategory, 
              selectedCategory: _selectedCategory
            ),
          ),
          AnimatedPositioned(
            height: _bottomSheetHeight,
            width: screenSize.width,
            duration: Durations.medium3,
            curve: Curves.fastOutSlowIn,
            child: detailsBottomSheet()
          )
        ],
      ),
    );
  }

  Widget detailsBottomSheet() {
    final appState = context.watch<AppModel>();
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    final currentTextTheme = Theme.of(context).textTheme;
    final CostItemCategory localCategory;

    if (_selectedCategory != null) {
      localCategory = _selectedCategory!;
    } else {
      localCategory = CostItemCategory( // placeholder
        name: "Placeholder", 
        color: Colors.brown, 
        imagePath: "assets/images/placeholder.png",
        costType: CostType.expense
      ); 
    }

    final categoryColorScheme = localCategory.colorScheme;

    final Widget? subtitle;

    if (_isFormExpanded) {
      subtitle =  null;
    } else {
      final amount = '| ${appState.currencySymbol} ${_amountController.text == "" ? "0" : _amountController.text}';
      final description = _nameController.text == "" ? '' : '| ${_nameController.text}';
      subtitle = Text(
        '${_dateController.text} $amount $description',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 12),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: categoryColorScheme(selectedThemeMode),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: categoryColorScheme(selectedThemeMode).onPrimaryContainer
        ),
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          fillColor: Colors.amber,
          filled: true,
        )
      ),
      child: Container(
        color: categoryColorScheme(selectedThemeMode).surface,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dy > 10) {
              if (_isKeyboardOpen) {
                FocusManager.instance.primaryFocus?.unfocus(); //unfocus on screen keyboard
              } else {
                setState(() => _isFormExpanded = false);
              }
            }
            if (details.delta.dy < -10) {
              setState(() => _isFormExpanded = true);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _isFormExpanded = !_isFormExpanded);
                  },
                  child: AnimatedContainer(
                    duration: Durations.medium1,
                    curve: Curves.fastOutSlowIn,
                    height: _bottomSheetHeight == 120 ? 120 : 60 ,
                    decoration: BoxDecoration(
                      color: categoryColorScheme(selectedThemeMode).primaryContainer.withAlpha(200),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12), 
                          topRight: Radius.circular(12)
                      )
                    ),
                    alignment: Alignment.center,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12), 
                          topRight: Radius.circular(12)
                        )
                      ),
                      contentPadding: EdgeInsets.only(left: 16, top: 4, bottom: 4),
                      title: Text(
                        localCategory.name,
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 24),
                      ),
                      leading: localCategory.createIcon(_isFormExpanded? 24: 34,selectedThemeMode),
                      subtitle: subtitle,
                      trailing: actionIcons(appState, categoryColorScheme(selectedThemeMode)),
                    ),
                  ),
                ),
              ),
              Column(
                spacing: 0,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    readOnly: true,
                    // focusNode: textFocusNode,
                    textInputAction: TextInputAction.next,
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: customInputDecoration().copyWith(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // prefixIcon: Text(appState.currencySymbol, style: currentTextTheme.headlineLarge),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(appState.currencySymbol, style: Theme.of(context).textTheme.displayMedium),
                      ),
                      // prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: "0",
                      isDense: true,
                      fillColor: categoryColorScheme(selectedThemeMode).surface,
                      filled: true
                      // hintStyle: currentTextTheme.headlineLarge!.copyWith(
                      //   color: categoryColorScheme.onPrimaryContainer.withAlpha(150) 
                      // ),
                    ),
                    style: currentTextTheme.displayMedium,
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      // only allow number
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                    ],
                    // validator: (value) {
                    //   if (value == "") {
                    //     return "This must be more than 0";
                    //   } else {
                    //     return null;
                    //   }
                    // },
                  ),
                  Divider(),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: customInputDecoration().copyWith(
                      fillColor: categoryColorScheme(selectedThemeMode).surface,
                      filled: true,
                      hintText: "Add a note/description for the item..",
                      hintStyle: currentTextTheme.titleLarge!.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(100)
                      )
                    ),
                    minLines: 2,
                    maxLines: 2,
                    style: currentTextTheme.titleLarge!.copyWith(
                      fontSize: 14,
                      height: 1.7,
                      color: categoryColorScheme(selectedThemeMode).onSurface
                    ),
                  ),
                ],
              ),
              if (appState.notes(_selectedCategory?.name).isNotEmpty) 
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: appState.notes(_selectedCategory?.name).map((note) =>
                      FilterChip(
                        label: Text(note.note), 
                        onSelected: (bool isSelected) {
                          if (isSelected) {
                            _nameController.clear();
                            _nameController.value = _nameController.value.copyWith(
                              text: note.note
                            );
                          }
                        }
                      )
                    ).toList(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CustomKeyboard(
                    controller: _amountController, 
                    onDone:() => saveResultAndPop(context),
                    selectedDate: _selectedDate,
                    onDateTapped: () async {
                      final response = await pickDate(context,categoryColorScheme(selectedThemeMode));
                      if (response == null) return;
                      setState(() {
                        _selectedDate = response;
                      });
                    } 
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row actionIcons(AppModel appState, ColorScheme categoryColorScheme) {
    return Row(
      spacing: 0,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.costItem != null) 
        IconButton(
          iconSize: 24,
          onPressed: () async {
            final bool? response = await deleteDialog();

            if (response != null && response) { // deleting item
              appState.deleteCostItem(widget.costItem!.uuid!);
              if (!context.mounted) {
                return;
              } else {
                // ignore: use_build_context_synchronously
                context.read<NavigationModel>().popFormToMain();
              }
            }
          },
          icon: Icon(Icons.delete, color: Colors.red)
        ),
        // if (widget.costItem == null)  // show camera if form is new
        IconButton(
          iconSize: 24,
          onPressed: () async {
            // pick file if no file selected currently
            if (_imageString == null) {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: false,
                allowedExtensions: ['jpg','jpeg','gif','png',]
              );
              if (result == null) return;
              
              Uint8List? compressResult = await FlutterImageCompress.compressWithFile(
                result.files.single.path!,
                quality: 50,
              );
              if (compressResult == null) return;

              setState(() => _imageString = base64Encode(compressResult));
              debugPrint('file selected and saved, image: $_imageString');
            } else { // show pic when image string is present
              Uint8List imageBytes = base64Decode(_imageString!); 
              final imageProvider = MemoryImage(imageBytes);
              await precacheImage(imageProvider, context);

              await showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  // content: Image.memory(
                  //   imageBytes,
                  // ),
                  content: Image(image: imageProvider),
                  actions: [
                    CustomCancelButton(onPressed: () {Navigator.pop(context);}),
                    CustomDeleteButton(onPressed: () {
                      Navigator.pop(context);
                      setState(() => _imageString = null);
                    }),
                    TextButton(
                      onPressed: () async {
                        String? outputFile = await FilePicker.platform.saveFile();
                        if (outputFile != null) {
                          Flushbar(
                            message: "Image exported!",
                            animationDuration: Duration(milliseconds: 500),
                          );
                        }
                      },
                      child: const Text("Export"),
                    )
                  ],
                ),
              );
            }
          },
          icon: Icon(
            Icons.photo, 
            size: 24,
            color: _imageString != null ? _selectedCategory!.colorScheme(context.read<ThemeModel>().theme).onPrimary : Colors.grey,
          )
        ),
        // if (widget.costItem == null) // show currency exchange if form is new
        IconButton(
          iconSize: 24,
          onPressed: () {
            // debugPrint("add exchange feature!");
            currencyExchangeDialog();
          },
          icon: Icon(Icons.currency_exchange, size: 24,)
        ),
        if (widget.costItem != null) // show settings if editing existing form
        MenuAnchor(
          builder:(context, controller, child) {
            return IconButton(
              iconSize: 24,
              onPressed: () => controller.isOpen? controller.close() : controller.open(), 
              icon: Icon(Icons.more_vert)
            );
          },
          alignmentOffset: Offset(-130, 0),
          style: MenuStyle(
            // visualDensity: VisualDensity.compact,
            backgroundColor: WidgetStateProperty.all(categoryColorScheme.primaryContainer) 
          ),
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  appState.createNewCostItem(saveResult());
                  Navigator.of(context).pop();
                }
              },
              child: Text("Save as Copy", textAlign: TextAlign.right,)
            ),
            MenuItemButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  appState.createNewCostItem(saveResult());
                  Navigator.of(context).pop();
                }
              },
              child: Text("Create copy for today", textAlign: TextAlign.right)
            ),
            MenuItemButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pushNamed('/recurring');
                  appState.saveTempRecCostFromForm(saveResult());
                }
              },
              child: Text("Create recurring copy", textAlign: TextAlign.right)
            ),
          ],
        )
      ],
    );
  }

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
              child: Text("Cancel")
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                // iconColor: Theme.of(context).colorScheme.onError
              ),
              onPressed: () => Navigator.pop(context, true), 
              child: Text("Delete", style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.redAccent),)
            ),
          ],
        );
      },
    );
  }

  Future pickDate(BuildContext context, ColorScheme colorScheme) {
    return showDatePicker(
      context: context, 
      firstDate: _earliestDate, 
      lastDate: _latestDate, 
      initialDate: _selectedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme
          ),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 1,
              child: child
            ),
          ),
        );
      },
    );
  }

  Future currencyExchangeDialog() async {
    final dropdownMenuWidth = MediaQuery.of(context).size.width * 0.64;
    final textFieldBg = Colors.black.withAlpha(100);
    final textFieldDisabledBg = Colors.white.withAlpha(20);

    List<Widget> labelTitle(String title, {bool useSpacing = true}) => [
      useSpacing? SizedBox(height: 20,) : SizedBox.shrink(),
      Text(title, style: Theme.of(context).textTheme.labelSmall,),
      SizedBox(height: 8,)
    ];

    List<Widget> customDivider = [
      Divider(),
      SizedBox(height: 8,),
    ];

    TextEditingController _amountController = TextEditingController(text: "0");
    TextEditingController _rateController = TextEditingController(text: "0");
    TextEditingController _convertedAmountController = TextEditingController(text: "");
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
            return StatefulBuilder(
              builder: (context, setState) {
                final Map<String,dynamic> currencies = context.select((CurrencyModel state) => state.currencies);
                final Map<String,dynamic> exchange = context.select((CurrencyModel state) => state.rates);
                _convertedAmountController.text = (double.parse(_amountController.text) / double.parse(_rateController.text)).toStringAsFixed(2);
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
                              }
                            ),
                            Text(ExchangeRateType.current.name),
                            SizedBox(width: 10,),
                            Radio(
                              visualDensity: VisualDensity(horizontal: -2),
                              value: ExchangeRateType.custom, 
                              groupValue: _currentExchangeType, 
                              onChanged: (value) {
                                setState(() => _currentExchangeType = value!);
                              }
                            ),
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
                                    borderSide: BorderSide.none
                                  ),
                                  fillColor: textFieldBg,
                                  filled: true,
                                ),
                                textStyle: Theme.of(context).textTheme.titleMedium,
                                width: dropdownMenuWidth,
                                menuHeight: MediaQuery.of(context).size.height * 0.4,
                                dropdownMenuEntries: currencies.map((key,value) => MapEntry(key, 
                                  DropdownMenuEntry(
                                    value: key, 
                                    label: value,
                                    trailingIcon: Text(key)
                                  )
                                )).values.toList(),
                                onSelected: (value) {
                                  debugPrint("Selected value: $value");
                                  setState(() {
                                    _exchangedCurrency = value?? "";
                                    _currentExchangeRate = (exchange[_exchangedCurrency] as double)/(exchange[_currentCurrency] as double);
                                    _rateController.text = _currentExchangeRate.toStringAsFixed(2);
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
                          readOnly: _currentExchangeType == ExchangeRateType.custom? false: true,
                          enabled: _currentExchangeType == ExchangeRateType.custom? true: false,
                          decoration: InputDecoration(
                            fillColor: _currentExchangeType == ExchangeRateType.custom? textFieldBg: textFieldDisabledBg,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide.none
                            ),
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
                              borderSide: BorderSide.none
                            ),
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: (){}, 
                        child: Text("Confirm")
                      )
                    ],
                  );
                }
              }
            );
          }
        );
      },
    );
  }
}

class CostItemCategoryGrid extends StatefulWidget {
  const CostItemCategoryGrid({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory
  });

  final CostItemCategory? selectedCategory;
  final void Function(CostItemCategory) onCategorySelected;
  @override
  State<CostItemCategoryGrid> createState() => _CostItemCategoryGridState();
}

class _CostItemCategoryGridState extends State<CostItemCategoryGrid> {
  int? _selectedItem;
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

    final categories = context.read<AppModel>().categories;
    
    if (widget.selectedCategory != null) {
      _selectedCostType = widget.selectedCategory!.costType; 
      _filteredCostItemCategories = categories.where((category) => 
        category.costType == _selectedCostType
      ).toList();
      _selectedItem = _filteredCostItemCategories.indexWhere((category) => category.name == widget.selectedCategory!.name);
    } else {
      _filteredCostItemCategories = categories.where((category) => 
        category.costType == _selectedCostType
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final selectedThemeMode = context.select((ThemeModel state) => state.theme);
    final gridSize = context.select((ThemeModel state) => state.gridSize);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: screenSize.width,
          // height: screenSize.height * 0.07,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: SegmentedButton(
            segments: CostType.values.map((costType) {
              return ButtonSegment(
                value: costType,
                icon: Icon(Icons.money),
                label: Text(
                  costType.name,
                  style: Theme.of(context).textTheme.titleMedium,
                )
              );
            }).toList(), 
            selected: {_selectedCostType},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedCostType = newSelection.first;
                _filteredCostItemCategories = context.read<AppModel>().categories.where((category) => 
                  category.costType == _selectedCostType
                ).toList();
              });
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: gridSettings[gridSize]?['crossSpacing'] ?? 4,
                mainAxisSpacing: gridSettings[gridSize]?['mainSpacing'] ?? 4,
                mainAxisExtent: 100
                // childAspectRatio:0.9
              ),
              itemCount: _filteredCostItemCategories.length , 
              padding: EdgeInsets.all(20),
              itemBuilder:(context, index) {
                final CostItemCategory category = _filteredCostItemCategories.elementAt(index);
                final ColorScheme colorScheme = category.colorScheme(selectedThemeMode);
                final bgColor = index == _selectedItem ? colorScheme.primary : colorScheme.primaryContainer.withAlpha(200);
                // final bgColor = index == _selectedItem ? colorScheme.primary : null;
                final fgColor = index == _selectedItem ? colorScheme.onPrimary : colorScheme.onPrimaryContainer;
                return GestureDetector(
                  onTap: () {
                    widget.onCategorySelected(category);
                    
                    setState(() {
                      _selectedItem = index;
                    });
                  },
                  child: AnimatedScale(
                    scale: _selectedItem == index ? 1: 0.9,
                    duration: Durations.short3,
                    curve: Curves.easeInOut,
                    // decoration: BoxDecoration(border: Border.all()),
                    child: Column(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: AnimatedContainer(
                            duration: Durations.medium1,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bgColor,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  bgColor.withValues(
                                    red: min<double>((bgColor.r + 20/255), 1),
                                    blue: min<double>((bgColor.b + 20/255), 1),
                                    green: min<double>((bgColor.g + 20/255), 1),
                                  ),
                                  bgColor,
                                  bgColor.withAlpha(100),

                                ]
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(gridSettings[gridSize]?['iconPadding'] ?? 20),
                              // child: Image.asset(category.imagePath, color: fgColor,),
                              child: category.createIcon(40, selectedThemeMode, fgColor)
                            ),
                          ),
                        ),
                        Text(
                          // category.getLocalizedName(context), 
                          category.name, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}