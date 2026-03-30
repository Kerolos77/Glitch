import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  String? _selectedGame;
  bool _isSidebarVisible = true;

  String? get selectedGame => _selectedGame;
  bool get isSidebarVisible => _isSidebarVisible;

  void selectGame(String? gameId) {
    _selectedGame = gameId;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarVisible = !_isSidebarVisible;
    notifyListeners();
  }

  void setSidebarVisible(bool visible) {
    _isSidebarVisible = visible;
    notifyListeners();
  }
}
