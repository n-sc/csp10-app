import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:csp10_app/features/bear/views/bear.dart';
export 'package:csp10_app/features/home/views/home.dart';
export 'package:csp10_app/features/quotes/views/quotes.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      body: SafeArea(
        child: navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Badge(
              child: Icon(Icons.sports_bar),
            ),
            icon: Badge(
              label: Text("2"),
              child: Icon(Icons.sports_bar_outlined),
            ),
            label: "Bär",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notes),
            icon: Icon(Icons.notes_outlined),
            label: "Zitate",
          ),
        ],
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
