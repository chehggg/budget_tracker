import 'dart:ui';

import 'package:budget_tracker/custom/enum.dart';
import 'package:flutter/material.dart';

class CostItemCategory {
  const CostItemCategory({this.id, this.name, this.color, this.imagePath, this.costType});

  final String? id;
  final String? name;
  final Color? color;
  final String? imagePath;
  final CostType? costType;

  CostItemCategory.error()
    : id = '0',
      name = "Not Found",
      color = Colors.white,
      imagePath = "assets/images/warning.svg",
      costType = CostType.expense;

  ColorScheme colorScheme(ThemeMode mode) {
    Brightness brightness;
    // final themeMode = ThemeMode.light;
    switch (mode) {
      case ThemeMode.dark:
        brightness = Brightness.dark;
      case ThemeMode.light:
        brightness = Brightness.light;
      default:
        brightness = PlatformDispatcher.instance.platformBrightness;
    }

    return ColorScheme.fromSeed(
      seedColor: color!,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      brightness: brightness,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color": color?.toARGB32(),
    "imagePath": imagePath,
    "costType": costType!.name,
  };

  CostItemCategory.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      color = Color(json['color'] as int),
      imagePath = json['imagePath'],
      costType = CostType.from(json['costType'] as String);
}
