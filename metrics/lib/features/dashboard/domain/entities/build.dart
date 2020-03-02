import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BuildResult { successful, canceled, failed }

/// Represents the build entity.
class Build extends Equatable {
  final String id;
  final DateTime startedAt;
  final BuildResult result;
  final Duration duration;
  final String workflowName;
  final String url;
  final double coverage;

  /// Creates the [Build].
  ///
  /// [id] is the unique identifier of this build.
  /// [startedAt] is the date and time this build was started at.
  /// [result] is the result of this build.
  /// [duration] is the duration of this build.
  /// [workflowName] is the name of the workflow on which the build was running.
  /// [url] is the url of the commit/pr this build was triggered by.
  /// [coverage] is the project test coverage percent of this build.
  const Build({
    this.id,
    this.startedAt,
    this.result,
    this.duration,
    this.workflowName,
    this.url,
    this.coverage,
  });

  factory Build.fromJson(Map<String, dynamic> json, String id) {
    final buildResultValue = json['result'] as int;
    final durationMilliseconds = json['duration'] as int;

    return Build(
      id: id,
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      result: BuildResult.values[buildResultValue ?? 0],
      duration: Duration(milliseconds: durationMilliseconds),
      workflowName: json['workflow'] as String,
      url: json['url'] as String,
      coverage: json['coverage'] as double,
    );
  }

  @override
  List<Object> get props => [startedAt, result, duration, workflowName];

  @override
  String toString() {
    return 'Build{id: $id}';
  }
}
