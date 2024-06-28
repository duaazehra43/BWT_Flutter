import 'package:flutter/material.dart';
import 'package:task_5_google_classroom_clone/view_model/join_course_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinCourseScreen extends StatefulWidget {
  final User user;

  JoinCourseScreen(this.user);

  @override
  _JoinCourseScreenState createState() => _JoinCourseScreenState();
}

class _JoinCourseScreenState extends State<JoinCourseScreen> {
  final TextEditingController _courseCodeController = TextEditingController();
  final JoinCourseViewModel _joinCourseViewModel = JoinCourseViewModel();

  @override
  void dispose() {
    _courseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseCodeController,
              decoration: InputDecoration(labelText: 'Course Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinCourse,
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  void _joinCourse() async {
    String courseCode = _courseCodeController.text.trim();
    try {
      await _joinCourseViewModel.joinCourse(courseCode, widget.user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined the course')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
