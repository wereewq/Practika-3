import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/breakpoints.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AdaptiveScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        context.go('/books');
        break;
      case 1:
        context.go('/authors');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);

    if (size == ScreenSize.compact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (idx) => _onDestinationSelected(context, idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.menu_book), label: 'Книги'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Авторы'),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (idx) => _onDestinationSelected(context, idx),
            extended: size == ScreenSize.expanded,
            labelType: size == ScreenSize.expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.local_library, size: 32),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.menu_book),
                label: Text('Книги'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Авторы'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}