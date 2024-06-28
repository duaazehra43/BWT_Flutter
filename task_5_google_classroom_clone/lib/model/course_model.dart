import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  String id;
  String title;
  String description;
  String teacherId;
  List<String> studentIds;
  String? outline;
  List<String> tasks;
  List<String> uploadedFiles;
  String courseCode;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    this.studentIds = const [],
    this.outline,
    this.tasks = const [],
    this.uploadedFiles = const [],
    required this.courseCode,
  });

  factory CourseModel.fromSnapshot(DocumentSnapshot snapshot) {
    return CourseModel(
      id: snapshot.id,
      title: snapshot['title'],
      description: snapshot['description'],
      teacherId: snapshot['teacherId'],
      studentIds: List<String>.from(snapshot['studentIds'] ?? []),
      outline: snapshot['outline'],
      tasks: List<String>.from(snapshot['tasks'] ?? []),
      uploadedFiles: List<String>.from(snapshot['uploadedFiles'] ?? []),
      courseCode: snapshot['courseCode'],
    );
  }
}
