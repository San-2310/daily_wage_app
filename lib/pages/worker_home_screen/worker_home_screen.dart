import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_wage_app/localization/locales.dart';
import 'package:daily_wage_app/pages/notification_screen/notification_screen.dart';
import 'package:daily_wage_app/pages/worker_job_screen/worker_job_details_screen.dart';
import 'package:daily_wage_app/pages/worker_job_screen/worker_job_listings_screen.dart';
import 'package:daily_wage_app/widgets/all_job_fliter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Fetch user name
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
    final user = FirebaseAuth.instance.currentUser;

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
          LocaleData.title.getString(context),
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
                  Expanded(
                    child: Text(
                      context.formatString(LocaleData.hey, [_userName]),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      LocaleData.empowerWork.getString(context),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 24,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      LocaleData.yourApplications.getString(context),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerJobListScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            LocaleData.viewAll.getString(context),
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
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Using StreamBuilder to listen to real-time updates
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('workerId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData ||
                      snapshot.data?.docs.isEmpty == true) {
                    return Stack(
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
                          left: 50,
                          right: 50,
                          top: 50,
                          bottom: 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                LocaleData.noApplicationsYet.getString(context),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                              Text(
                                LocaleData.startApplyingNow.getString(context),
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Show applications with job details in horizontal scrolling cards
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        final application = snapshot.data!.docs[index].data()
                            as Map<String,
                                dynamic>; // Cast to Map<String, dynamic>
                        final jobId = application['jobId'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('jobs')
                              .doc(jobId)
                              .get(),
                          builder: (context, jobSnapshot) {
                            if (jobSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (jobSnapshot.hasData) {
                              final jobData = jobSnapshot.data!.data() as Map<
                                  String,
                                  dynamic>; // Cast to Map<String, dynamic>
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
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 163, 128, 244),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          jobData['jobTitle'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          application['status'],
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleData.allJobListings.getString(context),
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
                  Expanded(
                    child: Text(
                      LocaleData.sortBy.getString(context),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              JobFilterWidget(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
