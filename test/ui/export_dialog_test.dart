import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otp_migrator/ui/theme/app_theme.dart';
import 'package:otp_migrator/ui/pages/export_dialog.dart';

void main() {
  testWidgets('renders formats and handles empty export', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ExportDialog()),
      ),
    ));

    // Title is visible.
    expect(find.text('导出'), findsWidgets);

    // All five format labels render.
    expect(find.text('JSON 文件'), findsOneWidget);
    expect(find.text('CSV 文件'), findsOneWidget);
    expect(find.text('文本 URL 列表'), findsOneWidget);
    expect(find.text('URL 格式'), findsOneWidget);
    expect(find.text('二维码图片（每账户一张）'), findsOneWidget);

    // Tap 导出 — no accounts loaded, so the empty-check short-circuits
    // before any native file dialog is opened.
    await tester.tap(find.widgetWithText(FilledButton, '导出'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // A status message should appear, no exception thrown.
    expect(tester.takeException(), isNull);
    // The no-accounts message should be visible somewhere in the tree.
    expect(
      find.textContaining('没有可导出的账户'),
      findsOneWidget,
    );
  });
}
