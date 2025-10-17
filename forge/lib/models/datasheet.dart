class User {
  final int id;
  final String username;
  final String email;
  final String password;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });
}

class Project {
  final int id;
  final String name;
  final String description;

  Project({
    required this.id,
    required this.name,
    required this.description,
  });
}

class Dataset {
  final int id;
  final String name;
  final String description;
  final String type;
  final String? path;
  final int? projectId;

  Dataset({
    required this.id,
    required this.name,
    required this.description,
    this.type = 'csv',
    this.path,
    this.projectId,
  });
}


class Algorithm {
  final int id;
  final String name;
  final String description;
  final String code;
  final String
  parameters; // Store as a JSON string or comma-separated values for sqflite
  final int blueprintId;

  Algorithm({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.parameters,
    required this.blueprintId,
  });
}

class Column {
  final int id;
  final String name;
  final String dataType;
  final bool isNullable;
  final bool isPrimaryKey;
  final int datasetId;

  Column({
    required this.id,
    required this.name,
    required this.dataType,
    this.isNullable = true,
    this.isPrimaryKey = false,
    required this.datasetId,
  });
}

class Cell {
  final int id;
  final String value;
  final int rowId;
  final int columnId;
  final int isOutlier;

  Cell({
    required this.id,
    required this.value,
    required this.rowId,
    required this.columnId,
    this.isOutlier = 0,
  });
}
