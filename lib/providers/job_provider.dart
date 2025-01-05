import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/job_model.dart';

class JobProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  Map<String, int> _applicationsCount = {};

  List<Job> get jobs => _jobs;
  Map<String, int> get applicationsCount => _applicationsCount;

  JobProvider() {
    _listenToJobs();
  }

  void _listenToJobs() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('jobs')
        .where('employerId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      _jobs = snapshot.docs
          .map((doc) =>
              Job.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _updateApplicationCounts();
      notifyListeners();
    });
  }

  void _updateApplicationCounts() {
    for (final job in _jobs) {
      FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: job.id)
          .where('status', isEqualTo: 'applied')
          .snapshots()
          .listen((snapshot) {
        _applicationsCount[job.id] = snapshot.docs.length;
        notifyListeners();
      });
    }
  }
}
