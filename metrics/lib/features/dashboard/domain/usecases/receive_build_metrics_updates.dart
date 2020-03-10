import 'package:metrics/core/usecases/usecase.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';
import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';
import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';
import 'package:metrics/features/dashboard/domain/repositories/metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/project_id_param.dart';
import 'package:metrics/util/date_time_util.dart';
import 'package:rxdart/rxdart.dart';

/// Provides an ability to get the [BuildMetrics] updates.
class ReceiveBuildMetricsUpdates
    implements UseCase<Stream<BuildMetrics>, ProjectIdParam> {
  static const int numberOfBuildResults = 14;
  static const Duration defaultBuildMetricsLoadingPeriod = Duration(days: 7);
  static const Duration averageBuildDurationCalculationPeriod =
      Duration(days: 14);

  final MetricsRepository _repository;

  /// Creates the [ReceiveBuildMetricsUpdates] use case with given [_repository].
  ReceiveBuildMetricsUpdates(this._repository);

  @override
  Stream<BuildMetrics> call(ProjectIdParam params) {
    final projectId = params.projectId;

    final lastBuildsStream = _repository.latestProjectBuildsStream(
      projectId,
      numberOfBuildResults,
    );

    final projectBuildsInPeriod = _repository.projectBuildsFromDateStream(
      projectId,
      DateTime.now().subtract(averageBuildDurationCalculationPeriod),
    );

    return CombineLatestStream.combine2(
      lastBuildsStream,
      projectBuildsInPeriod,
      _mergeBuilds,
    ).map((builds) => _mapToBuildMetrics(
          builds,
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
    String projectId,
  ) {
    if (builds == null || builds.isEmpty) {
      return BuildMetrics(
        projectId: projectId,
      );
    }

    final buildNumberMetrics = _getBuildNumberMetrics(builds);
    final buildResultMetrics = _getBuildResultMetrics(builds);
    final performanceMetrics = _getPerformanceMetrics(builds);
    final stability = _getStability(builds);

    return BuildMetrics(
      projectId: projectId,
      buildNumberMetrics: buildNumberMetrics,
      performanceMetrics: performanceMetrics,
      buildResultMetrics: buildResultMetrics,
      coverage: builds.last.coverage,
      stability: stability,
    );
  }

  /// Creates the [PerformanceMetric] from [builds].
  PerformanceMetric _getPerformanceMetrics(
    List<Build> builds,
  ) {
    final averageBuildTime = _getAverageBuildTime(builds);
    final buildsInPeriod = _getBuildsInPeriod(
      builds,
      defaultBuildMetricsLoadingPeriod,
    );

    if (buildsInPeriod.isEmpty) return const PerformanceMetric();

    final buildPerformances = buildsInPeriod
        .where((element) => element.startedAt
            .isAfter(DateTime.now().subtract(defaultBuildMetricsLoadingPeriod)))
        .map(
          (build) => BuildPerformance(
            duration: build.duration,
            date: build.startedAt,
          ),
        )
        .toList();

    return PerformanceMetric(
      buildsPerformance: buildPerformances,
      averageBuildDuration: averageBuildTime,
    );
  }

  /// Calculates the average build time of [builds].
  Duration _getAverageBuildTime(List<Build> builds) {
    final buildsInPeriod = _getBuildsInPeriod(
      builds,
      averageBuildDurationCalculationPeriod,
    );

    if (buildsInPeriod.isEmpty) return const Duration();

    return buildsInPeriod.fold<Duration>(
            const Duration(), (value, element) => value + element.duration) ~/
        builds.length;
  }

  /// Calculates the [BuildNumberMetric] from [builds].
  BuildNumberMetric _getBuildNumberMetrics(List<Build> builds) {
    final Map<DateTime, int> buildNumberMap = {};

    final buildsInPeriod = _getBuildsInPeriod(
      builds,
      defaultBuildMetricsLoadingPeriod,
    );

    if (buildsInPeriod.isEmpty) {
      return const BuildNumberMetric();
    }

    for (final build in buildsInPeriod) {
      final dayOfBuild = build.startedAt.date;

      if (buildNumberMap.containsKey(dayOfBuild)) {
        buildNumberMap[dayOfBuild]++;
      } else {
        buildNumberMap[dayOfBuild] = 1;
      }
    }

    final buildsPerDate = buildNumberMap.entries.map((entry) {
      return BuildsPerDate(
        date: entry.key,
        numberOfBuilds: entry.value,
      );
    }).toList();

    return BuildNumberMetric(
      buildsPerDate: buildsPerDate,
      totalNumberOfBuilds: buildsInPeriod.length,
    );
  }

  /// Creates the [BuildResultsMetric] from the list of [builds].
  BuildResultsMetric _getBuildResultMetrics(List<Build> builds) {
    if (builds.isEmpty) return const BuildResultsMetric();

    List<Build> latestBuilds = builds;

    if (latestBuilds.length > numberOfBuildResults) {
      latestBuilds = latestBuilds.sublist(
        latestBuilds.length - numberOfBuildResults,
      );
    }

    final buildResults = latestBuilds.map((build) {
      return BuildResult(
        date: build.startedAt,
        duration: build.duration,
        result: build.result,
        url: build.url,
      );
    }).toList();

    return BuildResultsMetric(buildResults: buildResults);
  }

  /// Calculates the stability metric from list of [builds].
  double _getStability(List<Build> builds) {
    final buildsInPeriod = _getBuildsInPeriod(
      builds,
      defaultBuildMetricsLoadingPeriod,
    );

    if (buildsInPeriod.isEmpty) return 0.0;

    final successfulBuilds = buildsInPeriod.where(
      (build) => build.result == Result.successful,
    );

    return successfulBuilds.length / buildsInPeriod.length;
  }

  /// Gets all builds in [period] from given [builds].
  Iterable<Build> _getBuildsInPeriod(List<Build> builds, Duration period) {
    final periodStartDate = DateTime.now().subtract(period);

    return builds
        .where((element) => element.startedAt.isAfter(periodStartDate))
        .toList();
  }
}
