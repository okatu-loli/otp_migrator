import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';

/// Dialog that renders an otpauth:// URL as a scannable QR code alongside
/// the raw URL in a selectable monospace "code chip" — the design's canonical
/// treatment for credentials / data under glass.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => QrPreviewDialog(data: entry.otpauthUrl),
/// );
/// ```
class QrPreviewDialog extends StatelessWidget {
  const QrPreviewDialog({super.key, required this.data});

  /// The `otpauth://` URL to encode and display.
  final String data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      // dialogTheme in AppTheme handles elevation/radius/bg/border.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----------------------------------------------------------------
              // Title
              // ----------------------------------------------------------------
              Text(
                'Scan QR Code',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ----------------------------------------------------------------
              // QR image — always on a white background for scannability,
              // regardless of the app theme.
              // ----------------------------------------------------------------
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(
                      color: cs.outline,
                      width: AppBorders.hairline,
                    ),
                  ),
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 260,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ----------------------------------------------------------------
              // Code chip — selectable mono URL (design's "data under glass").
              // ----------------------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest == cs.surface
                      ? cs.surfaceContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                  border: Border.all(
                    color: cs.outline,
                    width: AppBorders.hairline,
                  ),
                ),
                child: SelectableText(
                  data,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppTheme.monoFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ----------------------------------------------------------------
              // Actions — close (TextButton, per design tertiary / inline role).
              // ----------------------------------------------------------------
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
