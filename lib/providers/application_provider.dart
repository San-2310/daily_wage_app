import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplicationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _applications = []; // Store applications

  List<Map<String, dynamic>> get applications => _applications;

  // Fetch applications based on jobId
  Future<void> fetchApplications(String jobId) async {
    try {
      QuerySnapshot applicationSnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('status', isEqualTo: 'applied') // Only 'applied' status
          .get();

      _applications = applicationSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      notifyListeners(); // Notify listeners that the data has changed
    } catch (e) {
      print("Error fetching applications: $e");
    }
  }

  // Optionally: Fetch and update specific application data when status changes
  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({'status': status});

      // Optionally re-fetch applications after status update
      notifyListeners();
    } catch (e) {
      print("Error updating application status: $e");
    }
  }
}
