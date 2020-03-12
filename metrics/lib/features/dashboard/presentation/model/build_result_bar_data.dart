import 'package:meta/meta.dart';
import 'package:metrics/features/dashboard/domain/entities/core/build_status.dart';
import 'package:metrics/features/dashboard/presentation/model/bar_data.dart';

/// Represents the data of the bar to display in [BarGraph].
@immutable
class BuildResultBarData implements BarData {
  @override
  final int value;
  final BuildStatus result;
  final String url;

  /// Creates the [BuildResultBarData].
  ///
  /// The [value] is the bar value.
  /// The height of the bar will be calculated based on this value.
  /// [result] is the result of the build.
  /// The color of the [BuildResultBar] will be obtained from this value.
  /// [url] is the url of the CI build.
  const BuildResultBarData({
    this.value,
    this.result,
    this.url,
  });
}
