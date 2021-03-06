import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metrics/features/common/presentation/injector/widget/injection_container.dart';
import 'package:metrics/features/common/presentation/metrics_theme/widgets/metrics_theme_builder.dart';
import 'package:metrics/features/dashboard/presentation/pages/dashboard_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return InjectionContainer(
      child: MetricsThemeBuilder(
        builder: (context, store) {
          final isDark = store?.isDark ?? true;

          return MaterialApp(
            title: 'Metrics',
            routes: {
              '/dashboard': (context) => DashboardPage(),
            },
            theme: ThemeData(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primarySwatch: Colors.blue,
              fontFamily: 'Bebas Neue',
            ),
            home: DashboardPage(),
          );
        },
      ),
    );
  }
}
