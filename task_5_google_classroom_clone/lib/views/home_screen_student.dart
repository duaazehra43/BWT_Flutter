import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/view_model/home_screen_teacher_view_model.dart';
import 'package:task_5_google_classroom_clone/views/course_detail_screen_student.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/service/auth_service.dart';
import 'package:task_5_google_classroom_clone/service/course_service.dart';
import 'package:task_5_google_classroom_clone/views/login_screen.dart';
import 'package:task_5_google_classroom_clone/view_model/join_course_view_model.dart';

class HomeScreenStudent extends StatefulWidget {
  final User user;
  HomeScreenStudent(this.user);

  @override
  State<HomeScreenStudent> createState() => _HomeScreenStudentState();
}

class _HomeScreenStudentState extends State<HomeScreenStudent> {
  final CourseService _courseService = CourseService();
  late HomeScreenTeacherViewModel _viewModel;
  final AuthService _authService = AuthService();
  final JoinCourseViewModel _joinCourseViewModel = JoinCourseViewModel();

  String? userName;
  String? userRole;
  String? userEmail;
  final TextEditingController _courseCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeScreenTeacherViewModel(widget.user.uid);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      Map<String, dynamic> userInfo =
          await _authService.getUserInfo(widget.user.uid);
      setState(() {
        userName = userInfo['name'];
        userRole = userInfo['role'];
        userEmail = userInfo['email'];
      });
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    super.dispose();
  }

  void _showJoinCourseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Course', style: GoogleFonts.lato()),
          content: TextField(
            controller: _courseCodeController,
            decoration: InputDecoration(
              labelText: 'Course Code',
              labelStyle: GoogleFonts.lato(),
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  Text('Cancel', style: GoogleFonts.lato(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                _joinCourse();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text('Join', style: GoogleFonts.lato()),
            ),
          ],
        );
      },
    );
  }

  void _joinCourse() async {
    String courseCode = _courseCodeController.text.trim();
    try {
      await _joinCourseViewModel.joinCourse(courseCode, widget.user.uid);

      Navigator.of(context).pop();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Text(
                      userName != null ? userName![0] : '',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    userEmail ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (userRole != null)
              ListTile(
                leading: Icon(Icons.person),
                title: Text(userRole!),
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.join_inner),
              title: Text('Join Course'),
              onTap: _showJoinCourseDialog,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _authService.signOut().then((_) {
                  print('User signed out successfully');
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                }).catchError((error) {
                  print('Error signing out: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: $error'),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: _courseService.getCoursesByStudent(widget.user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No classroom joined yet.'));
          }
          final courses = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of items per row
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.0, // Adjust as needed
            ),
            padding: EdgeInsets.all(10.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 8.0,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailStudentScreen(course),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 50.0, // Height of the colored section
                        color: Colors.purple,
                        child: Center(
                          child: Text(
                            course.title,
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Center(
                                child: Text(
                                  course.description,
                                  style: GoogleFonts.lato(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
