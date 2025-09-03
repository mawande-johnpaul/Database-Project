import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> _getLocalFile() async {
  final path = await _localPath;
  return File('$path/appfile.json');
}

Future<void> writeJsonToFile(Map<String, dynamic> data) async {
  final file = await _getLocalFile();
  await file.writeAsString(jsonEncode(data));
}

Future<Map<String, dynamic>> readJsonFromFile() async {
  try {
    final file = await _getLocalFile();
    final contents = await file.readAsString();
    return jsonDecode(contents);
  } catch (e) {
    return {'projects': []};
  }
}

dynamic getProjects(Map<String, dynamic> appData) {
  return appData['projects'];
}

