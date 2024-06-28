import 'package:task_5_google_classroom_clone/service/course_service.dart';
import 'package:task_5_google_classroom_clone/model/course_model.dart';

class JoinCourseViewModel {
  final CourseService _courseService = CourseService();

  Future<void> joinCourse(String courseCode, String studentId) async {
    try {
      CourseModel? course = await _courseService.getCourseByCode(courseCode);
      if (course != null) {
        await _courseService.addStudentToCourse(course.id, studentId);
      } else {
        throw 'Course not found';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
