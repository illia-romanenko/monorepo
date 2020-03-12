import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:metrics/features/dashboard/domain/entities/core/build_status.dart';
import 'package:metrics/features/dashboard/domain/entities/core/percent.dart';

/// Represents a single finished build from CI.
@immutable
class Build extends Equatable {
  final String id;
  final DateTime startedAt;
  final BuildStatus result;
  final Duration duration;
  final String workflowName;
  final String url;
  final Percent coverage;

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

  @override
  List<Object> get props => [startedAt, result, duration, workflowName];
}
