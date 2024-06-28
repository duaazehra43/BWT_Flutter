import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_5_google_classroom_clone/service/auth_service.dart';
import 'package:task_5_google_classroom_clone/view_model/add_outline_view_model.dart';
import 'package:task_5_google_classroom_clone/view_model/add_student_to_course_view_model.dart';
import 'package:task_5_google_classroom_clone/view_model/add_task_view_model.dart';
import 'package:task_5_google_classroom_clone/view_model/create_course_view_model.dart';
import 'package:task_5_google_classroom_clone/view_model/edit_course_view_model.dart';
import 'package:task_5_google_classroom_clone/views/course_detail_screen.dart';
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
  String? userName;
  String? userRole;
  String? userEmail;

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

  Future<void> _showCreateCourseDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController courseCodeController = TextEditingController();
    final CreateCourseViewModel _viewModel = CreateCourseViewModel();
    bool _isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Create Course', style: GoogleFonts.lato()),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: courseCodeController,
                      decoration: InputDecoration(
                        labelText: 'Course Code',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TextButton(
                        child: Text('Cancel', style: GoogleFonts.lato()),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await _viewModel.createCourse(
                        titleController.text,
                        descriptionController.text,
                        widget.user.uid,
                        courseCodeController.text,
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to create course: $e',
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
                    'Create Course',
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditCourseDialog(
      BuildContext context, CourseModel course) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController courseCodeController = TextEditingController();
    final EditCourseViewModel _viewModel = EditCourseViewModel();
    bool _isLoading = false;

    titleController.text = course.title;
    descriptionController.text = course.description;
    courseCodeController.text = course.courseCode ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Edit Course', style: GoogleFonts.lato()),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: courseCodeController,
                      decoration: InputDecoration(
                        labelText: 'Course Code',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TextButton(
                        child: Text('Cancel', style: GoogleFonts.lato()),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await _viewModel.updateCourse(
                        course.id,
                        titleController.text,
                        descriptionController.text,
                        courseCodeController.text,
                      );
                      Navigator.of(context).pop();
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
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddStudentDialog(
      BuildContext context, String courseId) async {
    final AddStudentToCourseViewModel _viewModel =
        AddStudentToCourseViewModel();
    List<String> studentIds = [];
    String? selectedStudent;
    bool _isLoading = false;

    await _viewModel.fetchStudentIds().then((ids) {
      studentIds = ids;
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to close
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Add Student to Course', style: GoogleFonts.lato()),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: selectedStudent,
                      onChanged: (newValue) {
                        setState(() {
                          selectedStudent = newValue;
                        });
                      },
                      items: studentIds.map((id) {
                        return DropdownMenuItem<String>(
                          value: id,
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(id)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text(
                                  'Loading...',
                                  style: GoogleFonts.lato(),
                                );
                              }
                              var userDoc = snapshot.data!;
                              return Text(userDoc['name']);
                            },
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Student',
                        labelStyle: GoogleFonts.lato(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TextButton(
                        child: Text('Cancel', style: GoogleFonts.lato()),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                ElevatedButton(
                  onPressed: selectedStudent == null
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await _viewModel.addStudentToCourse(
                                courseId, selectedStudent!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 8.0,
                                backgroundColor: Colors.purple,
                                content: Text(
                                  'Student added successfully!',
                                  style: GoogleFonts.lato(color: Colors.white),
                                ),
                              ),
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to add student: $e',
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
                    'Add Student',
                    style: GoogleFonts.lato(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddOutlineDialog(BuildContext context, String courseId) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final AddOutlineViewModel _viewModel = AddOutlineViewModel();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Add Outline', style: GoogleFonts.lato()),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: GoogleFonts.lato(),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: GoogleFonts.lato(),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',
                      style: GoogleFonts.lato(color: Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await _viewModel.saveOutline(
                          courseId,
                          _titleController.text,
                          _descriptionController.text,
                        );

                        Navigator.of(context)
                            .pop(); // Close dialog after saving
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create outline: $e',
                                style: GoogleFonts.lato()),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Save Outline', style: GoogleFonts.lato()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, String courseId) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime _dueDate = DateTime.now();
    final AddTaskViewModel _viewModel = AddTaskViewModel();
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
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
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Add Task', style: GoogleFonts.lato()),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: GoogleFonts.lato(),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: GoogleFonts.lato(),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: ListTile(
                          title: Text(
                            'Due Date: ${_dueDate.toLocal().toString().split(' ')[0]}',
                            style: GoogleFonts.lato(),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_down),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _dueDate) {
                              setState(() {
                                _dueDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: ListTile(
                          title: Text(_fileName ?? 'No file selected',
                              style: GoogleFonts.lato()),
                          trailing: _isUploading
                              ? CircularProgressIndicator()
                              : Icon(Icons.file_upload),
                          onTap: () async {
                            await _showImageSourceDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel',
                      style: GoogleFonts.lato(color: Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isUploading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isUploading = true;
                            });

                            try {
                              await _viewModel.saveTask(
                                courseId,
                                _titleController.text,
                                _descriptionController.text,
                                _dueDate,
                              );

                              setState(() {
                                _isUploading = false;
                              });

                              Navigator.of(context)
                                  .pop(); // Close dialog after saving
                            } catch (e) {
                              setState(() {
                                _isUploading = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to create task: $e',
                                      style: GoogleFonts.lato()),
                                ),
                              );
                            }
                          }
                        },
                  child: Text('Save Task', style: GoogleFonts.lato()),
                ),
              ],
            );
          },
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
          'Home Screen',
          style: GoogleFonts.lato(),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
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
              leading: Icon(Icons.add),
              title: Text('Create Course'),
              onTap: () {
                _showCreateCourseDialog(context);
              },
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
        stream: _viewModel.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No classroom created yet.'));
          }

          List<CourseModel> courses = snapshot.data ?? [];

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of items per row
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.0, // Adjust as needed for card aspect ratio
            ),
            padding: EdgeInsets.all(10.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              CourseModel course = courses[index];
              return GestureDetector(
                onTap: () {
                  print('Tapped on course: ${course.title}');
                  _navigateToCourseDetailScreen(context, course);
                },
                child: Card(
                  color: Colors.white,
                  elevation: 8.0,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 50.0, // Adjust height of colored section
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
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.description,
                                style: GoogleFonts.lato(
                                  fontSize: 16.0,
                                ),
                              ),
                              Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: PopupMenuButton<String>(
                                  color: Colors.white,
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _showEditCourseDialog(context, course);
                                        break;
                                      case 'delete':
                                        _deleteCourse(context, course.id);
                                        break;
                                      case 'add_student':
                                        _showAddStudentDialog(
                                            context, course.id);
                                        break;
                                      case 'add_task':
                                        _showAddTaskDialog(context, course.id);
                                        break;
                                      case 'add_outline':
                                        _showAddOutlineDialog(
                                            context, course.id);
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

  void _navigateToCourseDetailScreen(BuildContext context, CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseDetailScreen(course)),
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
