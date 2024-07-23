import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_6_e_commerce_app/models/storeModel.dart';

class AdminViewModel extends ChangeNotifier {
  List<StoreModel> _stores = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> fetchStores() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('stores').get();
      _stores = querySnapshot.docs
          .map((doc) => StoreModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _hasError = true;
      print('Error fetching stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreStatus(String storeId, bool isActive) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .update({'isActive': isActive});
      print('Store status updated to $isActive');
      await fetchStores(); // Refresh store list after update
    } catch (e) {
      print('Error updating store status: $e');
    }
  }

  Future<void> banStore(String storeId, bool isBanned) async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .update({'isBanned': isBanned});
      print('Store banned status updated to $isBanned');
      await fetchStores(); // Refresh store list after update
    } catch (e) {
      print('Error banning store: $e');
    }
  }
}
