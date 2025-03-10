import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _backgroundColor = Colors.white;
  String _selectedColorName = 'Light Blue';

  final Map<String, Color> availableColors = {
    'White': Colors.white,
    'Light Grey': Colors.grey.shade100,
    'Beige': Color(0xFFFFF8E1),
    'Light Blue': Color(0xFFE3F2FD),
    'Mint Green': Color(0xFFE0F2F1),
    'Light Blue Accent': Colors.lightBlueAccent,
  };

  Color get backgroundColor => _backgroundColor;
  String get selectedColorName => _selectedColorName;
  Color get selectedBackgroundColor => availableColors[selectedColorName] ?? Colors.white;

  ThemeProvider() {
    _loadBackgroundColor();
  }

  Future<void> _loadBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString('background_color') ?? 'Light Blue';

    if (availableColors.containsKey(colorName)) {
      _selectedColorName = colorName;
      _backgroundColor = availableColors[colorName]!;
    } else {
      _selectedColorName = 'White';
      _backgroundColor = Colors.white;
    }
    notifyListeners();
  }

  Future<void> setBackgroundColor(String colorName) async {
    if (availableColors.containsKey(colorName)) {
      _selectedColorName = colorName;
      _backgroundColor = availableColors[colorName]!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('background_color', colorName);
      notifyListeners();
    }
  }
}
