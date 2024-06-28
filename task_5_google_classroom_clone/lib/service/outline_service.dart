import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_5_google_classroom_clone/model/outline_model.dart';

class OutlineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOutline(
    String courseId,
    String title,
    String description,
  ) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('outlines')
          .add({
        'title': title,
        'description': description,
        'courseId': courseId,
      });
    } catch (e) {
      print('Error creating outline: $e');
      throw e;
    }
  }

  Stream<List<OutlineModel>> getOutlinesByCourse(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('outlines')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OutlineModel(
                  id: doc.id,
                  title: doc['title'],
                  description: doc['description'],
                  courseId: courseId,
                ))
            .toList());
  }
}
