import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set.dart';
import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set_entry.dart';
import 'package:test/test.dart';

void main() {
  test(
    "Creates the set of elements with the unique date",
    () {
      final currentTimestamp = DateTime.now();
      final testData = [
        DateTimeSetData(
          date: currentTimestamp,
        ),
        DateTimeSetData(
          date: currentTimestamp,
        ),
      ];

      final dateTimeSet = DateTimeSet.from(testData);
      final uniqueTestData = [];

      for (final performance in testData) {
        final contains =
            uniqueTestData.any((element) => element.date == performance.date);

        if (!contains) uniqueTestData.add(performance);
      }

      expect(dateTimeSet.length, uniqueTestData.length);
    },
  );
}

class DateTimeSetData extends DateTimeSetEntry {
  @override
  final DateTime date;

  DateTimeSetData({this.date});
}
