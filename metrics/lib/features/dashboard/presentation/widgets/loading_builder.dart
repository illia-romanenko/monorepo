import 'package:flutter/cupertino.dart';

/// Displays the [loadingPlaceholder] widget if the data [isLoading].
class LoadingBuilder extends StatelessWidget {
  final bool isLoading;
  final WidgetBuilder builder;
  final Widget loadingPlaceholder;

  /// Creates the [LoadingBuilder].
  ///
  /// [isLoading] defines if the data is loading or not.
  /// [loadingPlaceholder] the widget that will be shown when the data [isLoading].
  /// [builder] is the [WidgetBuilder] which will be called after data is loaded.
  const LoadingBuilder({
    Key key,
    this.isLoading,
    this.builder,
    this.loadingPlaceholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return loadingPlaceholder;

    return builder(context);
  }
}
