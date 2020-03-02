import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';

/// Represents the build metrics entity.
class BuildMetrics {
  final String projectId;
  final List<BuildNumberMetric> buildNumberMetrics;
  final List<PerformanceMetric> performanceMetrics;
  final List<BuildResultMetric> buildResultMetrics;
  final Duration averageBuildTime;
  final int totalBuildsNumber;
  final double coverage;
  final double stability;

  /// Creates the [BuildMetrics].
  ///
  /// [projectId] is the unique identifier of the build's project.
  /// [buildNumberMetrics] is the [BuildNumberMetric]s of project with [projectId].
  /// [performanceMetrics] is the [PerformanceMetric]s of project with [projectId].
  /// [buildResultMetrics] is the [BuildResultMetric]s of project with [projectId].
  /// [averageBuildTime] is the average duration of the build of project with [projectId].
  /// [totalBuildsNumber] is the number of builds from which the metrics were calculated.
  /// [coverage] is the test coverage percent of the project with [projectId].
  /// [stability] is the percentage of successful builds to [totalBuildsNumber].
  const BuildMetrics({
    this.projectId,
    this.buildNumberMetrics = const [],
    this.performanceMetrics = const [],
    this.buildResultMetrics = const [],
    this.averageBuildTime = const Duration(milliseconds: 0),
    this.totalBuildsNumber = 0,
    this.coverage = 0.0,
    this.stability = 0.0,
  });
}
