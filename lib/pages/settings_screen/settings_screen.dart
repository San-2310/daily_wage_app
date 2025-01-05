import 'package:daily_wage_app/providers/theme_provider.dart'; // Import your theme provider
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Assuming you have a FlutterLocalization class
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../localization/locales.dart'; // Add this import

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FlutterLocalization _flutterLocalization;
  late bool isHindiLanguage;
  bool _isLoading = true; // Track loading state
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
    print(_currentLocale);
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

  // Function to update locale based on language selection
  void _setLocale(String? value) {
    if (value == null) return;

    if (value == "en") {
      _flutterLocalization
          .translate("en"); // Assuming translate method sets the locale
    } else if (value == "hi") {
      _flutterLocalization.translate("hi"); // Change to Hindi
    } else {
      return;
    }

    setState(() {
      _currentLocale = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading indicator until language preference is loaded
      return Scaffold(
        appBar: AppBar(
          title: Text(LocaleData.settings.getString(context)), // Update this line
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show loading spinner
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleData.settings.getString(context)), // Update this line
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark/Light mode toggle using ThemeProvider
            SwitchListTile(
              title: Text(LocaleData.darkMode.getString(context)), // Update this line
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
                _setLocale(value ? "hi" : "en"); // Update locale when toggled
              },
            ),
          ],
        ),
      ),
    );
  }
}
