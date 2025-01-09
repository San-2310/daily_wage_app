import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rating_model.dart';

class RatingServices {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a Rating for a job (either worker or employer)
  // Add or update a Rating for a job (either worker or employer)
  Future<String?> addOrUpdateRating(Rating rating) async {
    try {
      // Check if a rating already exists for this combination
      QuerySnapshot existingRatingSnapshot = await _firestore
          .collection('ratings')
          .where('raterId', isEqualTo: rating.raterId)
          .where('ratedId', isEqualTo: rating.ratedId)
          .where('jobId', isEqualTo: rating.jobId)
          .get();

      if (existingRatingSnapshot.docs.isNotEmpty) {
        // If a rating exists, update it
        DocumentSnapshot existingRatingDoc = existingRatingSnapshot.docs.first;
        String ratingId = existingRatingDoc.id;

        await _firestore
            .collection('ratings')
            .doc(ratingId)
            .update(rating.toFirestore());
        print("Rating updated");

        // Recalculate average rating and rating count
        await updateAverageRating(rating.ratedId);
        await updateRatingCount(rating.ratedId);

        return null; // Success
      } else {
        // If no rating exists, add a new rating
        await _firestore.collection('ratings').add(rating.toFirestore());
        print("Rating added");

        // Recalculate average rating and rating count
        await updateAverageRating(rating.ratedId);
        await updateRatingCount(rating.ratedId);

        return null; // Success
      }
    } catch (e) {
      print("Add/Update Rating Error: $e");
      return e.toString(); // Return error message if failed
    }
  }

  // Update the rating count in Firestore
  Future<void> updateRatingCount(String userId) async {
    try {
      // Fetch all ratings for the user
      QuerySnapshot ratingSnapshot = await _firestore
          .collection('ratings')
          .where('ratedId', isEqualTo: userId)
          .get();

      // Update the rating count
      await _firestore.collection('users').doc(userId).update({
        'ratingCount': ratingSnapshot.docs.length,
      });
    } catch (e) {
      print("Update Rating Count Error: $e");
    }
  }

  // Update the average rating for a specific user
  // Update the average rating for a specific user
  Future<void> updateAverageRating(String userId) async {
    try {
      // Fetch all ratings for the user
      QuerySnapshot ratingSnapshot = await _firestore
          .collection('ratings')
          .where('ratedId', isEqualTo: userId)
          .get();

      if (ratingSnapshot.docs.isEmpty) {
        // If no ratings, set average to 0
        await _firestore.collection('users').doc(userId).update({
          'averageRating': 0.0,
        });
        return;
      }

      double totalRating = 0;
      for (var doc in ratingSnapshot.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'];
      }

      double averageRating = totalRating / ratingSnapshot.docs.length;

      // Round the average rating to 2 decimal places
      double roundedAverageRating =
          double.parse(averageRating.toStringAsFixed(2));

      // Update the user's average rating in Firestore
      await _firestore.collection('users').doc(userId).update({
        'averageRating': roundedAverageRating,
      });
    } catch (e) {
      print("Update Average Rating Error: $e");
    }
  }
}
