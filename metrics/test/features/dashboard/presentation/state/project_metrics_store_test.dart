import 'dart:async';

import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set.dart';
import 'package:metrics/features/dashboard/domain/entities/core/percent.dart';
import 'package:metrics/features/dashboard/domain/entities/core/project.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/build_performance.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/build_result.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/builds_on_date.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/performance_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/metrics/project_metrics.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/project_id_param.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_build_metrics_updates.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_poject_updates.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics_data.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:metrics/util/date.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  const projectId = 'projectId';
  const ReceiveBuildMetricsUpdates receiveBuildMetricsUpdates =
      ReceiveBuildMetricsUpdatesTestbed();
  const projectIdParam = ProjectIdParam(projectId);

  final ReceiveProjectUpdates receiveProjectUpdates =
      ReceiveProjectUpdatesTestbed();

  ProjectMetrics expectedBuildMetrics;
  ProjectMetricsStore projectMetricsStore;
  Stream<List<ProjectMetricsData>> projectMetricsStream;

  setUpAll(() async {
    projectMetricsStore = ProjectMetricsStore(
      receiveProjectUpdates,
      receiveBuildMetricsUpdates,
    );
    projectMetricsStream = projectMetricsStore.projectsMetrics;

    expectedBuildMetrics =
        await receiveBuildMetricsUpdates(projectIdParam).first;

    await projectMetricsStore.subscribeToProjects();
  });

  test("Throws an assert if one of the use cases is null", () {
    final assertionMatcher = throwsA(isA<AssertionError>());

    expect(() => ProjectMetricsStore(null, null), assertionMatcher);
    expect(
      () => ProjectMetricsStore(null, receiveBuildMetricsUpdates),
      assertionMatcher,
    );
    expect(
      () => ProjectMetricsStore(receiveProjectUpdates, null),
      assertionMatcher,
    );
  });

  test(
    "Creates ProjectMetrics with empty points from empty BuildMetrics",
    () async {
      const receiveEmptyMetrics = ReceiveEmptyBuildMetricsUpdatesTestbed();

      final projectMetricsStore = ProjectMetricsStore(
        receiveProjectUpdates,
        receiveEmptyMetrics,
      );

      await projectMetricsStore.subscribeToProjects();

      final metrics = await projectMetricsStore.projectsMetrics.first;
      final projectMetrics = metrics.first;

      expect(projectMetrics.buildResultMetrics, isEmpty);
      expect(projectMetrics.performanceMetrics, isEmpty);
      expect(projectMetrics.buildNumberMetrics, isEmpty);
    },
  );

  test(
    "Creates ProjectMetrics with null metrics if the BuildMetrics is null",
    () async {
      const receiveBuildMetricsUpdates =
          ReceiveNullBuildMetricsUpdatesTestbed();
      final projectMetricsStore = ProjectMetricsStore(
        receiveProjectUpdates,
        receiveBuildMetricsUpdates,
      );

      await projectMetricsStore.subscribeToProjects();

      final metrics = await projectMetricsStore.projectsMetrics.first;
      final projectMetrics = metrics.first;

      expect(projectMetrics.buildResultMetrics, isNull);
      expect(projectMetrics.performanceMetrics, isNull);
      expect(projectMetrics.buildNumberMetrics, isNull);
    },
  );

  test("Properly loads the coverage data", () async {
    final expectedProjectCoverage = expectedBuildMetrics.coverage;

    final projectMetrics = await projectMetricsStream.first;
    final projectCoverage = projectMetrics.first.coverage;

    expect(projectCoverage, expectedProjectCoverage);
  });

  test("Loads the build number metrics", () async {
    final expectedBuildNumberMetrics = expectedBuildMetrics.buildNumberMetrics;
    final buildsPerFirstDate = expectedBuildNumberMetrics.buildsOnDateSet.first;

    final actualProjectMetrics = await projectMetricsStream.first;
    final firstProjectMetrics = actualProjectMetrics.first;
    final buildNumberMetrics = firstProjectMetrics.buildNumberMetrics;

    expect(
      firstProjectMetrics.numberOfBuilds,
      expectedBuildNumberMetrics.totalNumberOfBuilds,
    );

    expect(
      firstProjectMetrics.buildNumberMetrics.length,
      expectedBuildNumberMetrics.buildsOnDateSet.length,
    );

    final firstBuildNumberMetric = buildNumberMetrics.first;

    expect(
      firstBuildNumberMetric.x,
      buildsPerFirstDate.date.millisecondsSinceEpoch,
    );
    expect(
      firstBuildNumberMetric.y,
      expectedBuildNumberMetrics.totalNumberOfBuilds,
    );
  });

  test('Loads the performance metrics', () async {
    final expectedPerformanceMetrics = expectedBuildMetrics.performanceMetrics;

    final projectMetrics = await projectMetricsStream.first;
    final firstProjectMetrics = projectMetrics.first;
    final performanceMetrics = firstProjectMetrics.performanceMetrics;

    expect(
      performanceMetrics.length,
      expectedPerformanceMetrics.buildsPerformance.length,
    );

    expect(
      firstProjectMetrics.averageBuildDurationInMinutes,
      expectedPerformanceMetrics.averageBuildDuration.inMinutes,
    );

    final firstBuildPerformance =
        expectedPerformanceMetrics.buildsPerformance.first;
    final performancePoint = performanceMetrics.first;

    expect(
      performancePoint.x,
      firstBuildPerformance.date.millisecondsSinceEpoch,
    );
    expect(
      performancePoint.y,
      firstBuildPerformance.duration.inMilliseconds,
    );
  });

  test('Loads the build result metrics', () async {
    final expectedBuildResults =
        expectedBuildMetrics.buildResultMetrics.buildResults;

    final projectMetrics = await projectMetricsStream.first;
    final firstProjectMetrics = projectMetrics.first;
    final buildResultMetrics = firstProjectMetrics.buildResultMetrics;

    expect(
      buildResultMetrics.length,
      expectedBuildResults.length,
    );

    final expectedBuildResult = expectedBuildResults.first;
    final firstBuildResultMetric = buildResultMetrics.first;

    expect(
      firstBuildResultMetric.value,
      expectedBuildResult.duration.inMilliseconds,
    );
    expect(
      firstBuildResultMetric.result,
      expectedBuildResult.result,
    );
    expect(
      firstBuildResultMetric.url,
      expectedBuildResult.url,
    );
  });

  test(
    'Deletes the ProjectMetrics if the project was deleted on server',
    () async {
      final projects = ReceiveProjectUpdatesTestbed.testProjects.toList();

      final receiveProjectUpdates = ReceiveProjectUpdatesTestbed(
        projects: projects,
      );

      final metricsStore = ProjectMetricsStore(
        receiveProjectUpdates,
        receiveBuildMetricsUpdates,
      );

      await metricsStore.subscribeToProjects();

      List<Project> expectedProjects = await receiveProjectUpdates().first;
      List<ProjectMetricsData> actualProjects =
          await metricsStore.projectsMetrics.first;

      expect(actualProjects.length, expectedProjects.length);

      projects.removeLast();

      expectedProjects = await receiveProjectUpdates().first;
      actualProjects = await metricsStore.projectsMetrics.first;

      expect(actualProjects.length, expectedProjects.length);
    },
  );

  test(
    'Creates empty ProjectMetrics list when the projects are null',
    () async {
      final receiveProjects = ReceiveProjectUpdatesTestbed(projects: null);

      final metricsStore = ProjectMetricsStore(
        receiveProjects,
        receiveBuildMetricsUpdates,
      );

      await metricsStore.subscribeToProjects();
      final projectMetrics = await metricsStore.projectsMetrics.first;

      expect(projectMetrics, isEmpty);
    },
  );
}

class ReceiveProjectUpdatesTestbed implements ReceiveProjectUpdates {
  static const testProjects = [
    Project(
      id: 'id',
      name: 'name',
    ),
    Project(
      id: 'id2',
      name: 'name2',
    ),
  ];

  final List<Project> _projects;
  final BehaviorSubject<List<Project>> _projectsSubject = BehaviorSubject();

  ReceiveProjectUpdatesTestbed({List<Project> projects = testProjects})
      : _projects = projects;

  @override
  Stream<List<Project>> call([_]) {
    _projectsSubject.add(_projects);
    return _projectsSubject.stream;
  }
}

class ReceiveBuildMetricsUpdatesTestbed implements ReceiveBuildMetricsUpdates {
  static final _buildMetrics = ProjectMetrics(
    projectId: 'id',
    performanceMetrics: PerformanceMetric(
      buildsPerformance: DateTimeSet.from([
        BuildPerformance(
          date: DateTime.now(),
          duration: const Duration(minutes: 14),
        )
      ]),
      averageBuildDuration: const Duration(minutes: 3),
    ),
    buildNumberMetrics: BuildNumberMetric(
      buildsOnDateSet: DateTimeSet.from([
        BuildsOnDate(
          date: DateTime.now().date,
          numberOfBuilds: 1,
        ),
      ]),
      totalNumberOfBuilds: 1,
    ),
    buildResultMetrics: BuildResultMetric(
      buildResults: [
        BuildResult(
          date: DateTime.now(),
          duration: const Duration(minutes: 14),
          url: 'some url',
        ),
      ],
    ),
    coverage: const Percent(0.2),
    stability: const Percent(0.5),
  );

  const ReceiveBuildMetricsUpdatesTestbed();

  @override
  Stream<ProjectMetrics> call([ProjectIdParam params]) {
    return Stream.value(_buildMetrics);
  }
}

class ReceiveEmptyBuildMetricsUpdatesTestbed
    implements ReceiveBuildMetricsUpdates {
  const ReceiveEmptyBuildMetricsUpdatesTestbed();

  @override
  Stream<ProjectMetrics> call(ProjectIdParam params) {
    return Stream.value(const ProjectMetrics());
  }
}

class ReceiveNullBuildMetricsUpdatesTestbed
    implements ReceiveBuildMetricsUpdates {
  const ReceiveNullBuildMetricsUpdatesTestbed();

  @override
  Stream<ProjectMetrics> call(ProjectIdParam params) {
    return Stream.value(null);
  }
}
