class User {
  final int id;
  final String username;
  final String email;
  final String password;
  final int teamId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.teamId,
  });
}

class Team {
  final int id;
  final String name;

  Team({
    required this.id,
    required this.name,
  });
}

class Project {
  final int id;
  final String name;
  final String description;
  final int teamId;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.teamId,
  });
}

class Dataset {
  final int id;
  final String name;
  final String description;
  final String type;
  final String? path;
  final int projectId;

  Dataset({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.path,
    required this.projectId,
  });
}

class Blueprint {
  final int id;
  final String name;
  final String type;
  final int projectId;

  Blueprint({
    required this.id,
    required this.name,
    required this.type,
    required this.projectId,
  });
}

class Algorithm {
  final int id;
  final String name;
  final String description;
  final String code;
  final String parameters; // Store as a JSON string or comma-separated values for sqflite
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
