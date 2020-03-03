import 'package:flutter/material.dart';

/// Displays the loading placeholder.
class LoadingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
