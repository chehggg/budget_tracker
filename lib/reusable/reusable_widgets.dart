import 'package:budget_tracker/custom/class.dart';
import 'package:budget_tracker/custom/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReusableContainer extends StatelessWidget {
  const ReusableContainer({
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(8),
    this.child,
    this.height,
    this.filled = false,
  });

  final EdgeInsets padding;
  final void Function()? onTap;
  final Widget? child;
  final bool filled;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: BoxBorder.all(color: context.customCs.fadeColor2 ?? Colors.transparent),
          color: filled ? context.customCs.fadeColor3 : null,
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
  });

  final double size;
  final bool inContainer;
  final CostItemCategory category;

  @override
  Widget build(BuildContext context) {
    if (inContainer) {
      return ReusableContainer(
        filled: true,
        child: SvgPicture.asset(
          category.imagePath!,
          colorFilter: ColorFilter.mode(context.cs.primary, BlendMode.srcIn),
          // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          height: size,
          width: size,
        ),
      );
    } else {
      return SvgPicture.asset(
        category.imagePath!,
        colorFilter: ColorFilter.mode(context.cs.primary, BlendMode.srcIn),
        // foregroundColor == null ? null : ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        height: size,
        width: size,
      );
    }
  }
}
