import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  //instance of auth & firestore
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //get current user
  User? getCurrentUser() {
    return auth.currentUser;
  }

  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      // Get FCM token and save with user info
      await _updateUserFCMToken(userCredential.user!.uid, email);
      
      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getErrorMessage(e));
      } else {
        throw Exception('An unexpected error occurred');
      }
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      // Create user
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Get user info
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Get FCM token and save with user info
      await _updateUserFCMToken(user.uid, email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  //sign out
  Future<void> signOut() async {
    return await auth.signOut();
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('No user is currently signed in');

      // Delete user from Firestore
      await firestore.collection('Users').doc(user.uid).delete();

      // Delete user from Firebase Auth
      await user.delete();
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw Exception(_getErrorMessage(e));
      } else {
        throw Exception('Failed to delete account');
      }
    }
  }

  // Update user's FCM token in Firestore
  Future<void> _updateUserFCMToken(String uid, String email) async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the FCM token
        String? token = await _firebaseMessaging.getToken();

        if (token != null) {
          // Save user info with FCM token in the exact structure shown
          final userData = {
            'email': email,
            'fcmToken': token,
            'uid': uid,
          };

          await firestore.collection("Users").doc(uid).set(
            userData,
            SetOptions(merge: true),
          );
        }
      }
    } catch (e) {
      print('Error updating FCM token: $e');
      rethrow; // Rethrow to handle in the calling function
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network request failed. Please check your internet connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
