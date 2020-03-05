import 'package:flutter/foundation.dart';

/// Represents the [numberOfBuilds] on specified [date].
@immutable
class BuildNumberMetric {
  final DateTime date;
  final int numberOfBuilds;

  const BuildNumberMetric({
    this.date,
    this.numberOfBuilds,
  });
}
