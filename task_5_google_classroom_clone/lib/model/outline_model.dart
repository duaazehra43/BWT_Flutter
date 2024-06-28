import 'package:cloud_firestore/cloud_firestore.dart';

class OutlineModel {
  String id;
  String title;
  String description;
  String courseId;
  String? fileUrl;

  OutlineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.fileUrl,
  });

  factory OutlineModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return OutlineModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      courseId: data['courseId'] ?? '',
      fileUrl: data['fileUrl'],
    );
  }
}
