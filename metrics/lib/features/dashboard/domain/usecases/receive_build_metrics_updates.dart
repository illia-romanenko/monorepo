import 'package:metrics/core/usecases/usecase.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';
import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';
import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';
import 'package:metrics/features/dashboard/domain/repositories/metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/build_metrics_loading_param.dart';
import 'package:metrics/util/date_time_util.dart';
import 'package:rxdart/rxdart.dart';

/// Provides an ability to get the [BuildMetrics] updates.
class ReceiveBuildMetricsUpdates
    implements UseCase<Stream<BuildMetrics>, BuildMetricsLoadingParam> {
  final MetricsRepository _repository;

  /// Creates the [ReceiveBuildMetricsUpdates] use case with given [_repository].
  ReceiveBuildMetricsUpdates(this._repository);

  @override
  Stream<BuildMetrics> call(BuildMetricsLoadingParam params) {
    final projectId = params.projectId;

    final lastBuildsStream = _repository.latestProjectBuildsStream(
      projectId,
      params.buildResultMetricsCount,
    );

    final projectBuildsInPeriod = _repository.projectBuildsFromDateStream(
      projectId,
      DateTime.now().subtract(params.period),
    );

    return CombineLatestStream.combine2(
      lastBuildsStream,
      projectBuildsInPeriod,
      _mergeBuilds,
    ).map((builds) => _mapToBuildMetrics(
          builds,
          params.buildResultMetricsCount,
          projectId,
        ));
  }

  /// Merges 2 [List] of [Build] into single list.
  List<Build> _mergeBuilds(
    List<Build> latestBuilds,
    List<Build> buildsInPeriod,
  ) {
    if (latestBuilds.isEmpty && buildsInPeriod.isEmpty) return [];

    final builds = buildsInPeriod.toList();

    for (final latestBuild in latestBuilds) {
      if (buildsInPeriod.any((build) => build.id == latestBuild.id)) continue;

      builds.add(latestBuild);
    }

    builds.sort((prev, next) => prev.startedAt.compareTo(next.startedAt));

    return builds;
  }

  /// Creates the [BuildMetrics] from the list of [Build]s.
  BuildMetrics _mapToBuildMetrics(
    List<Build> builds,
    int buildResultsCount,
    String projectId,
  ) {
    if (builds == null || builds.isEmpty) return const BuildMetrics();

    final averageBuildTime = _getAverageBuildTime(builds);
    final buildNumberMetrics = _getBuildNumberMetrics(builds);
    final buildResultMetrics = _getBuildResultMetrics(
      builds,
      buildResultsCount,
    );
    final List<PerformanceMetric> performanceMetrics = _getPerformanceMetrics(
      builds,
    );
    final stability = _getStability(builds);

    return BuildMetrics(
      projectId: projectId,
      buildNumberMetrics: buildNumberMetrics,
      performanceMetrics: performanceMetrics,
      buildResultMetrics: buildResultMetrics,
      averageBuildTime: averageBuildTime,
      totalBuildsNumber: builds.length,
      coverage: builds.last.coverage,
      stability: stability,
    );
  }

  /// Calculates the average build time of [builds].
  Duration _getAverageBuildTime(List<Build> builds) {
    final buildDurations = builds.map((build) => build.duration).toList();

    return buildDurations.reduce((value, element) => value + element) ~/
        builds.length;
  }

  /// Creates the [PerformanceMetric] list from [builds].
  List<PerformanceMetric> _getPerformanceMetrics(List<Build> builds) {
    return builds
        .map(
          (build) => PerformanceMetric(
            duration: build.duration,
            date: build.startedAt,
          ),
        )
        .toList();
  }

  /// Calculates the [BuildNumberMetric] list from [builds].
  List<BuildNumberMetric> _getBuildNumberMetrics(List<Build> builds) {
    final Map<DateTime, int> buildNumberMap = {};

    for (final build in builds) {
      final dayOfBuild = DateTimeUtil.trimToDay(build.startedAt);

      if (buildNumberMap.containsKey(dayOfBuild)) {
        buildNumberMap[dayOfBuild]++;
      } else {
        buildNumberMap[dayOfBuild] = 1;
      }
    }

    final List<BuildNumberMetric> buildNumberMetrics =
        buildNumberMap.entries.map((entry) {
      return BuildNumberMetric(
        date: entry.key,
        numberOfBuilds: entry.value,
      );
    }).toList();

    return buildNumberMetrics;
  }

  /// Creates the list of [BuildResultMetric]s from the list of [builds].
  List<BuildResultMetric> _getBuildResultMetrics(
    List<Build> builds,
    int count,
  ) {
    List<Build> latestBuilds = builds.toList();

    if (latestBuilds.length > count) {
      latestBuilds = latestBuilds.sublist(latestBuilds.length - count);
    }

    return latestBuilds.map((build) {
      return BuildResultMetric(
        date: build.startedAt,
        duration: build.duration,
        result: build.result,
        url: build.url,
      );
    }).toList();
  }

  /// Calculates the stability metric from list of [builds].
  double _getStability(List<Build> builds) {
    final successfulBuilds = builds.where(
      (build) => build.result == BuildResult.successful,
    );

    return successfulBuilds.length / builds.length;
  }
}
