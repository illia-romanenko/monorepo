import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';

/// Represents the build metrics entity.
@immutable
class BuildMetrics {
  final String projectId;
  final BuildNumberMetric buildNumberMetrics;
  final PerformanceMetric performanceMetrics;
  final BuildResultsMetric buildResultMetrics;
  final double coverage;
  final double stability;

  /// Creates the [BuildMetrics].
  ///
  /// [projectId] is the unique identifier of the build's project.
  /// [buildNumberMetrics] is the [BuildNumberMetric] of project with [projectId].
  /// [performanceMetrics] is the [PerformanceMetric] of project with [projectId].
  /// [buildResultMetrics] is the [BuildResultsMetric] of project with [projectId].
  /// [coverage] is the test coverage percent of the project with [projectId].
  /// [stability] is the percentage of successful builds to loaded builds.
  const BuildMetrics({
    this.projectId,
    this.buildNumberMetrics = const BuildNumberMetric(),
    this.performanceMetrics = const PerformanceMetric(),
    this.buildResultMetrics = const BuildResultsMetric(),
    this.coverage = 0.0,
    this.stability = 0.0,
  });
}
