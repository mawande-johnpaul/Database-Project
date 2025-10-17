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

Future<int> createDataset(Dataset dataset, String filePath) async {
  // Save the dataset with file path
  return await SqfliteService.createDataset(dataset, filePath);
}

Future<List<Dataset>> getDatasetsByProject(int projectId) async {
  return await SqfliteService.getDatasetsByProject(projectId);
}

// Add similar wrappers for users, datasheets, etc.

Future<List<String>> getDataset(Future<String?> pathFuture) async {
  // Wait for the path future to resolve
  final path = await pathFuture;
  
  // Check if path is null (user canceled file picking)
  if (path == null) {
    return [];
  }
  
  try {
    // Try to read with UTF-8 encoding first
    return await File(path).readAsLines();
  } catch (e) {
    // If UTF-8 fails, try with Latin-1 (ISO-8859-1) encoding
    try {
      final bytes = await File(path).readAsBytes();
      final content = String.fromCharCodes(bytes);
      return content.split('\n').map((line) => line.trim()).toList();
    } catch (e) {
      // If all attempts fail, return empty list and log error
      print('Error reading file: $e');
      return [];
    }
  }
}
