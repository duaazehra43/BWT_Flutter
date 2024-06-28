import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/views/course_detail_screen_student.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/views/join_course_screen.dart';
import 'package:task_5_google_classroom_clone/service/auth_service.dart';
import 'package:task_5_google_classroom_clone/service/course_service.dart';
import 'package:task_5_google_classroom_clone/views/login_screen.dart';

class HomeScreenStudent extends StatelessWidget {
  final User user;
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();

  HomeScreenStudent(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut().then((_) {
                // Successful sign-out
                print('User signed out successfully');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
                // Optionally, navigate to login screen or perform post-logout actions
              }).catchError((error) {
                // Handle sign-out error
                print('Error signing out: $error');
                // Display a snackbar or alert dialog to inform the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to sign out: $error'),
                  ),
                );
              });
            },
          )
        ],
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: _courseService.getCoursesByStudent(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No courses joined yet.'));
          }
          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 8.0,
                child: ListTile(
                  title: Text(course.title, style: GoogleFonts.lato()),
                  subtitle: Text(course.description, style: GoogleFonts.lato()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailStudentScreen(course),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JoinCourseScreen(user)),
          );
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
