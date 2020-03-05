import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/features/dashboard/presentation/widgets/loading_builder.dart';

void main() {
  testWidgets(
    "Can't create a LoadingBuilder without a builder",
    (WidgetTester tester) async {
      await tester.pumpWidget(const LoadingBuilderTestbed(builder: null));

      expect(tester.takeException(), isA<AssertionError>());
    },
  );

  testWidgets(
    "Can't create a LoadingBuilder when the isLoading is null",
    (WidgetTester tester) async {
      await tester.pumpWidget(const LoadingBuilderTestbed(isLoading: null));

      expect(tester.takeException(), isA<AssertionError>());
    },
  );
}

class LoadingBuilderTestbed extends StatelessWidget {
  final bool isLoading;
  final WidgetBuilder builder;

  const LoadingBuilderTestbed({
    Key key,
    this.isLoading = false,
    this.builder = _defaultBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LoadingBuilder(
          isLoading: isLoading,
          builder: builder,
        ),
      ),
    );
  }

  static Widget _defaultBuilder(BuildContext context) {
    return Container();
  }
}
