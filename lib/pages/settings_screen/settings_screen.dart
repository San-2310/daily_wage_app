import 'package:daily_wage_app/providers/theme_provider.dart'; // Import your theme provider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isHindiLanguage;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // Load saved language setting from SharedPreferences
  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isHindiLanguage = prefs.getBool('isHindiLanguage') ??
          false; // Default to false (English)
      _isLoading = false; // Once data is loaded, set loading to false
    });
  }

  // Save language setting to SharedPreferences
  Future<void> _saveLanguagePreference(bool isHindi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isHindiLanguage', isHindi);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading indicator until language preference is loaded
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show loading spinner
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark/Light mode toggle using ThemeProvider
            SwitchListTile(
              title: Text('Dark Mode'),
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (bool value) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
            // Language toggle (Hindi/English)
            SwitchListTile(
              title: Text(isHindiLanguage ? 'हिंदी' : 'English'),
              value: isHindiLanguage,
              onChanged: (bool value) {
                setState(() {
                  isHindiLanguage = value;
                });
                _saveLanguagePreference(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
