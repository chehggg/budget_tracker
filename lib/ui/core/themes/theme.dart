import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:flutter/material.dart';

ThemeData get appTheme {
  final brightness = Brightness.dark;
  final baseTheme = ThemeData(brightness: brightness);

  final customColorScheme = baseTheme.colorScheme.copyWith(
    surface: Color(0xff0A0A0C),
    surfaceContainerHigh: Color.fromARGB(255, 30, 30, 37),
    surfaceContainer: Color(0xff0A0A0C),
    primary: Color(0xffF0EBE0),
    secondary: Color(0xffFFAB00),
  );

  final customTextTheme = baseTheme.textTheme.copyWith(
    bodySmall: TextStyle(fontFamily: 'Inter', color: Color(0xffF0EBE0).withAlpha(150)),
    bodyMedium: TextStyle(fontFamily: 'Inter'),
    // headline
    // titleSmall: TextStyle(fontFamily: 'Inter'),
    bodyLarge: TextStyle(fontFamily: 'Oranienbaum', fontSize: 26, color: customColorScheme.primary),
    labelSmall: TextStyle(fontFamily: 'Oranienbaum', fontWeight: FontWeight(600)),
    titleMedium: TextStyle(
      fontFamily: 'Oranienbaum',
      color: customColorScheme.onSurface.withAlpha(200),
      fontSize: 18,
    ),
    titleLarge: TextStyle(fontFamily: 'Oranienbaum'),
    headlineMedium: TextStyle(fontFamily: 'Oranienbaum'),
    titleSmall: TextStyle(fontFamily: 'Oranienbaum', color: customColorScheme.onSurface),
  );

  final MyTexts customTextExtension = MyTexts(
    numberFontLarge: customTextTheme.bodyLarge!.copyWith(
      fontSize: 50,
      fontWeight: FontWeight(800),
    ),
    numberFontMedium: customTextTheme.bodyMedium!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight(500),
    ),
    numberFontSmall: customTextTheme.bodyMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight(600),
    ),
    numberLabel: customTextTheme.labelSmall!.copyWith(
      fontSize: 18,
      letterSpacing: 0,
      color: customColorScheme.primary,
    ),
    elegantLabel: customTextTheme.labelSmall!.copyWith(
      fontSize: 25,
      letterSpacing: 0,
      color: customColorScheme.primary,
    ),
    elegantLabelLarge: customTextTheme.labelSmall!.copyWith(
      fontSize: 35,
      letterSpacing: 0,
      color: customColorScheme.primary,
    ),
    dateLabel: customTextTheme.labelSmall!.copyWith(
      fontSize: 25,
      letterSpacing: 0,
      color: customColorScheme.primary,
    ),
    paragraphTitle: customTextTheme.bodyMedium!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight(500),
      letterSpacing: 0,
      color: customColorScheme.primary,
    ),
    paragraphText: customTextTheme.bodyMedium!.copyWith(
      fontSize: 14,
      letterSpacing: 0,
      color: Color(0xffF0EBE0).withAlpha(150),
    ),
    paragraphTextSmall: customTextTheme.bodyMedium!.copyWith(
      fontSize: 12,
      letterSpacing: 0,
      color: Color(0xffF0EBE0).withAlpha(150),
    ),
  );

  final MyColors customColorExtension = MyColors(
    flipCardColor: Color(0xffF0EBE0),
    onFlipCard: Color(0xff0A0A0C),
    fadeColor1: Color(0xffF0EBE0).withAlpha(150),
    fadeColor2: Color(0xffF0EBE0).withAlpha(60),
    fadeColor3: Color(0xffF0EBE0).withAlpha(10),
    fadeColor4: Color(0xffF0EBE0).withAlpha(20),
  );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: customColorExtension.fadeColor2 ?? Colors.transparent),
  );

  return baseTheme.copyWith(
    extensions: [customColorExtension, customTextExtension],
    textTheme: customTextTheme,
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity(vertical: -2, horizontal: -2),
        // iconSize: 20,
        fixedSize: Size.square(20),
      ),
    ),

    appBarTheme: AppBarTheme(
      titleTextStyle: customTextExtension.dateLabel,
    ),
    colorScheme: customColorScheme,
    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
    dialogTheme: DialogThemeData(
      // actionsPadding: EdgeInsets.only(bottom: 8, right: 4),
      titleTextStyle: customTextExtension.elegantLabelLarge,
      backgroundColor: customColorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
        side: BorderSide(color: customColorExtension.fadeColor3!, width: 2),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: customColorExtension.fadeColor2,
      thickness: 0.5,
      space: 1,
    ),
    checkboxTheme: CheckboxThemeData(
      visualDensity: VisualDensity(vertical: -4, horizontal: -4),
      overlayColor: WidgetStateProperty.all(customColorScheme.primary.withAlpha(200)),
    ),
    radioTheme: RadioThemeData(
      visualDensity: VisualDensity(vertical: -4, horizontal: -4),
      fillColor: WidgetStateProperty.all(customColorScheme.primary.withAlpha(200)),
      overlayColor: WidgetStateProperty.all(customColorScheme.primary),
      // innerRadius: WidgetStateProperty.all(4.0),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity(vertical: 2),
        selectedBackgroundColor: customColorExtension.flipCardColor,
        selectedForegroundColor: customColorExtension.onFlipCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      visualDensity: VisualDensity.comfortable,
      fillColor: customColorExtension.fadeColor4,
    ),
  );
}
