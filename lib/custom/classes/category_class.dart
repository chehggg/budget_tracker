import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:budget_tracker/custom/enums/enum.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';

class CostItemCategory {
  const CostItemCategory({
    this.id,
    this.name,
    this.color,
    this.imagePath,
    this.costType,
    this.iconName,
  });

  final String? id;
  final String? name;
  final Color? color;
  final String? imagePath;
  final CostType? costType;
  final String? iconName;

  CostItemCategory.error()
    : id = '0',
      name = "Not Found",
      color = Colors.white,
      imagePath = "assets/images/warning.svg",
      costType = CostType.expense,
      iconName = null;

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
    "costType": costType?.name,
    "iconName": iconName,
  };

  String get capName => name?.capitalize() ?? "";

  CostItemCategory.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      color = Color(json['color'] ?? 0xff000000),
      imagePath = json['imagePath'],
      costType =
          json['costType'] != null ? CostType.values.byName(json['costType']) : CostType.expense,
      // ignore: non_const_argument_for_const_parameter
      iconName = json['iconName'];

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

  CostItemCategory copyWith({
    String? id,
    String? name,
    Color? color,
    String? imagePath,
    CostType? costType,
    String? Function()? iconName,
  }) {
    return CostItemCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      costType: costType ?? this.costType,
      iconName: iconName != null ? iconName.call() : this.iconName,
    );
  }
}
