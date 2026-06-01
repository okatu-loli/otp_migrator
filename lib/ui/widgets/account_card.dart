import 'package:flutter/material.dart';

import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/otpauth_uri.dart';
import 'package:otp_migrator/core/secret_encoding.dart';
import 'package:otp_migrator/ui/widgets/qr_preview_dialog.dart';
import '../theme/app_theme.dart';

/// A card that renders a single [OtpAccount] in the "Terminal Ledger" style.
///
/// Shows:
/// - Title (issuer · name or just name).
/// - Metadata line (type · algorithm · digits) in a mono eyebrow.
/// - The base32 secret in a tonal "code chip" surface (selectable, mono).
/// - A trailing QR button that opens [QrPreviewDialog].
class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.account});

  final OtpAccount account;

  String get _title => account.issuer.isEmpty
      ? account.name
      : '${account.issuer} · ${account.name}';

  String get _meta =>
      '${account.type.uriLabel.toUpperCase()} · '
      '${account.algorithm.label} · '
      '${account.digits.count} 位';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Resolve the code-chip background — prefer surfaceContainer so it reads
    // as a tonal inset on both light and dark. The surfaceVariant design role
    // maps to surfaceContainerHighest in Material 3; fall back gracefully.
    final chipBg = cs.surfaceContainerHighest == cs.surface
        ? cs.surfaceContainer
        : cs.surfaceContainerHighest;

    final secretB32 = base32NoPad(account.secret);

    return Card(
      // cardTheme in AppTheme sets elevation 0, hairline border, AppRadii.card.
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------------
            // Leading monogram avatar
            // ----------------------------------------------------------------
            _MonogramAvatar(
              label: account.issuer.isNotEmpty ? account.issuer : account.name,
              cs: cs,
            ),
            const SizedBox(width: AppSpacing.md),

            // ----------------------------------------------------------------
            // Content column
            // ----------------------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _title,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: AppSpacing.xxs),

                  // Metadata line — mono eyebrow
                  Text(
                    _meta,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: AppTheme.monoFontFamily,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Secret code chip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(AppRadii.chip),
                      border: Border.all(
                        color: cs.outline,
                        width: AppBorders.hairline,
                      ),
                    ),
                    child: SelectableText(
                      secretB32,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: AppTheme.monoFontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------------------
            // Trailing QR button
            // ----------------------------------------------------------------
            IconButton(
              icon: const Icon(Icons.qr_code_2),
              tooltip: '显示二维码',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => QrPreviewDialog(
                  data: buildOtpauthUri(account),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// A 40×40 avatar that shows the first character of [label] in
/// secondaryContainer fill with control-radius corners.
class _MonogramAvatar extends StatelessWidget {
  const _MonogramAvatar({required this.label, required this.cs});

  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final initial =
        label.isNotEmpty ? label.characters.first.toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: cs.onSecondaryContainer,
        ),
      ),
    );
  }
}
