import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

class EditStoreScreen extends StatefulWidget {
  final String userId;

  EditStoreScreen(this.userId);

  @override
  _EditStoreScreenState createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final picker = ImagePicker();
  List<File> _images = [];
  List<String> _imageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadStoreDetails();
  }

  Future<void> _loadStoreDetails() async {
    try {
      DocumentSnapshot storeSnapshot =
          await _firestore.collection('stores').doc(widget.userId).get();
      if (storeSnapshot.exists) {
        Map<String, dynamic> data =
            storeSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _storeNameController.text = data['storeName'];
          _descriptionController.text = data['description'];
          _emailController.text = data['email'];
          _phoneController.text = data['phone'];
          _addressController.text = data['address'];
          _imageUrls = List<String>.from(data['images']);
        });
      }
    } catch (e) {
      print('Error loading store details: $e');
    }
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      final file = File(image.path);
      final storageRef =
          _storage.ref().child('store_images/${Path.basename(image.path)}');
      final uploadTask = await storageRef.putFile(file);
      final imageUrl = await uploadTask.ref.getDownloadURL();
      setState(() {
        _images.add(file);
        _imageUrls.add(imageUrl); // Save the image URL after successful upload
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? pickedImage = await _imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        await _uploadImageToFirebase(File(pickedImage.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _removeImage(int index) async {
    try {
      final image = _images[index];
      final storageRef =
          _storage.ref().child('store_images/${Path.basename(image.path)}');
      await storageRef.delete();
      setState(() {
        _images.removeAt(index);
        _imageUrls.removeAt(index); // Remove the image URL from the list
      });
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  Future<void> _updateStore() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update the store document in Firestore with the new details
        await _firestore.collection('stores').doc(widget.userId).update({
          'storeName': _storeNameController.text,
          'description': _descriptionController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'images': _imageUrls, // Save the list of image URLs
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store updated successfully')),
        );

        // Clear the form fields after successful update
        _storeNameController.clear();
        _descriptionController.clear();
        _emailController.clear();
        _phoneController.clear();
        _addressController.clear();
        setState(() {
          _images.clear();
          _imageUrls.clear();
        });

        // Navigate back to HomeScreenDashboard
        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating store: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating store')),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Choose Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Colors.black),
                    const SizedBox(width: 10.0),
                    Text(
                      'From Gallery',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.camera,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      'From Camera',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Store Details',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Logo',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Card(
                    elevation: 3.0,
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: _imageUrls.isNotEmpty
                          ? SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          _imageUrls[index],
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () => _removeImage(index),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            )
                          : Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.add_a_photo, size: 50),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Store Name',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter store name',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter store name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter description',
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter email',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Phone',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: 'Enter phone',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Address',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'Enter address',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: Text(
                      'Update Store',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
