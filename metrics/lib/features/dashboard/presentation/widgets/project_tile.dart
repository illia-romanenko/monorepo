import 'package:flutter/material.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:metrics/features/dashboard/presentation/strings/dashboard_strings.dart';
import 'package:metrics/features/dashboard/presentation/widgets/build_result_bar_graph.dart';
import 'package:metrics/features/dashboard/presentation/widgets/circle_percentage.dart';
import 'package:metrics/features/dashboard/presentation/widgets/coverage_circle_percentage.dart';
import 'package:metrics/features/dashboard/presentation/widgets/loading_builder.dart';
import 'package:metrics/features/dashboard/presentation/widgets/loading_placeholder.dart';
import 'package:metrics/features/dashboard/presentation/widgets/sparkline_graph.dart';

/// Displays the project name and it's metrics.
class ProjectTile extends StatelessWidget {
  final ProjectMetrics projectMetrics;

  /// Creates the [ProjectTile].
  ///
  /// [projectMetrics] is the metrics of the project to be displayed.
  const ProjectTile({
    Key key,
    @required this.projectMetrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 150.0,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  projectMetrics.projectName ?? '',
                  style: const TextStyle(fontSize: 22.0),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    child: LoadingBuilder(
                      isLoading: projectMetrics.buildResultMetrics == null,
                      loadingPlaceholder: const LoadingPlaceholder(),
                      builder: (_) => BuildResultBarGraph(
                        data: projectMetrics.buildResultMetrics,
                        title: DashboardStrings.buildTaskName,
                        numberOfBars:
                            ProjectMetricsStore.defaultNumberOfBuildResults,
                      ),
                    ),
                  ),
                  Flexible(
                    child: LoadingBuilder(
                      isLoading: projectMetrics.performanceMetrics == null,
                      loadingPlaceholder: const LoadingPlaceholder(),
                      builder: (_) => SparklineGraph(
                        title: DashboardStrings.performance,
                        data: projectMetrics.performanceMetrics,
                        value: '${projectMetrics.averageBuildTime}M',
                      ),
                    ),
                  ),
                  Flexible(
                    child: LoadingBuilder(
                      isLoading: projectMetrics.buildNumberMetrics == null,
                      loadingPlaceholder: const LoadingPlaceholder(),
                      builder: (_) => SparklineGraph(
                        title: DashboardStrings.builds,
                        data: projectMetrics.buildNumberMetrics,
                        value: '${projectMetrics.totalBuildsNumber}',
                      ),
                    ),
                  ),
                  LoadingBuilder(
                    isLoading: projectMetrics.coverage == null,
                    loadingPlaceholder: const Flexible(
                      child: LoadingPlaceholder(),
                    ),
                    builder: (_) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CirclePercentage(
                        title: DashboardStrings.stability,
                        value: projectMetrics.stability,
                      ),
                    ),
                  ),
                  LoadingBuilder(
                    isLoading: projectMetrics.coverage == null,
                    loadingPlaceholder: const Flexible(
                      child: LoadingPlaceholder(),
                    ),
                    builder: (_) => CoverageCirclePercentage(
                      value: projectMetrics.coverage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
