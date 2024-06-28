import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';

class CourseDetailViewModel {
  final CourseModel course;
  CourseDetailViewModel(this.course);

  Stream<QuerySnapshot> get enrolledStudentsStream {
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: course.studentIds)
        .snapshots();
  }

  Stream<QuerySnapshot> get tasksStream {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(course.id)
        .collection('tasks')
        .snapshots();
  }

  Stream<QuerySnapshot> get outlinesStream {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(course.id)
        .collection('outlines')
        .snapshots();
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(course.id)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }

  Future<void> deleteOutline(String outlineId) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(course.id)
          .collection('outlines')
          .doc(outlineId)
          .delete();
    } catch (e) {
      print('Error deleting outline: $e');
      throw e;
    }
  }

  Future<void> updateTask(
      String taskId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(course.id)
          .collection('tasks')
          .doc(taskId)
          .update(updatedData);
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  Future<void> updateOutline(
      String taskId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(course.id)
          .collection('outlines')
          .doc(taskId)
          .update(updatedData);
    } catch (e) {
      print('Error updating outlines: $e');
      throw e;
    }
  }
}
