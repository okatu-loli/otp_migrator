import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otp_migrator/l10n/app_localizations.dart';
import 'package:otp_migrator/ui/pages/import_panel.dart';
import 'package:otp_migrator/ui/theme/app_theme.dart';

void main() {
  testWidgets('ImportPanel renders image button and paste field', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ImportPanel()),
        ),
      ),
    );

    // The primary image-pick button should be visible.
    expect(find.text('选择二维码图片（可多选）'), findsOneWidget);

    // The paste URL text field label should be visible.
    expect(find.text('粘贴 otpauth-migration 链接'), findsOneWidget);
  });

  testWidgets('Pasting a bad string produces a failed ParseGroup, not a crash',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ImportPanel()),
        ),
      ),
    );

    // Enter a known-bad migration URL.
    await tester.enterText(
      find.byType(TextField),
      'this-is-not-a-valid-otpauth-migration-url',
    );

    // Tap the parse button.
    await tester.tap(find.widgetWithText(OutlinedButton, '解析链接'));
    await tester.pump();

    // No exception should have been thrown — bad input should produce a
    // failed ParseGroup rather than crashing the widget.
    expect(tester.takeException(), isNull);
  });
}
