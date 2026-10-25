import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../widgets/drawers/desk_settings_drawer.dart';
import '../widgets/layout/desktop_sidebar.dart';
import '../widgets/layout/perforated_player_bar.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final shade = theme.currentShade;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: shade.desk,
          endDrawer: const DeskSettingsDrawer(),
          appBar: !isDesktop
              ? AppBar(
                  backgroundColor: shade.paper,
                  elevation: 1,
                  title: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/images/santori_logo.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.graphic_eq,
                              color: Color(0xFF00FF66),
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SANTORI',
                        style: GoogleFonts.fraunces(
                          color: shade.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.tune, color: theme.inkColor, size: 20),
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                )
              : null,
          bottomNavigationBar: !isDesktop
              ? NavigationBar(
                  backgroundColor: shade.paper,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (idx) =>
                      setState(() => _currentIndex = idx),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Search',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.library_music_outlined),
                      selectedIcon: Icon(Icons.library_music),
                      label: 'Library',
                    ),
                  ],
                )
              : null,
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Desktop Left Sidebar
                    if (isDesktop)
                      DesktopSidebar(
                        currentIndex: _currentIndex,
                        onIndexChanged: (idx) =>
                            setState(() => _currentIndex = idx),
                        onOpenDeskSettings: () =>
                            _scaffoldKey.currentState?.openEndDrawer(),
                      ),

                    // Main Content Screen
                    Expanded(
                      child: Container(
                        color: shade.desk,
                        child: _screens[_currentIndex],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Bottom Perforated Music Player Bar
              const PerforatedPlayerBar(),
            ],
          ),
        );
      },
    );
  }
}
