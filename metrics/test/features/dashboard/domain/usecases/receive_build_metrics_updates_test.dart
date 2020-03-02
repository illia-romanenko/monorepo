import 'package:metrics/features/dashboard/domain/entities/build.dart';
import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';
import 'package:metrics/features/dashboard/domain/entities/project.dart';
import 'package:metrics/features/dashboard/domain/repositories/metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/build_metrics_loading_param.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_build_metrics_updates.dart';
import 'package:metrics/util/date_time_util.dart';
import 'package:test/test.dart';

void main() {
  group("Build metrics data loading", () {
    const projectId = 'projectId';
    const repository = MetricsRepositoryStubImpl();
    final receiveBuildUpdates = ReceiveBuildMetricsUpdates(repository);
    const buildLoadingLimit = 5;
    const buildLoadingPeriod = Duration(days: 4);

    List<Build> builds;
    Build lastBuild;

    BuildMetrics buildMetrics;

    setUpAll(() async {
      builds = MetricsRepositoryStubImpl.builds;

      buildMetrics = await receiveBuildUpdates(const BuildMetricsLoadingParam(
        projectId,
        buildLoadingPeriod,
        buildLoadingLimit,
      )).first;

      lastBuild = builds.last;
    });

    test('Calculates the average build time and total number of builds', () {
      final expectedAverageBuildTime = builds
              .map((build) => build.duration)
              .reduce((value, element) => value + element) ~/
          builds.length;
      final expectedTotalBuildNumber = builds.length;

      expect(buildMetrics.averageBuildTime, expectedAverageBuildTime);
      expect(buildMetrics.totalBuildsNumber, expectedTotalBuildNumber);
    });

    test("Properly loads the performance metrics", () {
      final firstPerformanceMetric = buildMetrics.performanceMetrics.first;

      expect(
        builds.length,
        buildMetrics.performanceMetrics.length,
      );

      expect(
        lastBuild.startedAt,
        firstPerformanceMetric.date,
      );
      expect(
        lastBuild.duration,
        firstPerformanceMetric.duration,
      );
    });

    test("Loads all fields in the build number metrics", () {
      final buildStartDate = DateTimeUtil.trimToDay(lastBuild.startedAt);

      final numberOfBuilds = builds
          .where((element) =>
              DateTimeUtil.trimToDay(element.startedAt) == buildStartDate)
          .length;

      final buildNumberMetrics = buildMetrics.buildNumberMetrics;
      final firstBuildMetric = buildNumberMetrics.first;

      expect(firstBuildMetric.date, buildStartDate);
      expect(firstBuildMetric.numberOfBuilds, numberOfBuilds);
    });

    test('Properly loads the build result metrics', () {
      final buildResultMetrics = buildMetrics.buildResultMetrics;

      final firstBuildResultMetric = buildResultMetrics.first;

      expect(firstBuildResultMetric.result, lastBuild.result);
      expect(firstBuildResultMetric.duration, lastBuild.duration);
      expect(firstBuildResultMetric.date, lastBuild.startedAt);
      expect(firstBuildResultMetric.url, lastBuild.url);
    });

    test(
      "Provides the build metrics based on builds in a given period",
      () async {
        const period = Duration(days: 2);
        const buildsLoadingCount = 1;

        final buildsInPeriod = builds
            .where(
              (build) =>
                  build.startedAt.isAfter(DateTime.now().subtract(period)),
            )
            .toList();

        final loadedBuildMetrics =
            await receiveBuildUpdates(const BuildMetricsLoadingParam(
          projectId,
          period,
          buildsLoadingCount,
        )).first;

        expect(loadedBuildMetrics.totalBuildsNumber, buildsInPeriod.length);
      },
    );

    test('Provides build metrics based on required number of builds', () async {
      const period = Duration(hours: 1);
      const buildsLoadingCount = 3;

      final loadedBuildMetrics =
          await receiveBuildUpdates(const BuildMetricsLoadingParam(
        projectId,
        period,
        buildsLoadingCount,
      )).first;

      expect(
        loadedBuildMetrics.totalBuildsNumber,
        greaterThanOrEqualTo(buildsLoadingCount),
      );
    });
  });
}

class MetricsRepositoryStubImpl implements MetricsRepository {
  static const Project _project = Project();
  static final List<Build> builds = [
    Build(
      id: '1',
      startedAt: DateTime.now(),
      duration: const Duration(minutes: 10),
    ),
    Build(
      id: '2',
      startedAt: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(minutes: 6),
    ),
    Build(
      id: '3',
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
      duration: const Duration(minutes: 3),
    ),
    Build(
      id: '4',
      startedAt: DateTime.now().subtract(const Duration(days: 3)),
      duration: const Duration(minutes: 8),
    ),
    Build(
      id: '5',
      startedAt: DateTime.now().subtract(const Duration(days: 4)),
      duration: const Duration(minutes: 12),
    ),
  ];

  const MetricsRepositoryStubImpl();

  @override
  Stream<List<Build>> latestProjectBuildsStream(String projectId, int limit) {
    List<Build> latestBuilds = builds;

    if (latestBuilds.length > limit) {
      latestBuilds = latestBuilds.sublist(0, limit);
    }

    return Stream.value(latestBuilds);
  }

  @override
  Stream<List<Build>> projectBuildsFromDateStream(
      String projectId, DateTime from) {
    return Stream.value(
        builds.where((build) => build.startedAt.isAfter(from)).toList());
  }

  @override
  Stream<List<Project>> projectsStream() {
    return Stream.value([_project]);
  }
}
