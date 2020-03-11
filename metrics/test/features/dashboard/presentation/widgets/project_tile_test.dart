import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics_data.dart';
import 'package:metrics/features/dashboard/presentation/widgets/project_tile.dart';

void main() {
  testWidgets(
    "Can't create the ProjectTile with null projectMetrics",
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProjectTileTestbed(
        projectMetrics: null,
      ));

      expect(tester.takeException(), isAssertionError);
    },
  );

  testWidgets(
    "Displays the project name even if it is very long",
    (WidgetTester tester) async {
      const ProjectMetricsData metrics = ProjectMetricsData(
        projectName:
            'Some very long name to display that may overflow on some screens but should be displayed properly. Also, this project name has a description that placed to the project name, but we still can display it properly with any overflows.',
      );

      await tester.pumpWidget(const ProjectTileTestbed(
        projectMetrics: metrics,
      ));

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "Displays the ProjectMetrics even when the project nam is null",
    (WidgetTester tester) async {
      const metrics = ProjectMetricsData();

      await tester.pumpWidget(const ProjectTileTestbed(
        projectMetrics: metrics,
      ));

      expect(tester.takeException(), isNull);
    },
  );
}

class ProjectTileTestbed extends StatelessWidget {
  static const ProjectMetricsData testProjectMetrics = ProjectMetricsData(
    projectName: 'Test project name',
  );
  final ProjectMetricsData projectMetrics;

  const ProjectTileTestbed({
    Key key,
    this.projectMetrics = testProjectMetrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ProjectTile(
          projectMetrics: projectMetrics,
        ),
      ),
    );
  }
}
