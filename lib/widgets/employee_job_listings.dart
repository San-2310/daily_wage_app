import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/models/job_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../configs/theme.dart';

class EmployerJobListWidget extends StatefulWidget {
  const EmployerJobListWidget({super.key});

  @override
  _EmployerJobListWidgetState createState() => _EmployerJobListWidgetState();
}

class _EmployerJobListWidgetState extends State<EmployerJobListWidget> {
  List<Job> _jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  // Function to fetch jobs from Firestore
  Future<void> _fetchJobs() async {
    // Get the current authenticated user ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is signed in');
      return;
    }

    String employerId = user.uid; // Current user's ID

    try {
      // Query Firestore to get jobs where employerId matches the current user's ID
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .where('employerId', isEqualTo: employerId)
          .get();

      // Convert Firestore documents to Job objects
      setState(() {
        _jobs = snapshot.docs
            .map((doc) =>
                Job.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList()
            .take(4) // Limit to 4 jobs
            .toList();
      });
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _jobs.isEmpty
        ? const Center() // Loading indicator
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              //scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _jobs
                    .asMap()
                    .map((index, job) {
                      // Alternate colors for each job
                      Color jobColor = index % 2 == 0
                          ? AppColors.royalBlue
                          : AppColors.lightBlue;
                      return MapEntry(
                        index,
                        Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 120,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: jobColor,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        job.jobTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        job.jobDescription,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: -25,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          150, 142, 167, 230),
                                      borderRadius: BorderRadius.circular(2000),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 27,
                                  top: -25,
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          150, 142, 167, 230),
                                      borderRadius: BorderRadius.circular(2000),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      );
                    })
                    .values
                    .toList(),
              ),
            ),
          );
  }
}
