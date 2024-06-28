import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_5_google_classroom_clone/view_model/add_outline_view_model.dart';

class AddOutlineScreen extends StatefulWidget {
  final String courseId;

  AddOutlineScreen(this.courseId);

  @override
  _AddOutlineScreenState createState() => _AddOutlineScreenState();
}

class _AddOutlineScreenState extends State<AddOutlineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AddOutlineViewModel _viewModel = AddOutlineViewModel();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isUploading = true;
    });

    XFile? pickedImage = await _viewModel.pickImage(source);
    if (pickedImage != null) {
      await _viewModel.uploadFile(pickedImage);
      setState(() {
        _viewModel.fileName = pickedImage.name;
        _isUploading = false;
      });
    } else {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _isUploading = true;
    });

    File? pickedFile = await _viewModel.pickFile();
    if (pickedFile != null) {
      await _viewModel.uploadFile(pickedFile);
      setState(() {
        _viewModel.fileName = pickedFile.path.split('/').last;
        _isUploading = false;
      });
    } else {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveOutline() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        await _viewModel.saveOutline(
          widget.courseId,
          _titleController.text,
          _descriptionController.text,
        );
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create outline: $e'),
          ),
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
          title: Text(
            'Choose Source',
            style: GoogleFonts.lato(color: Colors.purple),
          ),
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
                      style: GoogleFonts.lato(
                          color: Colors.black, fontWeight: FontWeight.bold),
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
                    Text('From Camera',
                        style: GoogleFonts.lato(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickFile();
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10.0),
                    Text('From Files',
                        style: GoogleFonts.lato(
                            color: Colors.black, fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'Add Outline',
          style: GoogleFonts.lato(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: GoogleFonts.lato(),
                    border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.lato(),
                    border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(_viewModel.fileName ?? 'No file selected'),
                  trailing: _isUploading
                      ? CircularProgressIndicator()
                      : Icon(Icons.file_upload),
                  onTap: _showImageSourceDialog,
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: _isUploading ? null : _saveOutline,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: Text(
                  'Save Outline',
                  style: GoogleFonts.lato(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
