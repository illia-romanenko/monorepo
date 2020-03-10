import 'package:flutter/foundation.dart';

/// Represents the build performance metric.
@immutable
class PerformanceMetric {
  final List<BuildPerformance> buildsPerformance;
  final Duration averageBuildDuration;

  /// Creates the [PerformanceMetric].
  ///
  /// [buildsPerformance] is the performance of several builds.
  /// [averageBuildDuration] is the average build duration of all builds in [buildsPerformance].
  const PerformanceMetric({
    this.buildsPerformance = const [],
    this.averageBuildDuration = const Duration(),
  });
}

/// Represents the [duration] of the build, started at [date].
@immutable
class BuildPerformance {
  final DateTime date;
  final Duration duration;

  const BuildPerformance({
    this.date,
    this.duration,
  });
}
