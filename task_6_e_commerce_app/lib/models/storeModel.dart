import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String storeName;
  final String description;
  final String address;
  final String email;
  final String image;
  final String phone;
  final bool isActive;
  final bool isBanned;

  StoreModel({
    required this.id,
    required this.storeName,
    required this.description,
    required this.address,
    required this.email,
    required this.image,
    required this.phone,
    required this.isActive,
    required this.isBanned,
  });

  factory StoreModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: doc.id,
      storeName: data['storeName'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      image: data['image'] ?? '',
      phone: data['phone'] ?? '',
      isActive: data['isActive'] ?? false,
      isBanned: data['isBanned'] ?? false,
    );
  }
}
