import 'package:meta/meta.dart';
import 'package:metrics/features/dashboard/domain/entities/core/percent.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/performance_metric.dart';

/// Represents the build metrics entity.
@immutable
class ProjectMetrics {
  final String projectId;
  final BuildNumberMetric buildNumberMetrics;
  final PerformanceMetric performanceMetrics;
  final BuildResultMetric buildResultMetrics;
  final Percent coverage;
  final Percent stability;

  /// Creates the [ProjectMetrics].
  ///
  /// [projectId] is the unique identifier of the build's project.
  /// [buildNumberMetrics] is the [BuildNumberMetric] of project with [projectId].
  /// [performanceMetrics] is the [PerformanceMetric] of project with [projectId].
  /// [buildResultMetrics] is the [BuildResultMetric] of project with [projectId].
  /// [coverage] is the test coverage percent of the project with [projectId].
  /// [stability] is the percentage of successful builds to loaded builds.
  const ProjectMetrics({
    this.projectId,
    this.buildNumberMetrics = const BuildNumberMetric(),
    this.performanceMetrics = const PerformanceMetric(),
    this.buildResultMetrics = const BuildResultMetric(),
    this.coverage = const Percent(0.0),
    this.stability = const Percent(0.0),
  });
}
