import 'package:budget_tracker/custom/classes/category_class.dart';
import 'package:budget_tracker/custom/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReusableContainer extends StatelessWidget {
  const ReusableContainer({
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(8),
    this.child,
    this.height,
    this.width,
    this.filled = false,
    this.highlight = false,
  });

  final EdgeInsets padding;
  final void Function()? onTap;
  final Widget? child;
  final bool filled;
  final bool highlight;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          border: BoxBorder.all(color: context.customCs.fadeColor2 ?? Colors.transparent),
          color: highlight ? context.customCs.flipCardColor : filled ? context.customCs.fadeColor3 : null,
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
  });

  final double size;
  final bool inContainer;
  final bool inverse;
  final CostItemCategory category;

  @override
  Widget build(BuildContext context) {
    if (inContainer) {
      return ReusableContainer(
        filled: true,
        highlight: inverse,
        child: SvgPicture.asset(
          category.imagePath?? "assets/images/placeholder.svg",
          colorFilter: ColorFilter.mode(inverse ? context.cs.surface : context.cs.primary, BlendMode.srcIn),
          // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          height: size,
          width: size,
        ),
      );
    } else {
      return SvgPicture.asset(
        category.imagePath?? "assets/images/placeholder.svg",
        colorFilter: ColorFilter.mode(inverse ? context.cs.surface : context.cs.primary, BlendMode.srcIn),
        // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        height: size,
        width: size,
      );
    }
  }
}
