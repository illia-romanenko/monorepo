/// Provides util methods to work with [DateTime].
class DateTimeUtil {
  /// Trims the date to include only the year, month and day.
  static DateTime trimToDay(DateTime buildDate) =>
      DateTime(buildDate.year, buildDate.month, buildDate.day);
}
