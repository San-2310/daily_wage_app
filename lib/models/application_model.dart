import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id; // ID of the application
  final String workerId;
  final String jobId; // ID of the job the application belongs to
  final String status; // "applied", "accepted", "rejected"
  final DateTime appliedAt; // Timestamp for when the application was created

  Application({
    required this.id,
    required this.workerId,
    required this.jobId,
    this.status = 'applied',
    DateTime? appliedAt,
  }) : appliedAt = appliedAt ?? DateTime.now();

  // Convert Firestore document to Application
  factory Application.fromFirestore(Map<String, dynamic> data, String id) {
    return Application(
      id: id,
      workerId: data['workerId'] ?? '',
      jobId: data['jobId'] ?? '',
      status: data['status'] ?? 'applied',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Application to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'workerId': workerId,
      'jobId': jobId,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }
}
