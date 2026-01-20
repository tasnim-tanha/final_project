import 'package:flutter/material.dart';
import 'recipes_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [RecipesScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.orange.shade600,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.green.shade100,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Colors.green.shade600),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.blue.shade600),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
