import 'package:task_5_google_classroom_clone/service/course_service.dart';

class CreateCourseViewModel {
  final CourseService _courseService = CourseService();

  Future<void> createCourse(String title, String description, String userId,
      String courseCode) async {
    try {
      await _courseService.createCourse(title, description, userId, courseCode);
    } catch (e) {
      throw e.toString();
    }
  }
}
