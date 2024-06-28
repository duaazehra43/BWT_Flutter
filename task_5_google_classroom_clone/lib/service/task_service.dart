import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_5_google_classroom_clone/model/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask(String courseId, String title, String description,
      DateTime dueDate, String? fileUrl) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('tasks')
          .add({
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'fileUrl': fileUrl, // Store the file URL in Firestore
      });
    } catch (e) {
      print('Error creating task: $e');
      throw e;
    }
  }

  Stream<List<TaskModel>> getTasksByCourse(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel(
                  id: doc.id,
                  title: doc['title'],
                  description: doc['description'],
                  courseId: courseId,
                  dueDate: (doc['dueDate'] as Timestamp).toDate(),
                  fileUrl:
                      doc['fileUrl'], // Retrieve the file URL from Firestore
                ))
            .toList());
  }

  Future<void> submitTask(Map<String, dynamic> submissionData) async {
    try {
      await _firestore.collection('submitted_tasks').add(submissionData);
    } catch (e) {
      print('Error submitting task: $e');
      throw e;
    }
  }
}
