import 'dart:ui';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
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

  String get capName => name?.capitalize() ?? "";

  CostItemCategory.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      color = Color(json['color'] ?? 0xff000000),
      imagePath = json['imagePath'],
      costType = CostType.fromString(json['costType']);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Fast path if they are the exact same instance

    return other is CostItemCategory &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name;
  }
  
  @override
  int get hashCode => Object.hash(id, name);
}
