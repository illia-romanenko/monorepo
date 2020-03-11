import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:metrics/features/dashboard/domain/entities/collections/date_time_set_entry.dart';

/// Represents the set of the [DateTimeSetEntry]s with the unique date.
class DateTimeSet<T extends DateTimeSetEntry> extends DelegatingSet<T> {
  /// Creates an empty [DateTimeSet].
  DateTimeSet()
      : super(LinkedHashSet<T>(
          equals: (entry1, entry2) => entry1.date == entry2.date,
          hashCode: (entry) => entry.date.hashCode,
        ));

  /// Creates the [BuildsOnDateSet] that contains all elements from [iterable] with unique date.
  factory DateTimeSet.from(Iterable<T> iterable) {
    return DateTimeSet()..addAll(iterable);
  }
}
