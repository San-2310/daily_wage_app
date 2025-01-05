import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/pages/notification_screen/notification_screen.dart';
import 'package:daily_wage_app/widgets/all_job_fliter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/employee_job_listings.dart';
import '../create_job/create_job_screen.dart';
import '../employer_job_listings/employer_job_listings_screen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'] ?? 'User'; // Default to 'User'
          });
        } else {
          setState(() {
            _userName = 'User'; // Default if no document found
          });
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
      setState(() {
        _userName = 'User'; // Default if error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            image: AssetImage(
              'assets/images/app_logo_placeholder.png',
            ),
          ),
        ),
        title: Text(
          'Daily Wage App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Hey, $_userName!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Empower Work. Simplify Life.",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateJobScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 163, 128, 244),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      top: -50,
                      child: Container(
                        height: 175,
                        width: 175,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 169, 142, 232),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      top: -50,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 190, 168, 242),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 50,
                      bottom: 50,
                      child: Row(
                        children: [
                          Text(
                            "Create a new Job Listing",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  fontSize: 18,
                                ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(155, 230, 224, 234),
                                  borderRadius: BorderRadius.circular(300),
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 32,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Listings",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployerJobListScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "View All",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Container(child: EmployerJobListWidget()),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "All Job Listings",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              JobFilterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
