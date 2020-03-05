import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/features/dashboard/presentation/model/project_metrics.dart';
import 'package:metrics/features/dashboard/presentation/widgets/project_tile.dart';

void main() {
  testWidgets(
    "Displays the project name even if it is very long",
    (WidgetTester tester) async {
      const ProjectMetrics metrics = ProjectMetrics(
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
      const metrics = ProjectMetrics();

      await tester.pumpWidget(const ProjectTileTestbed(
        projectMetrics: metrics,
      ));

      expect(tester.takeException(), isNull);
    },
  );
}

class ProjectTileTestbed extends StatelessWidget {
  static const ProjectMetrics testProjectMetrics = ProjectMetrics(
    projectName: 'Test project name',
  );
  final ProjectMetrics projectMetrics;

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
