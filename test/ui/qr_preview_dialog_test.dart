import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:otp_migrator/l10n/app_localizations.dart';
import 'package:otp_migrator/ui/theme/app_theme.dart';
import 'package:otp_migrator/ui/widgets/qr_preview_dialog.dart';

void main() {
  testWidgets('shows data and a QR', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Center(
          child: QrPreviewDialog(
            data: 'otpauth://totp/x?secret=JBSWY3DP',
          ),
        ),
      ),
    ));
    expect(find.text('otpauth://totp/x?secret=JBSWY3DP'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
