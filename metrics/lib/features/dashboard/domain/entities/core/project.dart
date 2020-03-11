import 'package:flutter/foundation.dart';

/// Represents the project entity.
@immutable
class Project {
  final String id;
  final String name;

  /// Creates the [Project] with [name] and [id].
  const Project({
    this.id,
    this.name,
  });
}
