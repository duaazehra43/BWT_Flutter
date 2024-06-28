import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/service/auth_service.dart';
import 'package:task_5_google_classroom_clone/views/add_outline_screen.dart';
import 'package:task_5_google_classroom_clone/views/add_student_to_course.dart';
import 'package:task_5_google_classroom_clone/views/add_task_screen.dart';
import 'package:task_5_google_classroom_clone/views/course_detail_screen.dart';
import 'package:task_5_google_classroom_clone/views/create_course_screen.dart';
import 'package:task_5_google_classroom_clone/views/edit_course_screen.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/view_model/home_screen_teacher_view_model.dart';
import 'package:task_5_google_classroom_clone/views/login_screen.dart';

class HomeScreenTeacher extends StatefulWidget {
  final User user;

  HomeScreenTeacher(this.user);

  @override
  _HomeScreenTeacherState createState() => _HomeScreenTeacherState();
}

class _HomeScreenTeacherState extends State<HomeScreenTeacher> {
  late HomeScreenTeacherViewModel _viewModel;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeScreenTeacherViewModel(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'Home Screen',
          style: GoogleFonts.lato(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToCreateCourseScreen(context);
            },
          ),
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
        stream: _viewModel.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No courses joined yet.'));
          }

          List<CourseModel> courses = snapshot.data ?? [];

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              CourseModel course = courses[index];
              return GestureDetector(
                onTap: () {
                  print('Tapped on course: ${course.title}');
                  _navigateToCourseDetailScreen(context, course);
                },
                child: Card(
                  elevation: 8.0,
                  color: Colors.white,
                  shadowColor: Colors.purple,
                  child: ListTile(
                    title: Text(course.title),
                    subtitle: Text(course.description),
                    onTap: () {
                      print('Tapped on ListTile: ${course.title}');
                      _navigateToCourseDetailScreen(context, course);
                    },
                    trailing: PopupMenuButton<String>(
                      color: Colors.white,
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _navigateToEditCourseScreen(context, course);
                            break;
                          case 'delete':
                            _deleteCourse(context, course.id);
                            break;
                          case 'add_student':
                            _navigateToAddStudentScreen(context, course.id);
                            break;
                          case 'add_task':
                            _navigateToAddTaskScreen(context, course.id);
                            break;
                          case 'add_outline':
                            _navigateToAddOutlineScreen(context, course.id);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          const PopupMenuItem(
                            value: 'add_student',
                            child: Text('Add Student'),
                          ),
                          const PopupMenuItem(
                            value: 'add_task',
                            child: Text('Add Task'),
                          ),
                          const PopupMenuItem(
                            value: 'add_outline',
                            child: Text('Add Outline'),
                          ),
                        ];
                      },
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToCreateCourseScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateCourseScreen(widget.user)),
    );
  }

  void _navigateToEditCourseScreen(BuildContext context, CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditCourseScreen(widget.user, course)),
    );
  }

  void _navigateToAddStudentScreen(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddStudentToCourseScreen(courseId)),
    );
  }

  void _navigateToCourseDetailScreen(BuildContext context, CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseDetailScreen(course)),
    );
  }

  void _navigateToAddTaskScreen(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(courseId)),
    );
  }

  void _navigateToAddOutlineScreen(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddOutlineScreen(courseId)),
    );
  }

  Future<void> _deleteCourse(BuildContext context, String courseId) async {
    try {
      await _viewModel.deleteCourse(courseId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete course: $e'),
        ),
      );
    }
  }
}
