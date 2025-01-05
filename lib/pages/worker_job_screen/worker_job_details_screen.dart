import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/models/application_model.dart';
import 'package:daily_wage_app/models/rating_model.dart';
import 'package:daily_wage_app/models/user_model.dart';
import 'package:daily_wage_app/services/notification_service.dart';
import 'package:daily_wage_app/services/rating_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerJobDetailsScreen extends StatefulWidget {
  final String jobId;

  const WorkerJobDetailsScreen({
    Key? key,
    required this.jobId,
  }) : super(key: key);

  @override
  State<WorkerJobDetailsScreen> createState() => _WorkerJobDetailsScreenState();
}

class _WorkerJobDetailsScreenState extends State<WorkerJobDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _jobDetails;
  AppUser? _worker;
  int selectedRating = 0;
  final RatingServices _ratingServices = RatingServices();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
    _fetchJobDetails();
  }

  Future<void> _fetchWorkerData() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          _worker = AppUser.fromFirestore(
              userSnapshot.data() as Map<String, dynamic>, currentUserId);
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching worker data: $e')),
      );
    }
  }

  Future<void> _fetchJobDetails() async {
    try {
      DocumentSnapshot jobSnapshot = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .get();

      if (jobSnapshot.exists) {
        setState(() {
          _jobDetails = jobSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job not found')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching job details: $e')),
      );
    }
  }

  // Function to handle rating submission
  Future<void> _submitRating(String employerId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    Rating ratingObj = Rating(
      raterId: currentUser.uid, // The worker (current user)
      ratedId: employerId, // The employer being rated
      jobId: widget.jobId, // The job associated with the rating
      rating: selectedRating, // The rating value (user input)
      ratedAt: DateTime.now(), // Current time when the rating is given
    );

    String? error = await _ratingServices.addOrUpdateRating(ratingObj);
    if (error == null) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $error')));
    }
  }

  // Function to show rating dialog with dots
  void _showRatingDialog(String employerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setDialogState) {
            return AlertDialog(
              title: Text('Rate Employer'),
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
                  Text('Rating: $selectedRating'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitRating(_jobDetails!['employerId']);
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_jobDetails == null || _worker == null) {
      return const Scaffold(
        body: Center(child: Text('Data not available')),
      );
    }

    final employerRatingStream = FirebaseFirestore.instance
        .collection('ratings')
        .where('ratedId', isEqualTo: _jobDetails!['employerId'])
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _jobDetails!['jobTitle'] ?? 'Job Title',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),

            // Employer Rating Stream
            StreamBuilder<QuerySnapshot>(
              stream: employerRatingStream,
              builder: (context, snapshot) {
                double employerRating = 0.0;
                int ratingCount = 0;

                if (snapshot.hasData) {
                  var ratings = snapshot.data!.docs;
                  employerRating = ratings.fold<double>(0.0, (sum, doc) {
                        return sum + (doc['rating'] ?? 0.0);
                      }) /
                      ratings.length;
                  ratingCount = ratings.length;
                }

                return Row(
                  children: [
                    Text(
                      'Employer Rating: ${employerRating.toStringAsFixed(1)}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '($ratingCount reviews)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Job Details
            _buildDetailsSection(
              'Details',
              [
                'Wage Per Day: ₹${_jobDetails!['wagePerDay']}',
                'Duration: ${_jobDetails!['duration']} days',
                'Category: ${_jobDetails!['category']}',
                'Location: ${_jobDetails!['location']['address'] ?? 'N/A'}',
              ],
            ),
            const SizedBox(height: 20),

            // Description Section
            _buildDetailsSection(
              'Job Description',
              [_jobDetails!['jobDescription'] ?? 'No description available.'],
            ),
            const SizedBox(height: 30),

            // StreamBuilder for application status
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('applications')
                  .where('jobId', isEqualTo: widget.jobId)
                  .where('workerId', isEqualTo: _worker?.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  var applicationData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  Application application = Application.fromFirestore(
                      applicationData, snapshot.data!.docs.first.id);

                  if (application.status == 'accepted') {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showRatingDialog(_jobDetails!['employerId']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Rate Employer',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            'Applied (Accepted)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Applied (${application.status ?? 'Unknown'})',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                return ElevatedButton(
                  onPressed: () async {
                    // Submit the application
                    await _submitApplication();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to submit application and notify employer
  Future<void> _submitApplication() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('applications').add({
        'workerId': currentUserId,
        'jobId': widget.jobId,
        'status': 'applied',
      });

      // Notify employer about the new application
      await _notificationService.notifyEmployerOfNewApplication(
          _jobDetails!['employerId'], _jobDetails!['jobTitle'], _worker!.name);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    }
  }

  // Utility function to build details section
  Widget _buildDetailsSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ...details
            .map(
              (detail) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(detail),
              ),
            )
            .toList(),
      ],
    );
  }
}
