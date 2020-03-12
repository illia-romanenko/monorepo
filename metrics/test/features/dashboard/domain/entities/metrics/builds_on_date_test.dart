import 'package:metrics/features/dashboard/domain/entities/metrics/builds_on_date.dart';
import 'package:test/test.dart';

void main() {
  test(
    "Can't create the BuildsOnDate with the date that contains non-zero time",
    () {
      expect(
        () => BuildsOnDate(date: DateTime.now()),
        throwsA(isA<AssertionError>()),
      );
    },
  );
}
