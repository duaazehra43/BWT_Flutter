import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDonationViewModel {
  final User user;
  String foodItems = '';
  int quantity = 0;
  bool isAvailable = true;
  DateTime pickupTime = DateTime.now();

  AddDonationViewModel({required this.user});

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(pickupTime),
    );
    if (picked != null) {
      pickupTime = DateTime(
        pickupTime.year,
        pickupTime.month,
        pickupTime.day,
        picked.hour,
        picked.minute,
      );
    }
  }

  Future<bool> addDonation() async {
    try {
      CollectionReference donations =
          FirebaseFirestore.instance.collection('donations');
      DocumentReference docRef = await donations.add({
        'userId': user.uid,
        'foodItems': foodItems,
        'quantity': quantity,
        'isAvailable': isAvailable,
        'pickupTime': Timestamp.fromDate(pickupTime),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await docRef.update({'donationId': docRef.id});
      return true;
    } catch (e) {
      print('Error adding donation: $e');
      return false;
    }
  }
}
