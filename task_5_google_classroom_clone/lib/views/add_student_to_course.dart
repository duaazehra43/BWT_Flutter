import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/view_model/add_student_to_course_view_model.dart';

class AddStudentToCourseScreen extends StatefulWidget {
  final String courseId;

  AddStudentToCourseScreen(this.courseId);

  @override
  _AddStudentToCourseScreenState createState() =>
      _AddStudentToCourseScreenState();
}

class _AddStudentToCourseScreenState extends State<AddStudentToCourseScreen> {
  final AddStudentToCourseViewModel _viewModel = AddStudentToCourseViewModel();
  List<String> studentIds = [];
  List<String> addedStudentIds = [];
  String? selectedStudent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchAddedStudents();
  }

  Future<void> fetchStudents() async {
    List<String> ids = await _viewModel.fetchStudentIds();
    setState(() {
      studentIds = ids;
    });
  }

  Future<void> fetchAddedStudents() async {
    List<String> ids = await _viewModel.fetchAddedStudentIds(widget.courseId);
    setState(() {
      addedStudentIds = ids;
    });
  }

  Future<void> addStudentToCourse() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _viewModel.addStudentToCourse(widget.courseId, selectedStudent!);
      setState(() {
        addedStudentIds.add(selectedStudent!);
        selectedStudent = null;
      });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'Add Student to Course',
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
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        selectedStudent == null ? null : addStudentToCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Add Student',
                      style: GoogleFonts.lato(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: addedStudentIds.length,
                      itemBuilder: (context, index) {
                        String studentId = addedStudentIds[index];
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(studentId)
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    'Loading...',
                                    style: GoogleFonts.lato(),
                                  ),
                                ),
                              );
                            }
                            var userDoc = snapshot.data!;
                            return Card(
                              child: ListTile(
                                title: Text(userDoc['name']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
