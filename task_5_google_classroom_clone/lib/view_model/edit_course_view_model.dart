import 'package:task_5_google_classroom_clone/service/course_service.dart';

class EditCourseViewModel {
  final CourseService _courseService = CourseService();

  Future<void> updateCourse(String courseId, String title, String description,
      String courseCode) async {
    try {
      await _courseService.updateCourse(
          courseId, title, description, courseCode);
    } catch (e) {
      throw e.toString();
    }
  }
}
