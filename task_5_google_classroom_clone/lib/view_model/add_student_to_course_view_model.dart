import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_5_google_classroom_clone/service/course_service.dart';

class AddStudentToCourseViewModel {
  final CourseService _courseService = CourseService();

  Future<List<String>> fetchStudentIds() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('role', isEqualTo: 'Student')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  Future<List<String>> fetchAddedStudentIds(String courseId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> courseDoc = await FirebaseFirestore
          .instance
          .collection('courses')
          .doc(courseId)
          .get();
      return List<String>.from(courseDoc.data()?['students'] ?? []);
    } catch (e) {
      print('Error fetching added students: $e');
      return [];
    }
  }

  Future<void> addStudentToCourse(String courseId, String studentId) async {
    try {
      await _courseService.addStudentToCourse(courseId, studentId);
    } catch (e) {
      throw e.toString();
    }
  }
}
