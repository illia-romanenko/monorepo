import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/core/build.dart';

/// Represents the build results metric entity.
@immutable
class BuildResultMetric {
  final List<BuildResult> buildResults;

  /// Creates the [BuildResultMetric].
  ///
  /// [buildResults] represents the results of several builds.
  const BuildResultMetric({this.buildResults = const []});
}

/// Represents the CI build [result] on specified [date].
///
/// Contains the data about build [url] and build [duration].
@immutable
class BuildResult {
  final DateTime date;
  final Duration duration;
  final BuildStatus result;
  final String url;

  const BuildResult({
    this.date,
    this.duration,
    this.result,
    this.url,
  });
}
