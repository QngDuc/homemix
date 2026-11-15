import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_NavDestination>[
    _NavDestination('Trang chủ', Icons.home_outlined, 0),
    _NavDestination('Nguyên liệu', Icons.inventory_2_outlined, 1),
    _NavDestination('Pha ngay', Icons.local_bar_outlined, 2),
    _NavDestination('Học pha chế', Icons.menu_book_outlined, 3),
    _NavDestination('Nhật ký', Icons.fact_check_outlined, 5),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final hideNavigation =
        location.startsWith('/discover/recipe/') ||
        location.startsWith('/mix-now/recipe/') ||
        location.startsWith('/learning/course/');

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: hideNavigation
          ? null
          : SafeArea(
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
                          selected:
                              navigationShell.currentIndex ==
                              _destinations[index].branchIndex,
                          onTap: () => navigationShell.goBranch(
                            _destinations[index].branchIndex,
                            initialLocation:
                                _destinations[index].branchIndex ==
                                navigationShell.currentIndex,
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
  const _NavDestination(this.label, this.icon, this.branchIndex);

  final String label;
  final IconData icon;
  final int branchIndex;
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
