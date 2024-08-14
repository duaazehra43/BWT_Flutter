import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditDonationViewModel extends ChangeNotifier {
  final User user;
  final String donationId;
  String foodItems = '';
  int quantity = 0;
  bool isAvailable = true;
  TimeOfDay pickupTime = TimeOfDay.now();
  bool isLoading = true;

  EditDonationViewModel({required this.user, required this.donationId}) {
    _loadDonationData();
  }

  Future<void> _loadDonationData() async {
    try {
      isLoading = true;
      notifyListeners();

      DocumentSnapshot donation = await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .get();

      if (donation.exists) {
        Map<String, dynamic> data = donation.data() as Map<String, dynamic>;
        foodItems = data['foodItems'] ?? '';
        quantity = data['quantity'] ?? 0;
        isAvailable = data['isAvailable'] ?? true;
        Timestamp timestamp = data['pickupTime'];
        DateTime dateTime = timestamp.toDate();
        pickupTime = TimeOfDay.fromDateTime(dateTime);
      }
    } catch (e) {
      print("Error loading donation data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: pickupTime,
    );
    if (picked != null && picked != pickupTime) {
      pickupTime = picked;
      notifyListeners();
    }
  }

  Future<bool> updateDonation() async {
    try {
      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .update({
        'foodItems': foodItems,
        'quantity': quantity,
        'isAvailable': isAvailable,
        'pickupTime': DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickupTime.hour,
          pickupTime.minute,
        ),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error updating donation: $e");
      return false;
    }
  }
}
