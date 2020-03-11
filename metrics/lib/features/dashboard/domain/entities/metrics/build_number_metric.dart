import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set.dart';
import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set_entry.dart';

/// Represents the build number metric entity.
@immutable
class BuildNumberMetric {
  final DateTimeSet<BuildsOnDate> buildsOnDateSet;
  final int totalNumberOfBuilds;

  /// Creates the [BuildNumberMetric].
  ///
  /// [buildsOnDateSet] is the list of number of builds on specific date.
  /// [totalNumberOfBuilds] is the number of builds that was used to calculate this metric.
  const BuildNumberMetric({
    this.buildsOnDateSet,
    this.totalNumberOfBuilds = 0,
  });
}

/// Represents the [numberOfBuilds] on specified [date].
@immutable
class BuildsOnDate extends DateTimeSetEntry {
  @override
  final DateTime date;
  final int numberOfBuilds;

  BuildsOnDate({
    this.date,
    this.numberOfBuilds,
  }) : assert(date.hour == 0 &&
            date.minute == 0 &&
            date.second == 0 &&
            date.millisecond == 0 &&
            date.microsecond == 0);
}
