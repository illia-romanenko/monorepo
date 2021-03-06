import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';

/// Represents the build metrics entity.
class BuildMetrics {
  final List<BuildNumberMetric> buildNumberMetrics;
  final List<PerformanceMetric> performanceMetrics;
  final List<BuildResultMetric> buildResultMetrics;
  final Duration averageBuildTime;
  final int totalBuildNumber;

  BuildMetrics({
    this.buildNumberMetrics,
    this.performanceMetrics,
    this.buildResultMetrics,
    this.averageBuildTime,
    this.totalBuildNumber,
  });
}
