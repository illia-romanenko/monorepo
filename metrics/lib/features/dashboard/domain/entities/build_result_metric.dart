import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';

/// Represents the build results metric entity.
@immutable
class BuildResultsMetric {
  final List<BuildResult> buildResults;

  /// Creates the [BuildResultsMetric].
  ///
  /// [buildResults] represents the results of several builds.
  const BuildResultsMetric({this.buildResults = const []});
}

/// Represents the CI build [result] on specified [date].
///
/// Contains the data about build [url] and build [duration].
@immutable
class BuildResult {
  final DateTime date;
  final Duration duration;
  final Result result;
  final String url;

  const BuildResult({
    this.date,
    this.duration,
    this.result,
    this.url,
  });
}
