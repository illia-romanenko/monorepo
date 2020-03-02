import 'dart:math';

import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';

/// Represents the metrics of the project.
class ProjectMetrics {
  final String projectId;
  final String projectName;
  final double coverage;
  final double stability;
  final int totalBuildsNumber;
  final int averageBuildTime;
  final List<Point<int>> performanceMetrics;
  final List<Point<int>> buildNumberMetrics;
  final List<BuildResultBarData> buildResultMetrics;

  /// Creates the [ProjectMetrics].
  ///
  /// [projectId] - id of the project this metrics behaves to.
  /// [projectName] is the name of the project this metrics behaves to.
  /// [coverage] is the tests code coverage of the project.
  /// [stability] is the percentage of the successful builds to total builds of the project.
  /// [totalBuildsNumber] is the number of builds the metrics are based on.
  /// [averageBuildTime] is the average duration of the single build.
  /// [performanceMetrics] is metric that represents the duration of the builds.
  /// [buildNumberMetrics] is the metric that represents the number of builds during some period of time.
  /// [buildResultMetrics] is the metric that represents the results of the builds.
  ProjectMetrics({
    this.projectId,
    this.projectName,
    this.coverage,
    this.stability,
    this.totalBuildsNumber,
    this.averageBuildTime,
    this.performanceMetrics,
    this.buildNumberMetrics,
    this.buildResultMetrics,
  });

  ProjectMetrics copyWith({
    String projectId,
    String projectName,
    double coverage,
    double stability,
    int totalBuildsNumber,
    int averageBuildTime,
    List<Point<int>> performanceMetrics,
    List<Point<int>> buildNumberMetrics,
    List<BuildResultBarData> buildResultMetrics,
  }) {
    return ProjectMetrics(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      coverage: coverage ?? this.coverage,
      stability: stability ?? this.stability,
      totalBuildsNumber: totalBuildsNumber ?? this.totalBuildsNumber,
      averageBuildTime: averageBuildTime ?? this.averageBuildTime,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      buildNumberMetrics: buildNumberMetrics ?? this.buildNumberMetrics,
      buildResultMetrics: buildResultMetrics ?? this.buildResultMetrics,
    );
  }

  @override
  String toString() {
    return 'ProjectMetrics{buildNumberMetrics: $buildNumberMetrics}';
  }
}
