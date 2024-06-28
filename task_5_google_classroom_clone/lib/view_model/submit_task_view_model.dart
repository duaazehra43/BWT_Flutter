import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SubmitTaskViewModel {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? fileUrl;

  Future<void> uploadFile(dynamic document) async {
    if (document is XFile) {
      await _uploadImageToFirebase(document);
    } else if (document is File) {
      await _uploadFileToFirebase(document);
    }
  }

  Future<void> _uploadImageToFirebase(XFile image) async {
    try {
      final file = File(image.path);
      final storageRef = _storage.ref().child('images/${image.name}');
      await storageRef.putFile(file);
      fileUrl = await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _uploadFileToFirebase(File file) async {
    try {
      final storageRef =
          _storage.ref().child('files/${file.path.split('/').last}');
      await storageRef.putFile(file);
      fileUrl = await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        await uploadFile(pickedImage);
      }
      return pickedImage;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await uploadFile(file);
        return file;
      }
    } catch (e) {
      print('Error picking file: $e');
    }
    return null;
  }
}
