import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set.dart';
import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set_entry.dart';

/// Represents the build performance metric.
@immutable
class PerformanceMetric {
  final DateTimeSet<BuildPerformance> buildsPerformance;
  final Duration averageBuildDuration;

  /// Creates the [PerformanceMetric].
  ///
  /// [buildsPerformance] is the performance of several builds.
  /// [averageBuildDuration] is the average build duration of all builds in [buildsPerformance].
  const PerformanceMetric({
    this.buildsPerformance,
    this.averageBuildDuration = const Duration(),
  });
}

/// Represents the [duration] of the build, started at [date].
@immutable
class BuildPerformance extends DateTimeSetEntry {
  @override
  final DateTime date;
  final Duration duration;

  BuildPerformance({
    this.date,
    this.duration,
  });
}
