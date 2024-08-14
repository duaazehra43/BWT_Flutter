// donation_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DonationProvider extends ChangeNotifier {
  final User user;
  List<QueryDocumentSnapshot> _donations = [];
  bool _isLoading = false;
  String? _error;

  DonationProvider(this.user) {
    _fetchDonations();
  }

  List<QueryDocumentSnapshot> get donations => _donations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _fetchDonations() {
    _isLoading = true;
    notifyListeners();

    FirebaseFirestore.instance
        .collection('donations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _donations = snapshot.docs;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addDonation(Map<String, dynamic> donationData) async {
    try {
      await FirebaseFirestore.instance
          .collection('donations')
          .add(donationData);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> editDonation(
      String donationId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .update(newData);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDonation(String donationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .delete();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
