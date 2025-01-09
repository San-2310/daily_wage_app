import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/pages/employer_home/employer_home_screen.dart';
import 'package:daily_wage_app/pages/employer_job_listings/employer_job_listings_screen.dart';
import 'package:daily_wage_app/pages/profile/profile_screen.dart';
import 'package:daily_wage_app/pages/settings_screen/settings_screen.dart';
import 'package:daily_wage_app/pages/worker_home_screen/worker_home_screen.dart';
import 'package:daily_wage_app/pages/worker_job_screen/worker_job_listings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Add this import

import '../localization/locales.dart'; // Add this import

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  _NavigatorScreenState createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _selectedIndex = 0;

  // List of pages for each BottomNavigationBar item
  final List<Widget> _pages = [
    FirebaseAuth.instance.currentUser?.uid == null
        ? const Scaffold(
            backgroundColor: Colors.red) // Placeholder for loading or error
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.blue,
                  body: Center(child: CircularProgressIndicator()),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Scaffold(
                  backgroundColor: Colors.red,
                  body: Center(child: Text('Error or No Data')),
                ); // Show error if data fetch fails
              }
              final userRole =
                  snapshot.data?['role'] ?? 'worker'; // Default to 'worker'
              if (userRole == 'employer') {
                return const EmployerHomeScreen(); // If role is employer, show employer home screen
              } else {
                return const WorkerHomeScreen(); // If role is worker, show worker home screen
              }
            },
          ),
    FirebaseAuth.instance.currentUser?.uid == null
        ? const Scaffold(
            backgroundColor: Colors.red) // Placeholder for loading or error
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.blue,
                  body: Center(child: CircularProgressIndicator()),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Scaffold(
                  backgroundColor: Colors.red,
                  body: Center(child: Text('Error or No Data')),
                ); // Show error if data fetch fails
              }
              final userRole =
                  snapshot.data?['role'] ?? 'worker'; // Default to 'worker'
              if (userRole == 'employer') {
                return const EmployerJobListScreen(); // If role is employer, show employer home screen
              } else {
                return const WorkerJobListScreen(); // If role is worker, show worker home screen
              }
            },
          ),
    ProfileScreen(),
    SettingsScreen(),
  ];

  // Function to handle item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_selectedIndex], // Display the current page
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            elevation: 8.0,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: const Color.fromRGBO(55, 27, 52, 1),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: LocaleData.home.getString(context), // Update this line
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.medical_services_outlined),
                label: LocaleData.jobs.getString(context), // Update this line
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: LocaleData.profile.getString(context), // Update this line
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: LocaleData.settings.getString(context), // Update this line
              ),
            ],
          ),
        ),
      ),
    );
  }
}
