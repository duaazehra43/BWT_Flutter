import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatefulWidget {
  final String storeId;

  AddItemScreen({required this.storeId});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _category = 'Tshirts'; // Default category
  List<File> _images = [];
  final picker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // For size and quantity
  final Map<String, TextEditingController> _sizeControllers = {};

  // Validators for form fields
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the name of the item.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the price of the item.';
    }
    final double? price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price.';
    }
    return null;
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      final file = File(image.path);
      final storageRef =
          _storage.ref().child('items/${Path.basename(image.path)}');
      await storageRef.putFile(file);
      print('Image uploaded: ${Path.basename(image.path)}');
      setState(() {
        _images.add(file);
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _uploadImagesToFirebase(List<XFile> images) async {
    try {
      for (var image in images) {
        final file = File(image.path);
        final storageRef =
            _storage.ref().child('images/${Path.basename(image.path)}');
        await storageRef.putFile(file);
        print('Image uploaded: ${Path.basename(image.path)}');
        _images.add(file);
      }
      setState(() {});
    } catch (e) {
      print('Error uploading images: $e');
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

  Future<void> _pickImages(ImageSource source) async {
    try {
      List<XFile>? pickedImages = await _imagePicker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        await _uploadImagesToFirebase(pickedImages);
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> _removeImage(int index) async {
    try {
      final image = _images[index];
      final storageRef =
          _storage.ref().child('images/${Path.basename(image.path)}');
      await storageRef.delete();

      setState(() {
        _images.removeAt(index);
      });
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<String> imageUrls = [];
        if (_images.isNotEmpty) {
          for (var image in _images) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('images/${Path.basename(image.path)}');
            UploadTask uploadTask = storageReference.putFile(image);
            await uploadTask.whenComplete(() async {
              String imageUrl = await storageReference.getDownloadURL();
              imageUrls.add(imageUrl);
            });
          }
        } else {
          print('No images selected.');
        }

        Map<String, int> sizes = {};
        _sizeControllers.forEach((key, controller) {
          int? quantity = int.tryParse(controller.text);
          if (quantity != null && quantity > 0) {
            sizes[key] = quantity;
          }
        });

        await FirebaseFirestore.instance.collection('items').add({
          'imageUrls': imageUrls,
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'category': _category,
          'sizes': sizes,
          'storeId': widget.storeId,
        });

        Navigator.pop(context);
      } catch (e) {
        print('Error saving item: $e');
      }
    } else {
      print('Form is not valid.');
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Choose Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
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
                  _pickImages(ImageSource.camera);
                },
                child: Row(
                  children: [
                    const Icon(Icons.camera, color: Colors.black),
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

  List<Widget> _buildSizeInputs() {
    List<String> sizes = [];
    if (_category == 'Tshirts' || _category == 'Jeans') {
      sizes = ['S', 'M', 'L'];
    } else if (_category == 'Shoes') {
      sizes = ['6', '7', '8', '9', '10'];
    }

    return sizes.map((size) {
      if (!_sizeControllers.containsKey(size)) {
        _sizeControllers[size] = TextEditingController();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text('Size $size:'),
            const SizedBox(width: 10.0),
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _sizeControllers[size],
                    decoration: const InputDecoration(
                        hintText: 'Quantity', border: InputBorder.none),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Add Item',
          style: GoogleFonts.inter(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 3.0,
                color: Colors.white,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: _images.isNotEmpty
                      ? SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.file(
                                      _images[index],
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
              const SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        hintText: 'Name', border: InputBorder.none),
                    validator: _validateName,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                        hintText: 'Price', border: InputBorder.none),
                    validator: _validatePrice,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: _category,
                    onChanged: (newValue) {
                      setState(() {
                        _category = newValue!;
                        _sizeControllers.clear();
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: 'Category', border: InputBorder.none),
                    items: ['Tshirts', 'Jeans', 'Shoes'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ..._buildSizeInputs(),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
