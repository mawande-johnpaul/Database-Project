import 'package:sqflite/sqflite.dart';

class User {
  final int id;
  final String email;
  final String username;
  final String password;
  final int teamId;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.teamId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'teamId': teamId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
      teamId: map['teamId'],
    );
  }
}

class Team {
  final int id;
  final String name;
  final List<User> users;

  Team({required this.id, required this.name, required this.users});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'users': users.map((user) => user.toMap()).toList(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      users: (map['users'] as List)
          .map((userMap) => User.fromMap(userMap))
          .toList(),
    );
  }
}

class Dataset {
  final int id;
  final String name;
  final String description;
  final String type;
  final String path;

  Dataset({
    required this.id,
    required this.name,
    required this.description,
<<<<<<< Updated upstream
    required this.type,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'path': path,
    };
  }

  factory Dataset.fromMap(Map<String, dynamic> map) {
    return Dataset(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      path: map['path'],
    );
  }
=======
    this.type = 'csv',
    this.path,
    this.projectId,
  });
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
}

class Algorithm {
  final int id;
  final String name;
  final String description;
  final List<dynamic> parameters;
  final String code;
<<<<<<< Updated upstream
  final int projectId;
=======
  final String
  parameters; // Store as a JSON string or comma-separated values for sqflite
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

  Algorithm({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    required this.code,
    required this.projectId,
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parameters': parameters,
      'code': code,
      'projectId': projectId,
    };
  }

  factory Algorithm.fromMap(Map<String, dynamic> map) {
    return Algorithm(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      parameters: List<dynamic>.from(map['parameters']),
      code: map['code'],
      projectId: map['projectId'],
    );
  }
}

<<<<<<< Updated upstream
<<<<<<< Updated upstream
class Project {
  final int id;
  final String name;
  final String description;
  final Team team;
  final List<Dataset> datasets;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.team,
    required this.datasets,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'team': {
        'id': team.id,
        'name': team.name,
        'users': team.users.map((user) => user.toMap()).toList(),
      },
      'datasets': datasets.map((dataset) => dataset.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      team: Team(
        id: map['team']['id'],
        name: map['team']['name'],
        users: (map['team']['users'] as List)
            .map((userMap) => User.fromMap(userMap))
            .toList(),
      ),
      datasets: (map['datasets'] as List)
          .map((datasetMap) => Dataset.fromMap(datasetMap))
          .toList(),
    );
  }
}

class Log {
  final int id;
  final DateTime timestamp;
  final int lineNumber;
  final String status;
  final int result;
  final Project projectId;

  Log({
    required this.id,
    required this.lineNumber,
    required this.timestamp,
    required this.status,
    required this.result,
    required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'lineNumber': lineNumber,
      'status': status,
      'result': result,
      'projectId': projectId.id,
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      lineNumber: map['lineNumber'],
      status: map['status'],
      result: map['result'],
      projectId: Project.fromMap(map['projectId']),
    );
  }
}

Future onCreate (Database db, int version) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      teamId INTEGER,
      FOREIGN KEY (teamId) REFERENCES teams (id)
    )
  ''');

  await db.execute('''
    CREATE TABLE teams (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE datasets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      type TEXT NOT NULL,
      path TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      teamId INTEGER,
      FOREIGN KEY (teamId) REFERENCES teams (id)
    )
  ''');

  await db.execute('''
    CREATE TABLE algorithms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      parameters TEXT,
      code TEXT NOT NULL,
      projectId INTEGER,
      FOREIGN KEY (projectId) REFERENCES projects (id)
    )
  ''');

  await db.execute('''
    CREATE TABLE logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TEXT NOT NULL,
      lineNumber INTEGER NOT NULL,
      status TEXT NOT NULL,
      result INTEGER NOT NULL,
      projectId INTEGER,
      FOREIGN KEY (projectId) REFERENCES projects (id)
    )
  ''');
}


=======
=======
>>>>>>> Stashed changes
// Log: timestamp as id, algorithm id (nullable), result, line number
class LogEntry {
  final int id; // epoch millis timestamp
  final int? algorithmId;
  final String? result;
  final int? lineNumber;

  LogEntry({
    required this.id,
    this.algorithmId,
    this.result,
    this.lineNumber,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'algorithm_id': algorithmId,
        'result': result,
        'line_number': lineNumber,
      };

  factory LogEntry.fromMap(Map<String, dynamic> map) => LogEntry(
        id: map['id'] as int,
        algorithmId: map['algorithm_id'] as int?,
        result: map['result'] as String?,
        lineNumber: map['line_number'] as int?,
      );
}

// Column: column number as id, dataset id (composite key handled in DB)
class DatasetColumn {
  final int datasetId;
  final int id; // column number

  DatasetColumn({
    required this.datasetId,
    required this.id,
  });

  Map<String, dynamic> toMap() => {
        'dataset_id': datasetId,
        'id': id,
      };

  factory DatasetColumn.fromMap(Map<String, dynamic> map) => DatasetColumn(
        datasetId: map['dataset_id'] as int,
        id: map['id'] as int,
      );
}

// Cell: column id, data(any type), algorithm id optional, plus dataset and row index
class CellEntry {
  final int datasetId;
  final int columnId;
  final int rowIndex;
  final dynamic data; // stored as TEXT in DB; parse as needed
  final int? algorithmId;

  CellEntry({
    required this.datasetId,
    required this.columnId,
    required this.rowIndex,
    this.data,
    this.algorithmId,
  });

  Map<String, dynamic> toMap() => {
        'dataset_id': datasetId,
        'column_id': columnId,
        'row_index': rowIndex,
        'data': data?.toString(),
        'algorithm_id': algorithmId,
      };

  factory CellEntry.fromMap(Map<String, dynamic> map) => CellEntry(
        datasetId: map['dataset_id'] as int,
        columnId: map['column_id'] as int,
        rowIndex: map['row_index'] as int,
        data: map['data'],
        algorithmId: map['algorithm_id'] as int?,
      );
}
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
