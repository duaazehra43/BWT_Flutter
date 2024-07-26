import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_6_e_commerce_app/LoginScreen.dart';

class DashboardViewModel extends ChangeNotifier {
  final User user;
  bool hasStore = false;
  bool isStoreVerified = false;
  String? userName;
  String? userEmail;
  String? userRole;
  List<DocumentSnapshot> items = [];

  DashboardViewModel({required this.user}) {
    // Initial fetch
    checkStoreStatus();
  }

  Future<void> checkStoreStatus() async {
    try {
      // Fetch store status from Firestore
      final storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(user.uid)
          .get();

      if (storeDoc.exists) {
        hasStore = true;
        isStoreVerified = storeDoc['isActive'] ?? false;
      } else {
        hasStore = false;
        isStoreVerified = false;
      }

      // Fetch user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      userName = userDoc['name'];
      userEmail = userDoc['email'];
      userRole = userDoc['role'];

      notifyListeners(); // Notify listeners of state changes
    } catch (e) {
      print("Error checking store status: $e");
      // Handle error appropriately
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<void> fetchItems({String? category}) async {
    try {
      QuerySnapshot snapshot = category == null
          ? await FirebaseFirestore.instance
              .collection('items')
              .where('storeId', isEqualTo: user.uid)
              .get()
          : await FirebaseFirestore.instance
              .collection('items')
              .where('storeId', isEqualTo: user.uid)
              .where('category', isEqualTo: category)
              .get();

      items = snapshot.docs; // Use DocumentSnapshot directly
      notifyListeners();
    } catch (e) {
      print("Error fetching items: $e");
      // Handle error appropriately
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
      items.removeWhere(
          (item) => item.id == itemId); // Check item.id instead of item['id']
      notifyListeners();
    } catch (e) {
      print("Error deleting item: $e");
      // Handle error appropriately
    }
  }
}
