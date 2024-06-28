import 'package:task_5_google_classroom_clone/model/course_model.dart';
import 'package:task_5_google_classroom_clone/service/course_service.dart';

class HomeScreenTeacherViewModel {
  final CourseService _courseService = CourseService();
  final String userId;

  HomeScreenTeacherViewModel(this.userId);

  Stream<List<CourseModel>> getCourses() {
    return _courseService.getCoursesByTeacher(userId);
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _courseService.deleteCourse(courseId);
    } catch (e) {
      throw e.toString();
    }
  }
}
