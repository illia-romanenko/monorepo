import 'package:flutter/material.dart';
import 'package:metrics/features/common/presentation/drawer/widget/metrics_drawer.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:metrics/features/dashboard/presentation/strings/dashboard_strings.dart';
import 'package:metrics/features/dashboard/presentation/widgets/project_tile.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/// Shows the available projects and metrics for these projects.
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const MetricsDrawer(),
      body: SafeArea(
        child: WhenRebuilder<ProjectMetricsStore>(
          models: [Injector.getAsReactive<ProjectMetricsStore>()],
          onError: _buildLoadingErrorPlaceholder,
          onWaiting: _buildProgressIndicator,
          onIdle: _buildProgressIndicator,
          onData: (store) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<List<ProjectMetrics>>(
                stream: store.projectsMetrics,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return _buildProgressIndicator();

                  final projects = snapshot.data;

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];

                      return ProjectTile(projectMetrics: project);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadingErrorPlaceholder(error) {
    return _DashboardPlaceholder(
      text: DashboardStrings.getLoadingErrorMessage("$error"),
    );
  }
}

class _DashboardPlaceholder extends StatelessWidget {
  final String text;

  const _DashboardPlaceholder({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text),
    );
  }
}
