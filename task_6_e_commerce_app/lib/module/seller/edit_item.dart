import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';

class EditItemScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String itemId;

  EditItemScreen({required this.itemData, required this.itemId});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String _category = 'Tshirts'; // Default category
  Map<String, TextEditingController> _sizeControllers = {};
  List<File> _images = [];
  List<String> _imageUrls = [];

  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemData['name']);
    _priceController =
        TextEditingController(text: widget.itemData['price'].toString());
    _category = widget.itemData['category'];
    _imageUrls = List<String>.from(widget.itemData['imageUrls']);

    // Initialize size controllers with existing data
    Map<String, dynamic> sizes = widget.itemData['sizes'] ?? {};
    sizes.forEach((size, quantity) {
      _sizeControllers[size] = TextEditingController(text: quantity.toString());
    });
  }

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

  Future<void> _updateItem() async {
    try {
      if (_images.isNotEmpty) {
        for (var image in _images) {
          Reference storageReference =
              _storage.ref().child('images/${Path.basename(image.path)}');
          await storageReference.putFile(image);
          String imageUrl = await storageReference.getDownloadURL();
          _imageUrls.add(imageUrl);
        }
      }

      Map<String, int> sizes = {};
      _sizeControllers.forEach((size, controller) {
        sizes[size] = int.parse(controller.text);
      });

      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.itemId)
          .update({
        'imageUrls': _imageUrls,
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'sizes': sizes,
        'category': _category,
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error updating item: $e');
      // Handle error, e.g., show a snackbar with the error message
    }
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      List<XFile>? pickedImages = await _imagePicker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        setState(() {
          _images = pickedImages.map((XFile file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      print('Error picking images: $e');
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
                        fontWeight: FontWeight.bold,
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
                        fontWeight: FontWeight.bold,
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

  void _removeImage(int index, {bool isExisting = false}) {
    setState(() {
      if (isExisting) {
        _imageUrls.removeAt(index);
      } else {
        _images.removeAt(index);
      }
    });
  }

  List<Widget> _buildSizeInputs() {
    List<String> sizes;
    if (_category == 'Shoes') {
      sizes = ['6', '7', '8', '9', '10'];
    } else {
      sizes = ['S', 'M', 'L'];
    }

    return sizes.map((size) {
      if (!_sizeControllers.containsKey(size)) {
        _sizeControllers[size] = TextEditingController();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Card(
          color: Colors.white,
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: _sizeControllers[size],
              decoration: InputDecoration(
                  labelText: 'Quantity for size $size',
                  border: InputBorder.none),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity for size $size.';
                }
                final int? quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity.';
                }
                return null;
              },
            ),
          ),
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
          'Edit Item',
          style: GoogleFonts.inter(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Card(
                  elevation: 3.0,
                  color: Colors.white,
                  child: _images.isNotEmpty
                      ? Container(
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
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: Icon(Icons.remove_circle),
                                      color: Colors.red,
                                      onPressed: () {
                                        _removeImage(index);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : _imageUrls.isNotEmpty
                          ? Container(
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
                                        top: 5,
                                        right: 5,
                                        child: IconButton(
                                          icon: Icon(Icons.remove_circle),
                                          color: Colors.red,
                                          onPressed: () {
                                            _removeImage(index,
                                                isExisting: true);
                                          },
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
                              child: Icon(Icons.add_a_photo, size: 50),
                            ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      border: InputBorder.none,
                    ),
                    validator: _validateName,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      hintText: 'Price',
                      border: InputBorder.none,
                    ),
                    validator: _validatePrice,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: InputBorder.none,
                    ),
                    items: <String>['Tshirts', 'Jeans', 'Shoes']
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _category = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),
              ..._buildSizeInputs(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateItem,
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.inter(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
