import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String raterId; // The user who is giving the rating
  final String ratedId; // The user who is being rated
  final int rating; // Rating value (1 to 5 stars)
  final String jobId; // Job associated with the rating
  final DateTime ratedAt; // Timestamp of when the rating was given

  Rating({
    required this.raterId,
    required this.ratedId,
    required this.rating,
    required this.jobId,
    required this.ratedAt,
  });

  // Convert Firestore document to Rating
  factory Rating.fromFirestore(Map<String, dynamic> data) {
    return Rating(
      raterId: data['raterId'] ?? '',
      ratedId: data['ratedId'] ?? '',
      rating: data['rating'] ?? 0,
      jobId: data['jobId'] ?? '',
      ratedAt: (data['ratedAt'] as Timestamp).toDate(),
    );
  }

  // Convert Rating to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'raterId': raterId,
      'ratedId': ratedId,
      'rating': rating,
      'jobId': jobId,
      'ratedAt': Timestamp.fromDate(ratedAt),
    };
  }
}
