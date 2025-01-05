import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/pages/worker_job_screen/worker_job_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerJobListScreen extends StatelessWidget {
  const WorkerJobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user is signed in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Applied Jobs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('workerId', isEqualTo: user.uid)
            .snapshots(), // Real-time updates for worker's applications
        builder: (context, applicationSnapshot) {
          if (!applicationSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (applicationSnapshot.data?.docs.isEmpty == true) {
            return const Center(
              child: Text('You have not applied to any jobs yet!'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: applicationSnapshot.data?.docs.length ?? 0,
              itemBuilder: (context, index) {
                final application = applicationSnapshot.data!.docs[index].data()
                    as Map<String, dynamic>;
                final jobId = application['jobId'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(jobId)
                      .get(),
                  builder: (context, jobSnapshot) {
                    if (jobSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (jobSnapshot.hasData) {
                      final jobData =
                          jobSnapshot.data!.data() as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          // Navigate to job details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkerJobDetailsScreen(jobId: jobId),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blueAccent.withOpacity(0.1),
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
                                          jobData['jobTitle'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          jobData['jobDescription'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Wage: ₹${jobData['wagePerDay']} /day',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
