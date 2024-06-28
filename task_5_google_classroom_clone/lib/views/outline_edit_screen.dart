import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/model/outline_model.dart';
import 'package:task_5_google_classroom_clone/view_model/course_detail_view_model.dart';

class OutlineEditScreen extends StatefulWidget {
  final OutlineModel outline;
  final CourseDetailViewModel viewModel;

  OutlineEditScreen({required this.outline, required this.viewModel});

  @override
  _OutlineEditScreenState createState() => _OutlineEditScreenState();
}

class _OutlineEditScreenState extends State<OutlineEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.outline.title);
    _descriptionController =
        TextEditingController(text: widget.outline.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Outline',
          style: GoogleFonts.lato(),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: GoogleFonts.lato(),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: GoogleFonts.lato(),
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateTask,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: Text(
                  'Update Outline',
                  style: GoogleFonts.lato(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTask() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    widget.viewModel.updateOutline(widget.outline.id, {
      'title': title,
      'description': description,
    }).then((_) {
      Navigator.pop(context); // Return to previous screen after update
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update outline: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
