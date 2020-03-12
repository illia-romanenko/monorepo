import 'package:metrics/features/dashboard/domain/entities/core/build.dart';
import 'package:metrics/features/dashboard/domain/entities/core/project.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/project_metrics.dart';
import 'package:metrics/features/dashboard/domain/repositories/metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/project_id_param.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_build_metrics_updates.dart';
import 'package:metrics/util/date.dart';
import 'package:test/test.dart';

void main() {
  group("Build metrics data loading", () {
    const projectId = 'projectId';
    const repository = MetricsRepositoryStubImpl();
    final receiveBuildUpdates = ReceiveBuildMetricsUpdates(repository);

    List<Build> builds;
    Build lastBuild;

    ProjectMetrics buildMetrics;

    setUpAll(() async {
      builds = MetricsRepositoryStubImpl.builds;

      buildMetrics =
          await receiveBuildUpdates(const ProjectIdParam(projectId)).first;

      lastBuild = builds.last;
    });

    test("Properly loads the performance metrics", () {
      final performanceMetrics = buildMetrics.performanceMetrics;
      final firstPerformanceMetric = performanceMetrics.buildsPerformance.first;

      expect(
        performanceMetrics.buildsPerformance.length,
        builds.length,
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
      final buildStartDate = lastBuild.startedAt.date;

      final numberOfBuildsPerFirstDate = builds
          .where((element) => element.startedAt.date == buildStartDate)
          .length;
      final totalNumberOfBuilds = builds.length;

      final buildNumberMetrics = buildMetrics.buildNumberMetrics;
      final buildsPerFirstDate = buildNumberMetrics.buildsOnDateSet.first;

      expect(buildsPerFirstDate.date, buildStartDate);
      expect(buildsPerFirstDate.numberOfBuilds, numberOfBuildsPerFirstDate);
      expect(buildNumberMetrics.totalNumberOfBuilds, totalNumberOfBuilds);
    });

    test('Properly loads the build result metrics', () {
      final buildResultMetrics = buildMetrics.buildResultMetrics;

      final firstBuildResult = buildResultMetrics.buildResults.first;

      expect(firstBuildResult.result, lastBuild.result);
      expect(firstBuildResult.duration, lastBuild.duration);
      expect(firstBuildResult.date, lastBuild.startedAt);
      expect(firstBuildResult.url, lastBuild.url);
    });
  });
}

class MetricsRepositoryStubImpl implements MetricsRepository {
  static const Project _project = Project(
    name: 'projectName',
    id: 'projectId',
  );
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
