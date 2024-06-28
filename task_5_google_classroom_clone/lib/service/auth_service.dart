import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(
      String email, String password, String name, String role) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();

      DocumentReference userDocRef =
          _firestore.collection('users').doc(userCredential.user!.uid);
      if (!(await userDocRef.get()).exists) {
        await userDocRef.set({
          'name': name,
          'email': email,
          'role': role,
          'emailVerified': false,
        });
      }

      return userCredential.user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      throw e; // Propagate exception for handling in UI
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      throw e; // Propagate exception for handling in UI
    }
  }

  Stream<User?> get currentUser => _auth.authStateChanges();

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e; // You can handle the error appropriately
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc
            .get('role'); // Assuming 'role' is stored in the user document
      } else {
        return 'Unknown'; // Handle the case where role is not found
      }
    } catch (e) {
      print('Error getting user role: $e');
      return 'Error'; // Handle error scenario
    }
  }
}
