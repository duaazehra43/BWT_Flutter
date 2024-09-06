import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddDonationViewModel {
  final User user;
  String foodItems = '';
  int quantity = 0;
  bool isAvailable = true;
  DateTime pickupTime = DateTime.now();
  late DocumentReference docRef;

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

  Future<bool> addDonation(BuildContext context) async {
    try {
      CollectionReference donations =
          FirebaseFirestore.instance.collection('donations');

      if (pickupTime.isBefore(DateTime.now())) {
        throw Exception('Pickup time must be in the future.');
      }

      docRef = await donations.add({
        'userId': user.uid,
        'foodItems': foodItems,
        'quantity': quantity,
        'isAvailable': isAvailable,
        'pickupTime': Timestamp.fromDate(pickupTime),
        'createdAt': FieldValue.serverTimestamp(),
        'isExpired': false,
      });

      await docRef.update({'donationId': docRef.id});

      _scheduleExpirationCheck(docRef.id);

      return true;
    } catch (e) {
      print('Error adding donation: $e');
      return false;
    }
  }

  void _scheduleExpirationCheck(String donationId) {
    Duration timeUntilPickup = pickupTime.difference(DateTime.now());

    Future.delayed(
        timeUntilPickup, () => _checkAndUpdateExpiration(donationId));
  }

  Future<void> _checkAndUpdateExpiration(String donationId) async {
    try {
      DocumentReference donationRef =
          FirebaseFirestore.instance.collection('donations').doc(donationId);
      DocumentSnapshot donationSnapshot = await donationRef.get();

      if (donationSnapshot.exists) {
        Map<String, dynamic> data =
            donationSnapshot.data() as Map<String, dynamic>;

        if (data['isAvailable'] == true && !data['isExpired']) {
          await FirebaseFirestore.instance
              .collection('expiredDonations')
              .add(data);

          await donationRef.update({
            'isAvailable': false,
            'isExpired': true,
          });
        }
      }
    } catch (e) {
      print('Error checking and updating expiration: $e');
    }
  }

  static Future<void> checkAllDonationsForExpiration() async {
    try {
      QuerySnapshot activeDonations = await FirebaseFirestore.instance
          .collection('donations')
          .where('isExpired', isEqualTo: false)
          .where('isAvailable', isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot doc in activeDonations.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp pickupTimestamp = data['pickupTime'];

        if (pickupTimestamp.toDate().isBefore(DateTime.now())) {
          await FirebaseFirestore.instance
              .collection('expiredDonations')
              .add(data);

          await doc.reference.update({
            'isAvailable': false,
            'isExpired': true,
          });
        }
      }
    } catch (e) {
      print('Error checking all donations for expiration: $e');
    }
  }
}
