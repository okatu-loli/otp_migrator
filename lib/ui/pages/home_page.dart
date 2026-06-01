import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'import_panel.dart';
import 'results_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.expanded) {
          // Wide layout: two panels side by side.
          return Scaffold(
            appBar: AppBar(title: const Text('OTP Migrator')),
            body: const Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: ImportPanel()),
                VerticalDivider(width: 1),
                Expanded(flex: 3, child: ResultsPanel()),
              ],
            ),
          );
        }

        // Narrow layout: tabbed view.
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('OTP Migrator'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: '导入'),
                  Tab(text: '结果'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                ImportPanel(),
                ResultsPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}
