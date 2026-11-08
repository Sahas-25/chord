import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// The main frame of the app: navigation + current tab + mini player.
/// Phone  (< 600 px)  -> bottom NavigationBar
/// Tablet (600-1000)  -> NavigationRail with icons and labels
/// Desktop (>= 1000)  -> extended NavigationRail
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<_Destination> _destinations = [
    _Destination('Home', Icons.home_outlined, Icons.home),
    _Destination('Search', Icons.search, Icons.search),
    _Destination('Library', Icons.library_music_outlined, Icons.library_music),
    _Destination('Profile', Icons.person_outline, Icons.person),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= 600;
    final extended = width >= 1000;

    // Current screen on top, mini player below it.
    final body = Column(
      children: [
        Expanded(child: _screens[_index]),
        const MiniPlayer(),
      ],
    );

    if (useRail) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: _index,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                onDestinationSelected: (i) => setState(() => _index = i),
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'CHORD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purple,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, color: AppColors.cardLight),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
