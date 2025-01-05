import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<String?> signUp(
    String email,
    String password,
    String name,
    String phone,
    String role,
    String location, // Location as a string (could be address or geolocation)
  ) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After user is created, add details to Firestore
      String userId = userCredential.user!.uid;

      AppUser newUser = AppUser(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        location: location,
        averageRating: 0.0,
        ratingCount: 0,
      );

      // Save the user data in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .set(newUser.toFirestore());

      return null; // Successful sign-up
    } catch (e) {
      print("SignUp Error: $e");
      return e.toString(); // Return error message if sign-up fails
    }
  }

  // Login with email and password
  Future<String?> login(String email, String password) async {
    try {
      // Sign in the user with email and password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Successful login
    } catch (e) {
      print("Login Error: $e");
      return e.toString(); // Return error message if login fails
    }
  }

  // Log out the user
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // Get the current user
  Future<AppUser?> getCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return AppUser.fromFirestore(
            userDoc.data() as Map<String, dynamic>, user.uid);
      }
    }
    return null;
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } catch (e) {
      print("Reset Password Error: $e");
      return e.toString(); // Return error message
    }
  }
}
