import 'dart:async';

import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';
import 'package:metrics/features/dashboard/domain/entities/build_number_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/build_result_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/performance_metric.dart';
import 'package:metrics/features/dashboard/domain/entities/project.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/build_metrics_loading_param.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_build_metrics_updates.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_poject_updates.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  const projectId = 'projectId';
  const ReceiveBuildMetricsUpdates receiveBuildMetricsUpdates =
      ReceiveBuildMetricsUpdatesTestbed();
  final ReceiveProjectUpdates receiveProjectUpdates =
      ReceiveProjectUpdatesTestbed();

  const BuildMetricsLoadingParam buildMetricsParams =
      BuildMetricsLoadingParam(projectId, Duration(days: 5), 3);

  BuildMetrics expectedBuildMetrics;

  ProjectMetricsStore projectMetricsStore;

  setUpAll(() async {
    projectMetricsStore = ProjectMetricsStore(
      receiveProjectUpdates,
      receiveBuildMetricsUpdates,
    );

    expectedBuildMetrics =
        await receiveBuildMetricsUpdates(buildMetricsParams).first;

    await projectMetricsStore.subscribeToProjects();
  });

  test("Throws an assert if one of the use cases is null", () {
    final assertionMatcher = throwsA(const TypeMatcher<AssertionError>());

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
    "Creates empty ProjectMetrics number metrics from empty BuildMetrics",
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
      const getNullBuildMetrics = ReceiveNullBuildMetricsUpdatesTestbed();
      final projectMetricsStore = ProjectMetricsStore(
        receiveProjectUpdates,
        getNullBuildMetrics,
      );

      await projectMetricsStore.subscribeToProjects();

      final metrics = await projectMetricsStore.projectsMetrics.first;
      final projectMetrics = metrics.first;

      print(projectMetrics);

      expect(projectMetrics.buildResultMetrics, isNull);
      expect(projectMetrics.performanceMetrics, isNull);
      expect(projectMetrics.buildNumberMetrics, isNull);
    },
  );

  test("Properly loads the coverage data", () async {
    final expectedCoverage = expectedBuildMetrics.coverage;

    final actualMetrics = await projectMetricsStore.projectsMetrics.first;
    final actualCoverage = actualMetrics.first.coverage;

    expect(actualCoverage, expectedCoverage);
  });

  test("Loads the build number metrics", () async {
    final expectedBuildNumberMetrics = expectedBuildMetrics.buildNumberMetrics;
    final expectedBuildNumberMetric = expectedBuildNumberMetrics.first;

    final actualProjectMetrics =
        await projectMetricsStore.projectsMetrics.first;
    final actualProjectMetric = actualProjectMetrics.first;

    expect(
      actualProjectMetric.totalBuildsNumber,
      expectedBuildMetrics.totalBuildsNumber,
    );

    expect(
      actualProjectMetric.buildNumberMetrics.length,
      expectedBuildNumberMetrics.length,
    );

    final actualBuildNumberMetrics = actualProjectMetric.buildNumberMetrics;
    final firstBuildNumberMetric = actualBuildNumberMetrics.first;

    expect(
      firstBuildNumberMetric.x,
      expectedBuildNumberMetric.date.millisecondsSinceEpoch,
    );
    expect(
      firstBuildNumberMetric.y,
      expectedBuildNumberMetric.numberOfBuilds,
    );
  });

  test('Loads the performance metrics', () async {
    final expectedPerformanceMetrics = expectedBuildMetrics.performanceMetrics;
    final expectedPerformanceMetric = expectedPerformanceMetrics.first;

    final actualProjectMetrics =
        await projectMetricsStore.projectsMetrics.first;
    final actualProjectMetric = actualProjectMetrics.first;
    final performanceMetrics = actualProjectMetric.performanceMetrics;
    final performanceMetric = performanceMetrics.first;

    expect(performanceMetrics.length, expectedPerformanceMetrics.length);

    expect(
      actualProjectMetric.averageBuildTime,
      expectedBuildMetrics.averageBuildTime.inMinutes,
    );

    expect(
      performanceMetric.x,
      expectedPerformanceMetric.date.millisecondsSinceEpoch,
    );
    expect(
      performanceMetric.y,
      expectedPerformanceMetric.duration.inMilliseconds,
    );
  });

  test('Loads the build result metrics', () async {
    final expectedBuildResultMetrics = expectedBuildMetrics.buildResultMetrics;
    final expectedBuildResultMetric = expectedBuildResultMetrics.first;

    final actualProjectMetrics =
        await projectMetricsStore.projectsMetrics.first;
    final actualProjectMetric = actualProjectMetrics.first;
    final buildResultMetrics = actualProjectMetric.buildResultMetrics;
    final buildResultMetric = buildResultMetrics.first;

    expect(buildResultMetrics.length, expectedBuildResultMetrics.length);

    expect(
      buildResultMetric.value,
      expectedBuildResultMetric.duration.inMilliseconds,
    );
    expect(
      buildResultMetric.result,
      expectedBuildResultMetric.result,
    );
    expect(
      buildResultMetric.url,
      expectedBuildResultMetric.url,
    );
  });

  test(
    'Deletes the ProjectMetrics if the project was deleted on server',
    () async {
      final projects = ReceiveProjectUpdatesTestbed.testProjects.toList();

      final receiveProjectUpdates =
          ReceiveProjectUpdatesTestbed(projects: projects);

      final metricsStore = ProjectMetricsStore(
        receiveProjectUpdates,
        receiveBuildMetricsUpdates,
      );

      await metricsStore.subscribeToProjects();

      List<Project> expectedProjects = await receiveProjectUpdates().first;
      List<ProjectMetrics> actualProjects =
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
  Stream<List<Project>> call([void _]) {
    _projectsSubject.add(_projects);

    print('empty stream');
    return _projectsSubject.stream;
  }
}

class ReceiveBuildMetricsUpdatesTestbed implements ReceiveBuildMetricsUpdates {
  static final _buildMetrics = BuildMetrics(
    projectId: 'id',
    performanceMetrics: [
      PerformanceMetric(
        date: DateTime.now(),
        duration: const Duration(minutes: 14),
      )
    ],
    buildNumberMetrics: [
      BuildNumberMetric(date: DateTime.now(), numberOfBuilds: 1),
    ],
    buildResultMetrics: [
      BuildResultMetric(
        date: DateTime.now(),
        duration: const Duration(minutes: 14),
        url: 'some url',
      ),
    ],
    averageBuildTime: const Duration(minutes: 3),
    totalBuildsNumber: 1,
    coverage: 0.2,
    stability: 0.5,
  );

  const ReceiveBuildMetricsUpdatesTestbed();

  @override
  Stream<BuildMetrics> call([BuildMetricsLoadingParam params]) {
    return Stream.value(_buildMetrics);
  }
}

class ReceiveEmptyBuildMetricsUpdatesTestbed
    implements ReceiveBuildMetricsUpdates {
  const ReceiveEmptyBuildMetricsUpdatesTestbed();

  @override
  Stream<BuildMetrics> call(BuildMetricsLoadingParam params) {
    return Stream.value(const BuildMetrics());
  }
}

class ReceiveNullBuildMetricsUpdatesTestbed
    implements ReceiveBuildMetricsUpdates {
  const ReceiveNullBuildMetricsUpdatesTestbed();

  @override
  Stream<BuildMetrics> call(BuildMetricsLoadingParam params) {
    return Stream.value(null);
  }
}
