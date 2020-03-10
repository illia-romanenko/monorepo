import 'package:flutter/material.dart';
import 'package:metrics/features/common/presentation/metrics_theme/model/build_results_theme_data.dart';
import 'package:metrics/features/common/presentation/metrics_theme/widgets/metrics_theme.dart';
import 'package:metrics/features/dashboard/domain/entities/build.dart';
import 'package:metrics/features/dashboard/presentation/model/build_result_bar_data.dart';
import 'package:metrics/features/dashboard/presentation/widgets/bar_graph.dart';
import 'package:metrics/features/dashboard/presentation/widgets/colored_bar.dart';
import 'package:metrics/features/dashboard/presentation/widgets/expandable_text.dart';
import 'package:metrics/features/dashboard/presentation/widgets/placeholder_bar.dart';
import 'package:url_launcher/url_launcher.dart';

/// [BarGraph] that represents the build result metric.
class BuildResultBarGraph extends StatelessWidget {
  static const _barWidth = 8.0;

  final List<BuildResultBarData> data;
  final String title;
  final TextStyle titleStyle;
  final int numberOfBars;

  /// Creates the [BuildResultBarGraph] based [data] with the [title].
  ///
  /// The [title] and [data] should not be null.
  /// [titleStyle] the [TextStyle] of the [title] text.
  /// [numberOfBars] is the number if the bars on graph.
  /// If the [data] length will be greater than [numberOfBars],
  /// the last [numberOfBars] of the [data] will be shown.
  /// If there will be not enough [data] to display [numberOfBars] bars,
  /// the [PlaceholderBar]s will be added to match the requested [numberOfBars].
  /// If the [numberOfBars] won't be specified,
  /// the [data.length] number of bars will be displayed.
  const BuildResultBarGraph({
    Key key,
    @required this.title,
    @required this.data,
    this.titleStyle,
    this.numberOfBars,
  })  : assert(title != null),
        assert(data != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgetThemeData = MetricsTheme.of(context).buildResultTheme;
    final titleTextStyle = titleStyle ?? widgetThemeData.titleStyle;

    List<BuildResultBarData> barsData = data;
    int missingBarsCount = 0;

    if (numberOfBars != null) {
      if (barsData.length > numberOfBars) {
        barsData = barsData.sublist(barsData.length - numberOfBars);
      } else {
        missingBarsCount = numberOfBars - barsData.length;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ExpandableText(
              title,
              style: titleTextStyle,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: missingBarsCount,
                  child: Row(
                    children: List.generate(
                      missingBarsCount,
                      (index) => const Expanded(
                        child: PlaceholderBar(
                          width: _barWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: barsData.length,
                  child: BarGraph(
                    data: barsData,
                    graphPadding: EdgeInsets.zero,
                    onBarTap: _onBarTap,
                    barBuilder: (BuildResultBarData data) {
                      return Align(
                        alignment: Alignment.center,
                        child: ColoredBar(
                          width: _barWidth,
                          color: _getBuildResultColor(
                            data.result,
                            widgetThemeData,
                          ),
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Selects the color based on [result].
  Color _getBuildResultColor(
    Result result,
    BuildResultsThemeData themeData,
  ) {
    switch (result) {
      case Result.successful:
        return themeData.successfulColor;
      case Result.canceled:
        return themeData.canceledColor;
      case Result.failed:
        return themeData.failedColor;
      default:
        return null;
    }
  }

  /// Opens the [BuildResultBarData] url.
  void _onBarTap(BuildResultBarData data) {
    launch(data.url);
  }
}
