import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task7_food_savior_app/core/donor/services/donation_provider.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final User user;
  final DonationProvider donationProvider;

  String? userName;
  String? userEmail;
  String? userRole;

  HomeScreenViewModel({required this.user, required this.donationProvider}) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      userName = userDoc['name'];
      userEmail = userDoc['email'];
      userRole = userDoc['role'];
      notifyListeners();
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String date = DateFormat('dd MMM yyyy').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return '$date, $time';
  }

  Future<void> deleteDonation(String donationId) async {
    await donationProvider.deleteDonation(donationId);
    notifyListeners();
  }

  Future<void> refreshDonations() async {
    await donationProvider.refreshDonations();
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
