import 'package:flutter/foundation.dart';

/// Represents the performance of the build.
@immutable
class PerformanceMetric {
  final DateTime date;
  final Duration duration;

  /// Creates the [PerformanceMetric].
  ///
  /// [date] is the timestamp of the build started.
  /// [duration] is the time the build took to finish.
  const PerformanceMetric({
    this.date,
    this.duration,
  });
}
