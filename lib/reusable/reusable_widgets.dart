import 'package:budget_tracker/constants/icons.dart';
import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReusableContainer extends StatelessWidget {
  const ReusableContainer({
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(8),
    this.child,
    this.customColor,
    this.height,
    this.radius = 12,
    this.width,
    this.filled = false,
    this.showBorder = true,
    this.highlight = false,
    this.showSplash = true,
  });

  final EdgeInsets padding;
  final void Function()? onTap;
  final Widget? child;
  final bool filled;
  final bool showBorder;
  final bool showSplash;

  final Color? customColor;
  final bool highlight;
  final double? height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: !showSplash ? NoSplash.splashFactory: null,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          border:
              showBorder
                  ? BoxBorder.all(color: context.customCs.fadeColor2 ?? Colors.transparent)
                  : null,
          color:
              customColor ??
              (highlight
                  ? context.customCs.flipCardColor
                  : filled
                  ? context.customCs.fadeColor3
                  : null),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

class CategoryIconContainer extends StatelessWidget {
  const CategoryIconContainer({
    super.key,
    required this.category,
    this.size = 30,
    this.containerSize,
    this.inContainer = true,
    this.inverse = false,
    this.fade,
    this.padding = 0,
    this.radius = 12,
  });

  final double size;
  final double? containerSize;
  final bool inContainer;
  final bool inverse;
  final double radius;
  final double padding;
  final CostItemCategory category;
  final int? fade;

  @override
  Widget build(BuildContext context) {
    final finalSize = containerSize ?? size + 20;

    final iconChild =
        category.iconName != null
            ? FaIcon(
              icons.firstWhereOrNull((el) => el.name == category.iconName)?.icon ??
                  FontAwesomeIcons.photoFilm,
              size: size - 4,
              color: inverse ? context.cs.surface : context.cs.primary,
            )
            // ? Text(category.iconData!.codePoint.toString())
            : SvgPicture.asset(
              category.imagePath ?? "assets/images/placeholder.svg",
              colorFilter: ColorFilter.mode(
                inverse ? context.cs.surface : context.cs.primary,
                BlendMode.srcIn,
              ),
              // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
              height: size,
              width: size,
            );
    if (inContainer) {
      return ReusableContainer(
        height: finalSize,
        width: finalSize,
        radius: radius,
        padding: EdgeInsets.all(padding),
        customColor: category.color?.withAlpha(fade ?? 50),
        filled: true,
        highlight: inverse,
        child: Center(child: iconChild),
      );
    } else {
      return Center(child: iconChild);
    }
  }
}

Future<T?> showCustomModalSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool updateFab = true,
  bool? animated,
}) async {
  if (updateFab) {
    context.navMod.toggleFab(show: false);
  }
  final customAnimated = animated ?? !updateFab;
  final response = await showModalBottomSheet<T?>(
    isScrollControlled: true,
    sheetAnimationStyle: customAnimated ? null : AnimationStyle(reverseDuration: Duration.zero),
    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
    context: context,
    builder: builder,
  );
  if (updateFab && context.mounted) {
    context.navMod.toggleFab(show: true);
  }
  return response;
}
