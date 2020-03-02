/// Represents the project entity.
class Project {
  final String id;
  final String name;

  /// Creates the [Project] with [name] and [id].
  const Project({
    this.id,
    this.name,
  });

  /// Creates the [Project] using the [json] and it's [id].
  factory Project.fromJson(Map<String, dynamic> json, String id) {
    return Project(
      id: id,
      name: '${json['name']}',
    );
  }
}
