import 'dart:async';
import 'dart:math';

import 'package:metrics/features/dashboard/domain/entities/build_metrics.dart';
import 'package:metrics/features/dashboard/domain/usecases/parameters/build_metrics_loading_param.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_build_metrics_updates.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_poject_updates.dart';
import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:rxdart/rxdart.dart';

/// The store for the project metrics.
///
/// Stores the [Project]s and its [BuildMetrics].
class ProjectMetricsStore {
  static const int defaultNumberOfBuildResults = 14;
  static const Duration defaultBuildMetricsLoadingPeriod = Duration(days: 7);

  final ReceiveProjectUpdates _receiveProjectsUpdates;
  final ReceiveBuildMetricsUpdates _receiveBuildMetricsUpdates;
  final Map<String, StreamSubscription> _buildMetricsSubscriptions = {};
  final BehaviorSubject<Map<String, ProjectMetrics>> _projectsMetricsSubject =
      BehaviorSubject();

  StreamSubscription _projectsSubscription;

  /// Creates the project metrics store.
  ///
  /// The [_getCoverage] and [_getBuildMetrics] use cases should not be null.
  ProjectMetricsStore(
    this._receiveProjectsUpdates,
    this._receiveBuildMetricsUpdates,
  ) : assert(
          _receiveProjectsUpdates != null &&
              _receiveBuildMetricsUpdates != null,
          'The use cases should not be null',
        );

  Stream<List<ProjectMetrics>> get projectsMetrics =>
      _projectsMetricsSubject.map((metricsMap) => metricsMap.values.toList());

  /// Subscribes to projects and its metrics.
  Future<void> subscribeToProjects() async {
    final projectsStream = _receiveProjectsUpdates();
    await _projectsSubscription?.cancel();

    _projectsSubscription = projectsStream.listen((projects) {
      if (projects == null || projects.isEmpty) {
        _projectsMetricsSubject.add({});
        return;
      }

      final projectsMetrics = _projectsMetricsSubject.value ?? {};

      final newProjectsIds = projects.map((project) => project.id);
      projectsMetrics.removeWhere((projectId, value) {
        final remove = !newProjectsIds.contains(projectId);
        if (remove) _buildMetricsSubscriptions[projectId]?.cancel();

        return remove;
      });

      for (final project in projects) {
        final projectId = project.id;

        ProjectMetrics projectMetrics =
            projectsMetrics[projectId] ?? ProjectMetrics();

        // update name in case it was updated on server
        projectMetrics = projectMetrics.copyWith(
          projectName: project.name,
        );

        if (!projectsMetrics.containsKey(projectId)) {
          _subscribeToBuildMetrics(projectId);
        }
        projectsMetrics[projectId] = projectMetrics;
      }

      _projectsMetricsSubject.add(projectsMetrics);
    });
  }

  /// Subscribes to project metrics.
  void _subscribeToBuildMetrics(String projectId) {
    final buildMetricsStream = _receiveBuildMetricsUpdates(
      BuildMetricsLoadingParam(
        projectId,
        defaultBuildMetricsLoadingPeriod,
        defaultNumberOfBuildResults,
      ),
    );

    // We are storing subscriptions to map to cancel them later,
    // but the analyzer can't handle this, so we should add this ignoring.
    // ignore: cancel_subscriptions
    final metricsSubscription = buildMetricsStream.listen((metrics) {
      _createBuildMetrics(metrics, projectId);
    });

    _buildMetricsSubscriptions[projectId] = metricsSubscription;
  }

  /// Create project metrics form build metrics.
  void _createBuildMetrics(BuildMetrics buildMetrics, String projectId) {
    final projectsMetrics = _projectsMetricsSubject.value;

    final projectMetrics = projectsMetrics[projectId];

    if (projectMetrics == null || buildMetrics == null) return;

    final performanceMetrics = _getPerformanceMetrics(buildMetrics);
    final buildNumberMetrics = _getBuildNumberMetrics(buildMetrics);
    final buildResultMetrics = _getBuildResultMetrics(buildMetrics);

    projectsMetrics[projectId] = projectMetrics.copyWith(
      performanceMetrics: performanceMetrics,
      buildNumberMetrics: buildNumberMetrics,
      buildResultMetrics: buildResultMetrics,
      totalBuildsNumber: buildMetrics.totalBuildsNumber,
      averageBuildTime: buildMetrics.averageBuildTime.inMinutes,
      coverage: buildMetrics.coverage,
      stability: buildMetrics.stability,
    );

    _projectsMetricsSubject.add(projectsMetrics);
  }

  /// Creates the [_projectBuildNumberMetrics] from [_buildMetrics].
  List<Point<int>> _getBuildNumberMetrics(BuildMetrics metrics) {
    final buildNumberMetrics = metrics?.buildNumberMetrics ?? [];

    if (buildNumberMetrics.isEmpty) {
      return [];
    }

    return buildNumberMetrics.map((metric) {
      return Point(
        metric.date.millisecondsSinceEpoch,
        metric.numberOfBuilds,
      );
    }).toList();
  }

  /// Creates the [_projectPerformanceMetrics] from [_buildMetrics].
  List<Point<int>> _getPerformanceMetrics(BuildMetrics metrics) {
    final performanceMetrics = metrics?.performanceMetrics ?? [];

    if (performanceMetrics.isEmpty) {
      return [];
    }

    return performanceMetrics.map((metric) {
      return Point(
        metric.date.millisecondsSinceEpoch,
        metric.duration.inMilliseconds,
      );
    }).toList();
  }

  /// Creates the [_projectBuildResultMetrics] from [_buildMetrics].
  List<BuildResultBarData> _getBuildResultMetrics(BuildMetrics metrics) {
    final buildResults = metrics?.buildResultMetrics ?? [];

    if (buildResults.isEmpty) {
      return [];
    }

    return buildResults.map((result) {
      return BuildResultBarData(
        url: result.url,
        result: result.result,
        value: result.duration.inMilliseconds,
      );
    }).toList();
  }

  /// Cancels all created subscriptions.
  void dispose() {
    _projectsSubscription?.cancel();
    for (final subscription in _buildMetricsSubscriptions.values) {
      subscription?.cancel();
    }
  }
}
