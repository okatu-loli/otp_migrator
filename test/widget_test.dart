import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otp_migrator/app.dart';

void main() {
  testWidgets('OtpMigratorApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OtpMigratorApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('OTP Migrator'), findsOneWidget);
  });
}
