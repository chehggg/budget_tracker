import 'package:budget_tracker/custom/extensions/context_extensions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomMainScaffold extends StatelessWidget {
  const CustomMainScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: shell, // This renders the active branch screen
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: shell.currentIndex,
        onTap: shell.goBranch,
      ),
      resizeToAvoidBottomInset: true,
      floatingActionButton: CustomFAB(),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, this.onTap, required this.currentIndex});

  final ValueChanged<int>? onTap;
  final int currentIndex;

  static List<FaIconData> buttons = [
    FontAwesomeIcons.houseChimney,
    FontAwesomeIcons.chartPie,
    FontAwesomeIcons.bullseye,
    FontAwesomeIcons.gear,
    // Icons.auto_graph, // chart
    // Icons.ads_click_outlined, // goals
    // Icons.settings, // settings
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 10,
      shape: AutomaticNotchedShape(
        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
        RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(24)),
      ),

      // currentIndex: navigationShell.currentIndex,
      // onTap: onTap,
      // items: [
      //   ...buttons.mapIndexed(
      //     (index, button) => BottomNavigationBarItem(
      //       label: "Test",
      //       // onPressed: () => navigationShell.goBranch(5),
      //       icon: Icon(button, color: context.cs.primary),
      //     ),
      //   ),
      // ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...buttons.mapIndexed(
              (index, button) {
                final isSelected = index == currentIndex;
                return AnimatedScale(
                  scale: isSelected ? 1.05 : 0.90,
                  duration: Durations.medium1,
                  curve: Curves.easeOutCubic,
                  child: IconButton(
                    onPressed: () => onTap?.call(index),
                    // iconSize: 24,
                    padding: EdgeInsets.all(12),
                    style: IconButton.styleFrom(
                      fixedSize: Size.square(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: isSelected ? context.cs.primary : Colors.transparent,
                      padding: const EdgeInsets.all(0.0),
                    ),
                    // visualDensity: VisualDensity.comfortable,
                    icon: FaIcon(
                      size: 24,
                      button,
                      color: isSelected ? context.cs.surface : context.cs.primary,
                    ),
                  ),
                );
              },
            ),
          ]..insert(
            2,
            SizedBox(
              width: 120,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: FloatingActionButton(
        onPressed: () {
          context.push('/form');
          HapticFeedback.mediumImpact();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(24)),
        enableFeedback: true,
        elevation: 0,
        foregroundColor: context.cs.surfaceContainer,
        backgroundColor: context.cs.primary,
        child: FaIcon(
          FontAwesomeIcons.plus,
          size: 40,
        ),
      ),
    );
  }
}
