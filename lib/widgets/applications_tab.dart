import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/models/application_model.dart';
import 'package:daily_wage_app/models/rating_model.dart';
import 'package:daily_wage_app/services/notification_service.dart'; // Import the NotificationService
import 'package:daily_wage_app/services/rating_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart'; // Add this import

import '../localization/locales.dart'; // Add this import

class ApplicationTab extends StatefulWidget {
  final String jobId; // Add this line

  const ApplicationTab({super.key, required this.jobId}); // Update this line

  @override
  _ApplicationTabState createState() => _ApplicationTabState();
}

class _ApplicationTabState extends State<ApplicationTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RatingServices _ratingServices = RatingServices();
  final NotificationService _notificationService =
      NotificationService(); // Create instance of NotificationService

  int selectedRating = 0; // To track the selected dots for rating

  // Function to handle rating submission
  Future<void> _submitRating(
      String workerId, int rating, String applicationId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleData.noUserSignedIn
              .getString(context)))); // Update this line
      return;
    }

    Rating ratingObj = Rating(
      raterId: currentUser.uid, // The employer (current user)
      ratedId: workerId, // The worker being rated
      jobId:
          applicationId, // The job associated with the rating (application ID)
      rating: rating, // The rating value (user input)
      ratedAt: DateTime.now(), // Current time when the rating is given
    );

    String? error = await _ratingServices.addOrUpdateRating(ratingObj);
    if (error == null) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleData.ratingSubmittedSuccessfully
              .getString(context)))); // Update this line
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${LocaleData.errorSubmittingRating.getString(context)} $error'))); // Update this line
    }
  }

  // Function to display rating dialog with dots
  void _showRatingDialog(String workerId, String applicationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setDialogState) {
            return AlertDialog(
              title: Text(LocaleData.rateEmployer
                  .getString(context)), // Update this line
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          selectedRating > index
                              ? Icons.circle
                              : Icons.radio_button_unchecked,
                          color: selectedRating > index
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating =
                                index + 1; // Update the parent state
                          });
                          setDialogState(
                              () {}); // Force UI update inside the dialog
                        },
                      );
                    }),
                  ),
                  Text(
                      '${LocaleData.rating.getString(context)}: $selectedRating'), // Update this line
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                      LocaleData.cancel.getString(context)), // Update this line
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitRating(workerId, selectedRating, applicationId);
                  },
                  child: Text(
                      LocaleData.submit.getString(context)), // Update this line
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to handle application status changes (accept/reject)
  Future<void> _handleApplicationStatus(
      String applicationId, String status) async {
    try {
      // Update application status in Firestore
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
      });

      // Fetch the workerId and jobId from the application
      var applicationSnapshot =
          await _firestore.collection('applications').doc(applicationId).get();
      var applicationData = applicationSnapshot.data();
      String workerId = applicationData?['workerId'];
      String jobId = applicationData?['jobId'] ?? '';

      // Fetch the job title using the jobId
      var jobSnapshot = await _firestore.collection('jobs').doc(jobId).get();
      var jobData = jobSnapshot.data();
      String jobTitle = jobData?['jobTitle'] ?? 'Job';

      // Notify the worker about the status change
      await _notificationService.notifyWorkerOfApplicationStatus(
        Application(
          id: applicationId,
          workerId: workerId,
          jobId: jobId,
          status: status,
          appliedAt: DateTime.now(),
        ),
        jobTitle,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Application ${status == 'accepted' ? 'accepted' : 'rejected'}'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${LocaleData.errorUpdatingJob.getString(context)} $e'), // Update this line
      ));
    }
  }

  // Fetch applications based on status
  Widget _buildApplicationsTab(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('applications')
          .where('status', isEqualTo: status)
          .where('jobId', isEqualTo: widget.jobId) // Update this line
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(
                  '${LocaleData.error.getString(context)}: ${snapshot.error}')); // Update this line
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(LocaleData.noApplicationsYet
                  .getString(context))); // Update this line
        }

        List<Map<String, dynamic>> applications = [];

        Future<List<Map<String, dynamic>>> fetchApplications() async {
          List<Map<String, dynamic>> applicationsWithWorkerNames = [];

          for (var doc in snapshot.data!.docs) {
            var applicationData = doc.data() as Map<String, dynamic>;

            var workerSnapshot = await _firestore
                .collection('users')
                .doc(applicationData['workerId'])
                .get();

            if (workerSnapshot.exists) {
              var workerData = workerSnapshot.data() as Map<String, dynamic>;
              applicationsWithWorkerNames.add({
                'workerName': workerData['name'],
                'workerId': applicationData['workerId'],
                'status': applicationData['status'],
                'applicationId': doc.id,
                'workerData': workerData
              });
            }
          }

          return applicationsWithWorkerNames;
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchApplications(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (futureSnapshot.hasError) {
              return Center(
                  child: Text(
                      '${LocaleData.error.getString(context)}: ${futureSnapshot.error}')); // Update this line
            }

            if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
              return Center(
                  child: Text(LocaleData.noApplicationsYet
                      .getString(context))); // Update this line
            }

            List<Map<String, dynamic>> applicationsWithWorkerNames =
                futureSnapshot.data!;

            return ListView.builder(
              itemCount: applicationsWithWorkerNames.length,
              itemBuilder: (context, index) {
                var application = applicationsWithWorkerNames[index];
                String applicationId = application['applicationId'] ?? '';

                if (applicationId.isEmpty) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () {
                    var workerData = application['workerData'];

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(LocaleData.workerDetails
                              .getString(context)), // Update this line
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  LocaleData.name.getString(context),
                                  workerData['name']), // Update this line
                              _buildDetailRow(
                                  LocaleData.email.getString(context),
                                  workerData['email']), // Update this line
                              _buildDetailRow(
                                  LocaleData.phone.getString(context),
                                  workerData['phone']), // Update this line
                              _buildDetailRow(
                                  LocaleData.role.getString(context),
                                  workerData['role']), // Update this line
                              _buildDetailRow(
                                  LocaleData.location.getString(context),
                                  workerData['location']), // Update this line
                              _buildDetailRow(
                                  LocaleData.numRatings.getString(context),
                                  workerData['ratingCount']
                                      .toString()), // Update this line
                              _buildDetailRow(
                                  LocaleData.avgRating.getString(context),
                                  workerData['averageRating']
                                      .toString()), // Update this line
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(LocaleData.close
                                  .getString(context)), // Update this line
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(application['workerName'] ??
                                  LocaleData.unknownWorker
                                      .getString(context)), // Update this line
                              Text(
                                  '${LocaleData.status.getString(context)}: ${application['status']}'), // Update this line
                            ],
                          ),
                        ),
                        if (status == 'accepted') ...[
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.yellow),
                            onPressed: () {
                              _showRatingDialog(
                                  application['workerId'], applicationId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              _handleApplicationStatus(
                                  applicationId, 'rejected');
                            },
                          ),
                        ] else if (status == 'applied') ...[
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () {
                              _handleApplicationStatus(
                                  applicationId, 'accepted');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              _handleApplicationStatus(
                                  applicationId, 'rejected');
                            },
                          ),
                        ] else if (status == 'rejected') ...[
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () {
                              _handleApplicationStatus(
                                  applicationId, 'accepted');
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method to build detailed rows in the dialog
  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 204, 220, 231),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 157, 174, 182),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(value.toString()),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 206, 231, 247),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              tabs: [
                Tab(
                    text: LocaleData.applied
                        .getString(context)), // Update this line
                Tab(
                    text: LocaleData.accepted
                        .getString(context)), // Update this line
                Tab(
                    text: LocaleData.rejected
                        .getString(context)), // Update this line
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildApplicationsTab('applied'),
                _buildApplicationsTab('accepted'),
                _buildApplicationsTab('rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
