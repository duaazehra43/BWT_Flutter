import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/view_model/edit_course_view_model.dart';

class EditCourseScreen extends StatefulWidget {
  final User user;
  final CourseModel course;

  EditCourseScreen(this.user, this.course);

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final EditCourseViewModel _viewModel = EditCourseViewModel();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.course.title;
    descriptionController.text = widget.course.description;
    courseCodeController.text = widget.course.courseCode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'Edit Course',
          style: GoogleFonts.lato(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: courseCodeController,
                    decoration: InputDecoration(
                      labelText: 'Course Code',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        await _viewModel.updateCourse(
                          widget.course.id,
                          titleController.text,
                          descriptionController.text,
                          courseCodeController.text,
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to update course: $e',
                              style: GoogleFonts.lato(),
                            ),
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Update Course',
                      style: GoogleFonts.lato(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
