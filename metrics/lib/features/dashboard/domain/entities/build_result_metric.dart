import 'package:flutter/foundation.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';

/// Represents the CI build [result] on specified [date].
///
/// Contains the data about build [url] and build [duration].
@immutable
class BuildResultMetric {
  final DateTime date;
  final Duration duration;
  final BuildResult result;
  final String url;

  const BuildResultMetric({
    this.date,
    this.duration,
    this.result,
    this.url,
  });
}
