import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_NavDestination>[
    _NavDestination('Discover', Icons.explore_rounded),
    _NavDestination('Pantry', Icons.kitchen_rounded),
    _NavDestination('Mix Now', Icons.blender_rounded),
    _NavDestination('Learning', Icons.menu_book_rounded),
    _NavDestination('Practice', Icons.local_drink_rounded),
    _NavDestination('Journal', Icons.auto_stories_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              for (var index = 0; index < _destinations.length; index++)
                Expanded(
                  child: _NavigationItem(
                    destination: _destinations[index],
                    selected: navigationShell.currentIndex == index,
                    onTap: () => navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.coral : AppColors.muted;
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(destination.icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
