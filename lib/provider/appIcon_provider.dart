import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIconProvider with ChangeNotifier {
  String? _iconName;

  String get iconName => _iconName ?? 'dark_prime'; // Default to 'dark_prime'

  AppIconProvider() {
    loadIconName(); // Load the icon when the provider is created
  }

  // Setter with persistence
  set iconName(String name) {
    _iconName = name;
    _saveIconName(name); // Save icon name to SharedPreferences
    notifyListeners();
  }

  // Load the icon name from SharedPreferences
  Future<void> loadIconName() async {
    final prefs = await SharedPreferences.getInstance();
    _iconName =
        prefs.getString('app_icon') ?? 'dark_prime'; // Default to 'dark_prime'
    notifyListeners(); // Notify listeners once the icon is loaded
  }

  // Save the icon name to SharedPreferences
  Future<void> _saveIconName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_icon', name);
    print('Saved icon name: $name');
  }
}
