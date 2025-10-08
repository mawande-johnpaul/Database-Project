import 'dart:io';

import 'package:forge/models/datasheet.dart';

import 'sqflite_service.dart';

// Use Sqflite for all data operations
Future<List<Map<String, dynamic>>> getProjects() async {
  return await SqfliteService.getProjects();
}

Future<Project?> getProject(int id) async {
  return await SqfliteService.getProject(id);
}

Future<void> createProject(Project project) async {
  await SqfliteService.createProject(project);
}

// Add similar wrappers for users, datasheets, etc.

Future<List<String>> getDataset(String path) async {
  return File(path).readAsLines();
}

