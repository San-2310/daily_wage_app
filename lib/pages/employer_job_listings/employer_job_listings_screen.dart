import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/configs/theme.dart';
import 'package:daily_wage_app/models/job_model.dart';
import 'package:daily_wage_app/pages/create_job/create_job_screen.dart';
import 'package:daily_wage_app/pages/employer_job_listings/employer_job_details.dart';
import 'package:daily_wage_app/providers/application_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployerJobListScreen extends StatelessWidget {
  const EmployerJobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current authenticated user ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('No user is signed in'));
    }

    String employerId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Job Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateJobScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('employerId', isEqualTo: employerId)
            .snapshots(), // Real-time updates for jobs
        builder: (context, jobSnapshot) {
          if (!jobSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Job> jobs = jobSnapshot.data!.docs
              .map((doc) =>
                  Job.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: jobs.map((job) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .where('jobId', isEqualTo: job.id)
                        .where('status',
                            isEqualTo: 'applied') // Only count 'applied' status
                        .snapshots(), // Real-time updates for applications
                    builder: (context, appSnapshot) {
                      if (!appSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      int applicationsCount = appSnapshot.data!.docs.length;

                      return GestureDetector(
                        onTap: () {
                          // Fetch applications for the selected job when it's tapped
                          Provider.of<ApplicationProvider>(context,
                                  listen: false)
                              .fetchApplications(job.id);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EmployerJobDetailsScreen(jobId: job.id),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: job.id.hashCode % 2 == 0
                                ? AppColors.royalBlue
                                : AppColors.lightBlue,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Left side - Job info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Wage: ₹${job.wagePerDay} /day',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Status: ${job.status}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side - Application Count
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        '$applicationsCount Applications',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
