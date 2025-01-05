import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/pages/employer_home/employer_home_screen.dart';
import 'package:daily_wage_app/pages/employer_job_listings/employer_job_listings_screen.dart';
import 'package:daily_wage_app/pages/profile/profile_screen.dart';
import 'package:daily_wage_app/pages/settings_screen/settings_screen.dart';
import 'package:daily_wage_app/pages/worker_home_screen/worker_home_screen.dart';
import 'package:daily_wage_app/pages/worker_job_screen/worker_job_listings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavigatorScreen extends StatefulWidget {
  @override
  _NavigatorScreenState createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _selectedIndex = 0;

  // List of pages for each BottomNavigationBar item
  final List<Widget> _pages = [
    FirebaseAuth.instance.currentUser?.uid == null
        ? Scaffold(
            backgroundColor: Colors.red) // Placeholder for loading or error
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.blue,
                  body: Center(child: CircularProgressIndicator()),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Scaffold(
                  backgroundColor: Colors.red,
                  body: Center(child: Text('Error or No Data')),
                ); // Show error if data fetch fails
              }
              final userRole =
                  snapshot.data?['role'] ?? 'worker'; // Default to 'worker'
              if (userRole == 'employer') {
                return EmployerHomeScreen(); // If role is employer, show employer home screen
              } else {
                return WorkerHomeScreen(); // If role is worker, show worker home screen
              }
            },
          ),
    FirebaseAuth.instance.currentUser?.uid == null
        ? Scaffold(
            backgroundColor: Colors.red) // Placeholder for loading or error
        : FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.blue,
                  body: Center(child: CircularProgressIndicator()),
                ); // Show loading indicator while fetching data
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Scaffold(
                  backgroundColor: Colors.red,
                  body: Center(child: Text('Error or No Data')),
                ); // Show error if data fetch fails
              }
              final userRole =
                  snapshot.data?['role'] ?? 'worker'; // Default to 'worker'
              if (userRole == 'employer') {
                return EmployerJobListScreen(); // If role is employer, show employer home screen
              } else {
                return WorkerJobListScreen(); // If role is worker, show worker home screen
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medical_services_outlined),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
