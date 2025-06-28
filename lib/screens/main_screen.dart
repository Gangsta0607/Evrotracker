import 'package:flutter/material.dart';
import 'tracking_tab_page.dart';
import 'bookmarks_tab_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final TrackingTabPage _trackingTabPage = const TrackingTabPage();
  BookmarksTabPage? _bookmarksTabPage;

  final List<String> _titles = [
    'Трекер Европочты',
    'Закладки',
  ];

  // Утилита для осветления цвета
  Color brighten(Color color, [double amount = 0.05]) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lightAppBarColor = brighten(theme.colorScheme.surface, 0.03);
    final lightNavBarColor = brighten(theme.colorScheme.surface, 0.03);

    if (_currentIndex == 1) {
      _bookmarksTabPage = const BookmarksTabPage();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightAppBarColor,
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _trackingTabPage,
          _bookmarksTabPage ?? Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: lightNavBarColor,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Отследить',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            label: 'Закладки',
          ),
        ],
      ),
    );
  }
}
