import 'package:metrics/features/dashboard/domain/entities/core/project.dart';
import 'package:test/test.dart';

void main() {
  final throwsAssertionError = throwsA(isA<AssertionError>());

  test("Can't create project with null id", () {
    const projectName = 'name';

    expect(() => Project(name: projectName, id: null), throwsAssertionError);
  });

  test("Can't create project without name", () {
    const projectId = 'projectId';

    expect(() => Project(name: null, id: projectId), throwsAssertionError);
  });
}
