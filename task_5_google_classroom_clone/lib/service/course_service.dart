import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCourse(String title, String description, String teacherId,
      String courseCode) async {
    try {
      await _firestore.collection('courses').add({
        'title': title,
        'description': description,
        'teacherId': teacherId,
        'studentIds': [],
        'outline': '',
        'tasks': [],
        'uploadedFiles': [],
        'courseCode': courseCode,
      });
    } catch (e) {
      print('Error creating course: $e');
      throw e;
    }
  }

  Future<void> updateCourse(String courseId, String title, String description,
      String courseCode) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'title': title,
        'description': description,
        'courseCode': courseCode,
      });
    } catch (e) {
      print('Error updating course: $e');
      throw e;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      print('Error deleting course: $e');
      throw e;
    }
  }

  Stream<List<CourseModel>> getCoursesByTeacher(String teacherId) {
    return _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CourseModel.fromSnapshot(doc)).toList());
  }

  Future<void> addStudentToCourse(String courseId, String studentId) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'studentIds': FieldValue.arrayUnion([studentId]),
      });
    } catch (e) {
      print('Error adding student to course: $e');
      throw e;
    }
  }

  Future<CourseModel?> getCourseByCode(String courseCode) async {
    try {
      var querySnapshot = await _firestore
          .collection('courses')
          .where('courseCode', isEqualTo: courseCode)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return CourseModel.fromSnapshot(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting course by code: $e');
      throw e;
    }
  }

  Stream<List<CourseModel>> getCoursesByStudent(String studentId) {
    return _firestore
        .collection('courses')
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CourseModel.fromSnapshot(doc)).toList());
  }

  Future<DocumentSnapshot> getUserById(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<void> addComment(
      String courseId, String userEmail, String comment) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('comments')
          .add({
        'userEmail': userEmail,
        'comment': comment,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding comment: $e');
      throw e;
    }
  }

  Stream<List<DocumentSnapshot>> getComments(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> addCommentReply(
      String courseId, String commentId, String reply) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add({
        'userEmail': 'Teacher', // Replace with actual user email or name
        'reply': reply,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding comment reply: $e');
      throw e;
    }
  }

  Stream<List<DocumentSnapshot>> getCommentReplies(
      String courseId, String commentId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
