import 'package:task_5_google_classroom_clone/service/outline_service.dart';

class AddOutlineViewModel {
  final OutlineService _outlineService = OutlineService();

  Future<void> saveOutline(
    String courseId,
    String title,
    String description,
  ) async {
    try {
      await _outlineService.createOutline(
        courseId,
        title,
        description,
      );
    } catch (e) {
      print('Error saving task: $e');
    }
  }
}
