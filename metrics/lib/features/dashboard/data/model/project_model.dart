import 'package:metrics/features/dashboard/data/model/entity_model.dart';
import 'package:metrics/features/dashboard/domain/entities/project.dart';

/// [EntityModel] that represents the [Project] entity.
class ProjectModel extends Project implements EntityModel {
  const ProjectModel({
    String id,
    String name,
  }) : super(
          id: id,
          name: name,
        );

  /// Creates the [ProjectModel] using the [json] and it's [id].
  factory ProjectModel.fromJson(Map<String, dynamic> json, String id) {
    return ProjectModel(
      id: id,
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
