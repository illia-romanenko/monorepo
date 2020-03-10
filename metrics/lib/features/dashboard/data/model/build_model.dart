import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrics/features/dashboard/data/model/entity_model.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';

/// [EntityModel] that represents the [Build] entity.
class BuildModel extends Build implements EntityModel {
  const BuildModel({
    String id,
    DateTime startedAt,
    Result result,
    Duration duration,
    String workflowName,
    String url,
    double coverage,
  }) : super(
          id: id,
          startedAt: startedAt,
          result: result,
          duration: duration,
          workflowName: workflowName,
          url: url,
          coverage: coverage,
        );

  /// Creates the [BuildModel] from the [json] and it's [id].
  factory BuildModel.fromJson(Map<String, dynamic> json, String id) {
    final buildResultValue = json['result'] as int;
    final durationMilliseconds = json['duration'] as int;

    return BuildModel(
      id: id,
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      result: Result.values[buildResultValue ?? 0],
      duration: Duration(milliseconds: durationMilliseconds),
      workflowName: json['workflow'] as String,
      url: json['url'] as String,
      coverage: json['coverage'] as double,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'startedAt': startedAt,
      'result': result.index,
      'duration': duration.inMilliseconds,
      'workflowName': workflowName,
      'url': url,
      'coverage': coverage,
    };
  }
}
