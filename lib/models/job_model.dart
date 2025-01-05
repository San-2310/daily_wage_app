import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String jobTitle;
  final String jobDescription;
  final String employerId;
  final String?
      address; // Human-readable address (can be null if geolocation is used)
  final double? latitude; // Nullable for string-only location
  final double? longitude; // Nullable for string-only location
  final int numWorkers;
  final double wagePerDay;
  final int duration;
  final String category;
  final String status; //'active', 'completed', 'canceled'
  final DateTime postedAt; // Timestamp of when the job was posted

  Job({
    required this.id,
    required this.jobTitle,
    required this.jobDescription,
    required this.employerId,
    this.address,
    this.latitude,
    this.longitude,
    required this.numWorkers,
    required this.wagePerDay,
    required this.duration,
    required this.category,
    this.status = 'active',
    DateTime? postedAt,
  }) : postedAt = postedAt ?? DateTime.now();

  // Convert Firestore document to Job
  factory Job.fromFirestore(Map<String, dynamic> data, String id) {
    final location = data['location'] ?? {};
    return Job(
      id: id,
      jobTitle: data['jobTitle'] ?? '',
      jobDescription: data['jobDescription'] ?? '',
      employerId: data['employerId'] ?? '',
      address: location['address'],
      latitude: location['latitude']?.toDouble(),
      longitude: location['longitude']?.toDouble(),
      numWorkers: data['numWorkers'] ?? 0,
      wagePerDay: data['wagePerDay']?.toDouble() ?? 0.0,
      duration: data['duration'] ?? 0,
      category: data['category'] ?? '',
      status: data['status'] ?? 'active',
      postedAt: (data['postedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert Job to Firestore map
  Map<String, dynamic> toFirestore() {
    final location = <String, dynamic>{
      if (address != null) 'address': address,
      if (latitude != null && longitude != null) 'latitude': latitude,
      if (latitude != null && longitude != null) 'longitude': longitude,
    };

    return {
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'employerId': employerId,
      'location': location,
      'numWorkers': numWorkers,
      'wagePerDay': wagePerDay,
      'duration': duration,
      'category': category,
      'status': status,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }
}
