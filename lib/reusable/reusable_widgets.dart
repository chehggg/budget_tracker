import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReusableContainer extends StatelessWidget {
  const ReusableContainer({
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(8),
    this.child,
    this.customColor,
    this.height,
    this.width,
    this.filled = false,
    this.showBorder = true,
    this.highlight = false,
  });

  final EdgeInsets padding;
  final void Function()? onTap;
  final Widget? child;
  final bool filled;
  final bool showBorder;

  final Color? customColor;
  final bool highlight;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          border: showBorder? BoxBorder.all(color: context.customCs.fadeColor2 ?? Colors.transparent) : null,
          color: customColor ??
              (highlight
                  ? context.customCs.flipCardColor
                  : filled
                  ? context.customCs.fadeColor3
                  : null),
          // gradient:
          //     customColor != null
          //         ? LinearGradient(
          //           stops: [0, 1.5],
          //           colors: [customColor!, Colors.transparent],
          //           begin: Alignment.topCenter,
          //           end: Alignment.bottomRight,
          //         )
          //         : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class CategoryIconContainer extends StatelessWidget {
  const CategoryIconContainer({
    super.key,
    this.size = 30,
    required this.category,
    this.inContainer = true,
    this.inverse = false,
    this.fade,
  });

  final double size;
  final bool inContainer;
  final bool inverse;
  final CostItemCategory category;
  final int? fade;

  @override
  Widget build(BuildContext context) {
    if (inContainer) {
      return ReusableContainer(
        customColor: category.color?.withAlpha(fade ?? 50),
        filled: true,
        highlight: inverse,
        child: SvgPicture.asset(
          category.imagePath ?? "assets/images/placeholder.svg",
          colorFilter: ColorFilter.mode(
            inverse ? context.cs.surface : context.cs.primary,
            BlendMode.srcIn,
          ),
          // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          height: size,
          width: size,
        ),
      );
    } else {
      return SvgPicture.asset(
        category.imagePath ?? "assets/images/placeholder.svg",
        colorFilter: ColorFilter.mode(
          inverse ? context.cs.surface : context.cs.primary,
          BlendMode.srcIn,
        ),
        // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        height: size,
        width: size,
      );
    }
  }
}
