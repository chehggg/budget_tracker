import 'package:budget_tracker/custom/extensions.dart';
import 'package:flutter/material.dart';

ThemeData get appTheme {
  final brightness = Brightness.dark;
  final baseTheme = ThemeData(brightness: brightness);

  final customColorScheme = baseTheme.colorScheme.copyWith(
    surface: Color(0xff0A0A0C),
    surfaceContainer: Color(0xff0A0A0C),
    primary: Color(0xffF0EBE0),
    secondary: Color(0xffFFAB00),
  );

  final customTextTheme = baseTheme.textTheme.copyWith(
    bodySmall: TextStyle(fontFamily: 'Inter', color: Color(0xffF0EBE0).withAlpha(150)),
    bodyMedium: TextStyle(fontFamily: 'Inter'),
    // headline
    // titleSmall: TextStyle(fontFamily: 'Inter'),
    bodyLarge: TextStyle(fontFamily: 'DMSerifDisplay', fontSize: 26),
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
      fontWeight: FontWeight(300),
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
  );

  final MyColors customColorExtension = MyColors(
    flipCardColor: Color(0xffF0EBE0),
    onFlipCard: Color(0xff0A0A0C),
    fadeColor1: Color(0xffF0EBE0).withAlpha(150),
    fadeColor2: Color(0xffF0EBE0).withAlpha(60),
    fadeColor3: Color(0xffF0EBE0).withAlpha(10),
  );

  return baseTheme.copyWith(
    extensions: [customColorExtension, customTextExtension],
    textTheme: customTextTheme,
    colorScheme: customColorScheme,
    dialogTheme: DialogThemeData(
      actionsPadding: EdgeInsets.only(bottom: 8, right: 4),
      titleTextStyle: customTextExtension.elegantLabelLarge,
      backgroundColor: customColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(20),
        side: BorderSide(color: customColorExtension.fadeColor2!),
      ),
    ),
  );
}
