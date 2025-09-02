class User {
  final int id;
  final String email;
  final String username;
  final String password;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
  });
}

class Team {
  final int id;
  final String name;
  final List<User> users;

  Team({required this.id, required this.name, required this.users});
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
    required this.type,
    required this.path,
  });
}

class Algorithm {
  final int id;
  final String name;
  final String description;
  final List<dynamic> parameters;
  final String code;

  Algorithm({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    required this.code,
  });
}

class Blueprint {
  final int id;
  final String name;
  final String type;
  final List<Algorithm> algorithms;

  Blueprint({
    required this.id,
    required this.name,
    required this.type,
    required this.algorithms,
  });
}

class Project {
  final int id;
  final String name;
  final String description;
  final Team team;
  final List<Dataset> datasets;
  final List<Blueprint> blueprints;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.team,
    required this.datasets,
    required this.blueprints,
  });
}
