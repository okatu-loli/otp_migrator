import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/state/app_state.dart';
import 'package:otp_migrator/state/parse_group.dart';
import 'package:otp_migrator/ui/pages/results_panel.dart';
import 'package:otp_migrator/ui/widgets/account_card.dart';
import 'package:otp_migrator/ui/theme/app_theme.dart';

/// A known OtpAccount: secret [0x48, 0x65, 0x6C, 0x6C, 0x6F] = "Hello"
/// → base32NoPad → 'JBSWY3DP'
OtpAccount get _testAccount => OtpAccount(
      secret: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
      name: 'alice',
      issuer: 'GitHub',
      algorithm: OtpAlgorithm.sha1,
      digits: OtpDigits.six,
      type: OtpType.totp,
      counter: 0,
    );

void main() {
  // -------------------------------------------------------------------------
  // Empty state
  // -------------------------------------------------------------------------
  testWidgets('ResultsPanel shows empty hint when no groups imported',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ResultsPanel()),
        ),
      ),
    );

    expect(
      find.text('从左侧导入二维码后，这里显示解析结果'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });

  // -------------------------------------------------------------------------
  // Populated state — inject a ParseGroup via the real ProviderScope container
  // -------------------------------------------------------------------------
  testWidgets(
      'ResultsPanel shows AccountCard with issuer, name and base32 secret',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ResultsPanel()),
        ),
      ),
    );

    // Initially empty.
    expect(find.text('从左侧导入二维码后，这里显示解析结果'), findsOneWidget);

    // Obtain the ProviderContainer from the widget tree.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ResultsPanel)),
    );

    // Add a ParseGroup with one account.
    container.read(parseGroupsProvider.notifier).add(
          ParseGroup(
            sourceLabel: 'q.png',
            accounts: [_testAccount],
          ),
        );

    // Rebuild the frame.
    await tester.pump();

    // An AccountCard should be in the tree.
    expect(find.byType(AccountCard), findsOneWidget);

    // The title is 'GitHub · alice'.
    expect(find.text('GitHub · alice'), findsOneWidget);

    // The base32-encoded secret must appear in the code chip.
    // find.text works for both Text and SelectableText.
    expect(find.text('JBSWY3DP'), findsOneWidget);

    // The export button should be present.
    expect(find.text('导出'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  // -------------------------------------------------------------------------
  // Failed group — header rendered in danger color, no crash
  // -------------------------------------------------------------------------
  testWidgets('ResultsPanel renders failed group header without crashing',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: ResultsPanel()),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ResultsPanel)),
    );

    container.read(parseGroupsProvider.notifier).add(
          const ParseGroup(
            sourceLabel: 'bad.png',
            accounts: [],
            error: '未识别二维码',
          ),
        );

    await tester.pump();

    // The header should contain the source label.
    expect(find.textContaining('BAD.PNG'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
