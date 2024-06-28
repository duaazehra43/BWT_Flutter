import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String title;
  String description;
  String courseId;
  DateTime dueDate;
  String? fileUrl;
  String?
      submittedBy; // New field to store student email who submitted the task

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.dueDate,
    this.fileUrl,
    this.submittedBy,
  });

  factory TaskModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return TaskModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      courseId: data['courseId'] ?? '',
      dueDate: data['dueDate'] is Timestamp
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.parse(data['dueDate']),
      fileUrl: data['fileUrl'],
      submittedBy: data['submittedBy'], // Initialize submittedBy from Firestore
    );
  }
}
