import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otp_migrator/ui/theme/app_theme.dart';
import 'package:otp_migrator/ui/pages/home_page.dart';
import 'package:otp_migrator/ui/pages/import_panel.dart';
import 'package:otp_migrator/ui/pages/results_panel.dart';

void main() {
  testWidgets('wide layout shows both panels side by side', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: const HomePage())));
    await tester.pumpAndSettle();
    expect(find.byType(ImportPanel), findsOneWidget);
    expect(find.byType(ResultsPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow layout uses tabs', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: const HomePage())));
    await tester.pumpAndSettle();
    expect(find.text('导入'), findsWidgets);
    expect(find.text('结果'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
