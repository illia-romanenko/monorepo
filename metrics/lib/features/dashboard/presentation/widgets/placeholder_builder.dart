import 'package:flutter/cupertino.dart';

/// Displays the [placeholder] widget if the data [isLoading].
class PlaceholderBuilder extends StatelessWidget {
  final bool isLoading;
  final WidgetBuilder builder;
  final Widget placeholder;

  /// Creates the [PlaceholderBuilder].
  ///
  /// [isLoading] defines if the data is loading or not.
  /// [placeholder] the widget that will be shown when the data [isLoading].
  /// [builder] is the [WidgetBuilder] which will be called after data is loaded.
  const PlaceholderBuilder({
    Key key,
    this.isLoading,
    this.builder,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return placeholder;

    return builder(context);
  }
}
