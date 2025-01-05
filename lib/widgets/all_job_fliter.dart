import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/models/user_model.dart';
import 'package:daily_wage_app/pages/employer_job_listings/employer_job_details.dart';
import 'package:daily_wage_app/pages/worker_job_screen/worker_job_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/job_model.dart';

class JobFilterWidget extends StatefulWidget {
  const JobFilterWidget({super.key});

  @override
  _JobFilterWidgetState createState() => _JobFilterWidgetState();
}

class _JobFilterWidgetState extends State<JobFilterWidget> {
  List<Job> _jobs = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument; // for pagination
  bool _hasMoreJobs = true;

  String _selectedSortField = 'Wage'; // User's choice for sort field
  String _selectedSortOrder =
      'High to Low'; // Sort order (for wage or duration)

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  // Fetch jobs with pagination based on selected sort field
  Future<void> _fetchJobs() async {
    if (_isLoading || !_hasMoreJobs) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('jobs')
          .limit(10); // Fetch 10 jobs per page

      // Apply sorting based on selected field
      if (_selectedSortField == 'Wage') {
        query = _selectedSortOrder == 'High to Low'
            ? query.orderBy('wagePerDay', descending: true)
            : query.orderBy('wagePerDay');
      } else if (_selectedSortField == 'Duration') {
        query = _selectedSortOrder == 'High to Low'
            ? query.orderBy('duration', descending: true)
            : query.orderBy('duration');
      }

      // Pagination
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // Fetch data
      QuerySnapshot snapshot = await query.get();

      print("Fetched ${snapshot.docs.length} jobs."); // Debugging log

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _lastDocument = snapshot.docs.last;
          _hasMoreJobs = snapshot.docs.length == 10;
          _jobs.addAll(snapshot.docs
              .map((doc) =>
                  Job.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
        });

        print("Jobs after sorting: ${_jobs.length}"); // Debugging log
      } else {
        print("No jobs found."); // Debugging log
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Refactor the dropdowns to call _fetchJobs() after each filter change
  void _onSortFieldChanged(String? newValue) {
    setState(() {
      _selectedSortField = newValue!;
      _jobs.clear(); // Clear the list for the new sort field
      _lastDocument = null; // Reset pagination
      _hasMoreJobs = true; // Reset pagination flag
    });
    _fetchJobs(); // Refetch jobs after state update
  }

  void _onSortOrderChanged(String? newValue) {
    setState(() {
      _selectedSortOrder = newValue!;
      _jobs.clear(); // Clear the list for the new sort order
      _lastDocument = null; // Reset pagination
      _hasMoreJobs = true; // Reset pagination flag
    });
    _fetchJobs(); // Refetch jobs after state update
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Sort Options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sort Field Dropdown (Wage or Duration)
                DropdownButton<String>(
                  value: _selectedSortField,
                  onChanged: _onSortFieldChanged,
                  items: ['Wage', 'Duration']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                // Sort Order Dropdown (High to Low or Low to High)
                DropdownButton<String>(
                  value: _selectedSortOrder,
                  onChanged: _onSortOrderChanged,
                  items: ['High to Low', 'Low to High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Job List
          _isLoading && _jobs.isEmpty
              ? Center(child: CircularProgressIndicator())
              : _jobs.isEmpty
                  ? Center(child: Text('No jobs found'))
                  : ListView.builder(
                      shrinkWrap:
                          true, // Ensures ListView doesn't take more space than needed
                      physics:
                          NeverScrollableScrollPhysics(), // Prevent scrolling here as it's inside a scroll view
                      itemCount: _jobs.length + (_hasMoreJobs ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _jobs.length) {
                          // Show loader at the bottom when more jobs are being fetched
                          _fetchJobs();
                          return Center(child: CircularProgressIndicator());
                        }
                        final job = _jobs[index];
                        return GestureDetector(
                          onTap: () async {
                            try {
                              // Fetch the current user's ID
                              String currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;

                              // Fetch the user's data from Firestore
                              DocumentSnapshot userSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUserId)
                                      .get();

                              if (userSnapshot.exists) {
                                // Convert the Firestore data to an AppUser object using the fromFirestore method
                                AppUser worker = AppUser.fromFirestore(
                                    userSnapshot.data() as Map<String, dynamic>,
                                    currentUserId);

                                // Ensure job.id is treated as a string
                                String jobId = job
                                    .id; // Correctly treat job.id as a string

                                // Check the user's role and navigate to the appropriate screen
                                if (worker.role == 'employer') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EmployerJobDetailsScreen(
                                              jobId: jobId),
                                    ),
                                  );
                                } else if (worker.role == 'worker') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WorkerJobDetailsScreen(jobId: jobId),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Only employers can view job details.')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('User data not found.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? Colors.blueAccent
                                  : Colors.lightBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.jobTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  job.jobDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Wage per Day: Rs.${job.wagePerDay}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Duration: ${job.duration} days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
