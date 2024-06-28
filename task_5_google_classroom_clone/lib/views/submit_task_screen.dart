import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_5_google_classroom_clone/model/task_model.dart';
import 'package:task_5_google_classroom_clone/service/task_service.dart';
import 'package:task_5_google_classroom_clone/view_model/submit_task_view_model.dart';

class SubmitTaskScreen extends StatefulWidget {
  final TaskModel task;

  SubmitTaskScreen(this.task);

  @override
  _SubmitTaskScreenState createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  final TextEditingController _submissionTextController =
      TextEditingController();
  final SubmitTaskViewModel _viewModel = SubmitTaskViewModel();
  final TaskService _taskService = TaskService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? _submissionFileUrl;
  String? _fileName;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isUploading = true;
    });

    XFile? pickedImage = await _viewModel.pickImage(source);
    if (pickedImage != null) {
      await _viewModel.uploadFile(pickedImage);
      setState(() {
        _fileName = pickedImage.name;
        _isUploading = false;
        _submissionFileUrl = _viewModel.fileUrl; // Set the file URL
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
        _fileName = pickedFile.path.split('/').last;
        _isUploading = false;
        _submissionFileUrl = _viewModel.fileUrl; // Set the file URL
      });
    } else {
      setState(() {
        _isUploading = false;
      });
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

  Future<void> _submitTask() async {
    if (_submissionTextController.text.isEmpty) {
      return; // Exit if submission text is empty
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String userEmail = _auth.currentUser?.email ?? 'Unknown';

      String taskId = widget.task.id;
      String submissionText = _submissionTextController.text;

      Map<String, dynamic> submissionData = {
        'studentEmail': userEmail,
        'taskId': taskId,
        'submissionText': submissionText,
      };

      if (_fileName != null && _viewModel.fileUrl != null) {
        submissionData['fileUrl'] = _viewModel.fileUrl;
      }

      await _taskService.submitTask(submissionData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.purple,
          content: Text(
            "Submitted Successfully",
            style: GoogleFonts.lato(color: Colors.white),
          )));
    } catch (e) {
      print('Error submitting task: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'Submit Task',
          style: GoogleFonts.lato(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.task.title,
                style:
                    GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: ListTile(
                title: Text(_fileName ?? 'No file selected'),
                trailing: _isUploading
                    ? CircularProgressIndicator()
                    : Icon(Icons.file_upload),
                onTap: _showImageSourceDialog,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _submissionTextController,
              decoration: InputDecoration(
                labelText: 'Your Submission',
                labelStyle: GoogleFonts.lato(),
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitTask,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: Text(
                  'Submit',
                  style: GoogleFonts.lato(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _submissionTextController.dispose();
    super.dispose();
  }
}
