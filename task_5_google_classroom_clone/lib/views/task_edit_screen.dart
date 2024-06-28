import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/model/task_model.dart';
import 'package:task_5_google_classroom_clone/view_model/course_detail_view_model.dart';

class TaskEditScreen extends StatefulWidget {
  final TaskModel task;
  final CourseDetailViewModel viewModel;

  TaskEditScreen({required this.task, required this.viewModel});

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedDueDate = widget.task.dueDate;
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
      appBar: AppBar(
        title: Text(
          'Edit Task',
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
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: GoogleFonts.lato(),
                border: const OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _selectDueDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  labelStyle: GoogleFonts.lato(),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDueDate != null
                      ? "${_selectedDueDate!.toLocal()}".split(' ')[0]
                      : 'Select date',
                  style: TextStyle(
                    color:
                        _selectedDueDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateTask,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white),
                child: Text(
                  'Update Task',
                  style: GoogleFonts.lato(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate)
      setState(() {
        _selectedDueDate = picked;
      });
  }

  void _updateTask() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    if (_selectedDueDate == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Error',
            style: GoogleFonts.lato(),
          ),
          content: Text('Please select a due date', style: GoogleFonts.lato()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.lato()),
            ),
          ],
        ),
      );
      return;
    }

    DateTime dueDate = _selectedDueDate!;

    // Validate inputs if needed

    widget.viewModel.updateTask(widget.task.id, {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      // Add other fields to update as necessary
    }).then((_) {
      Navigator.pop(context); // Return to previous screen after update
    }).catchError((error) {
      // Handle error if update fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update task: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.lato()),
            ),
          ],
        ),
      );
    });
  }
}
