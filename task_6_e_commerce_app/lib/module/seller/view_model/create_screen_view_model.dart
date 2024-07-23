import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

class StoreViewModel extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  File? _image;
  String? _imageUrl;

  File? get image => _image;
  String? get imageUrl => _imageUrl;

  Future<void> uploadImageToFirebase(File image) async {
    try {
      final file = File(image.path);
      final storageRef =
          _storage.ref().child('store_images/${Path.basename(image.path)}');
      final uploadTask = await storageRef.putFile(file);
      final imageUrl = await uploadTask.ref.getDownloadURL();
      _image = file;
      _imageUrl = imageUrl;
      notifyListeners();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      XFile? pickedImage = await _imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        await uploadImageToFirebase(File(pickedImage.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> removeImage() async {
    try {
      if (_image != null) {
        final storageRef =
            _storage.ref().child('store_images/${Path.basename(_image!.path)}');
        await storageRef.delete();
        _image = null;
        _imageUrl = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  Future<void> createStore({
    required String userId,
    required String storeName,
    required String description,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      await _firestore.collection('stores').doc(userId).set({
        'storeName': storeName,
        'description': description,
        'email': email,
        'phone': phone,
        'address': address,
        'image': _imageUrl,
      });
      notifyListeners();
    } catch (e) {
      print('Error creating store: $e');
    }
  }
}
