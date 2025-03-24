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
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );

      // Get FCM token and save with user info
      await _updateUserFCMToken(userCredential.user!.uid, email);
      
      return userCredential;
    } on FirebaseAuthException catch(e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      //create user
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Get FCM token and save with user info
      await _updateUserFCMToken(userCredential.user!.uid, email);

      return userCredential;
    } on FirebaseAuthException catch(e) {
      throw Exception(e.code);
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
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to delete account');
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
          // Save user info with FCM token
          await firestore.collection("Users").doc(uid).set(
            {
              'uid': uid,
              'email': email,
              'fcmToken': token,
            },
            SetOptions(merge: true), // This ensures we don't overwrite existing data
          );
        }
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
