import 'package:file_picker/file_picker.dart';

class FilePickerService {
  /// Pick a single file and return its path, or null if cancelled.
  static Future<String?> pickFile({List<String>? allowedExtensions, bool allowMultiple = false}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null) return null;
    return result.files.first.path;
  }
}
