import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RDonationProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> donations = [];
  bool isLoading = true;
  String? error;

  Future<void> fetchDonations() async {
    isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .where('isAvailable', isEqualTo: true)
          .get();

      List<QueryDocumentSnapshot> validDonations = [];

      for (var doc in querySnapshot.docs) {
        Timestamp pickupTime = doc['pickupTime'];
        DateTime currentTime = DateTime.now();

        if (pickupTime.toDate().isAfter(currentTime)) {
          validDonations.add(doc);
        } else {
          await FirebaseFirestore.instance
              .collection('donations')
              .doc(doc.id)
              .update({
            'isAvailable': false,
            'isExpired': true,
          });
        }
      }

      donations = validDonations;
      error = null;
    } catch (e) {
      error = e.toString();
      donations = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> schedulePickup(
      String donationId, String id, Map<String, dynamic> donationData) async {
    try {
      await FirebaseFirestore.instance.collection('scheduledPickups').add({
        'donationId': donationId,
        'userId': donationData['userId'],
        'foodItems': donationData['foodItems'],
        'quantity': donationData['quantity'],
        'pickupTime': donationData['pickupTime'],
        'scheduledAt': FieldValue.serverTimestamp(),
        'receiverId': id,
      });

      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .update({'isAvailable': false});

      return true;
    } catch (e) {
      print('Error scheduling pickup: $e');
      return false;
    }
  }
}
