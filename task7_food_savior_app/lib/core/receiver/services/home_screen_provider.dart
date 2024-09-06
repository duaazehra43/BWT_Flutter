import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task7_food_savior_app/core/auth/screens/login.dart';
import 'package:task7_food_savior_app/core/receiver/screens/schedule_pickup.dart';
import 'package:task7_food_savior_app/core/receiver/services/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/utils/extensions/scaffold.dart';

class RHomeScreenProvider with ChangeNotifier {
  final User user;
  String? userName;
  String? userEmail;
  String? userRole;
  bool isLoading = true;
  String? error;

  RHomeScreenProvider(this.user) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        userName = userDoc['name'];
        userEmail = userDoc['email'];
        userRole = userDoc['role'];
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      error = "Error loading user data: $e";
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> schedulePickup(String donationId,
      Map<String, dynamic> donationData, BuildContext context) async {
    final donationProvider =
        Provider.of<RDonationProvider>(context, listen: false);
    final success = await donationProvider.schedulePickup(
        donationId, user.uid, donationData);

    if (success) {
      context.showSnackBar('Pickup scheduled successfully');
      await donationProvider.fetchDonations();
    } else {
      context.showSnackBar('Failed to schedule pickup');
    }
  }

  void navigateToScheduledPickup(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScheduledPickupScreen(user: user)));
  }
}
