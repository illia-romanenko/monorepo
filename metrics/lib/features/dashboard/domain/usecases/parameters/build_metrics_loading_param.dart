import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';

/// Parameter for loading the [BuildMetrics].
class BuildMetricsLoadingParam {
  final String projectId;
  final Duration period;
  final int buildResultMetricsCount;

  /// Creates the [BuildMetricsLoadingParam].
  ///
  /// [projectId] defines the id of the project for which the metrics will be loaded.
  /// [period] is the period in which the metrics will be loaded.
  /// [buildResultMetricsCount] is the required number of the build result metrics to load.
  const BuildMetricsLoadingParam(
    this.projectId,
    this.period,
    this.buildResultMetricsCount,
  );
}
