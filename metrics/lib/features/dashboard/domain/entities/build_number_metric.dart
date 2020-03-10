import 'package:flutter/foundation.dart';

/// Represents the build number metric entity.
@immutable
class BuildNumberMetric {
  final List<BuildsPerDate> buildsPerDate;
  final int totalNumberOfBuilds;

  /// Creates the [BuildNumberMetric].
  ///
  /// [buildsPerDate] is the list of number of builds on specific date.
  /// If not specified, the empty list will be used.
  /// [totalNumberOfBuilds] is the number of builds that was used to calculate this metric.
  const BuildNumberMetric({
    this.buildsPerDate = const [],
    this.totalNumberOfBuilds = 0,
  });
}

/// Represents the [numberOfBuilds] on specified [date].
@immutable
class BuildsPerDate {
  final DateTime date;
  final int numberOfBuilds;

  const BuildsPerDate({
    this.date,
    this.numberOfBuilds,
  });
}
