import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:otp_migrator/core/exporters/csv_exporter.dart';
import 'package:otp_migrator/core/exporters/json_exporter.dart';
import 'package:otp_migrator/core/exporters/text_exporter.dart';
import 'package:otp_migrator/core/exporters/url_exporter.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/otpauth_uri.dart';
import 'package:otp_migrator/export/export_writer.dart';
import 'package:otp_migrator/export/qr_image_renderer.dart';
import 'package:otp_migrator/state/app_state.dart';
import '../theme/app_theme.dart';

/// Supported export formats for the export dialog.
enum ExportFormat { json, csv, text, url, qrImages }

/// A dialog that lets the user choose an export format and save OTP accounts.
///
/// Respects the merge toggle: when merge is enabled, deduped [mergedAccountsProvider]
/// is used; otherwise all accounts from successful [parseGroupsProvider] groups are flattened.
///
/// Usage:
/// ```dart
/// showDialog(context: context, builder: (_) => const ExportDialog());
/// ```
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportFormat _fmt = ExportFormat.json;
  String? _status;
  bool _exporting = false;
  bool _isError = false;

  /// Returns the accounts to export based on the current merge toggle.
  List<OtpAccount> _accounts() {
    if (ref.read(mergeEnabledProvider)) {
      return ref.read(mergedAccountsProvider);
    }
    return [
      for (final g in ref.read(parseGroupsProvider))
        if (g.ok) ...g.accounts,
    ];
  }

  Future<void> _run() async {
    if (_exporting) return;

    final accounts = _accounts();

    // Short-circuit before any native file dialog if there are no accounts.
    if (accounts.isEmpty) {
      setState(() {
        _status = '没有可导出的账户，请先导入 OTP 数据。';
        _isError = true;
      });
      return;
    }

    setState(() {
      _exporting = true;
      _status = null;
    });

    String? dest;
    try {
      switch (_fmt) {
        case ExportFormat.json:
          dest = await ExportWriter.saveTextFile(
            suggestedName: 'otp.json',
            content: exportJson(accounts),
          );
        case ExportFormat.csv:
          dest = await ExportWriter.saveTextFile(
            suggestedName: 'otp.csv',
            content: exportCsv(accounts),
          );
        case ExportFormat.text:
          dest = await ExportWriter.saveTextFile(
            suggestedName: 'otp.txt',
            content: exportText(accounts),
          );
        case ExportFormat.url:
          dest = await ExportWriter.saveTextFile(
            suggestedName: 'otp_urls.txt',
            content: exportUrl(accounts),
          );
        case ExportFormat.qrImages:
          final pngs = <String, Uint8List>{};
          for (var i = 0; i < accounts.length; i++) {
            final a = accounts[i];
            final issuer = a.issuer.replaceAll(RegExp(r'[^\w\-.]'), '_');
            final name = a.name.replaceAll(RegExp(r'[^\w\-.]'), '_');
            final key = '${i + 1}_${issuer}_$name.png';
            pngs[key] = await renderQrPng(buildOtpauthUri(a));
          }
          dest = await ExportWriter.saveQrImages(pngs);
      }

      if (!mounted) return;
      setState(() {
        _exporting = false;
        if (dest == null) {
          _status = '已取消';
          _isError = false;
        } else {
          _status = '导出成功 → $dest';
          _isError = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _status = '导出失败：$e';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final semantics = theme.extension<AppSemanticColors>()!;

    // The status color follows the semantic palette: danger for errors, success for done.
    Color? statusColor;
    if (_status != null) {
      statusColor = _isError ? semantics.danger : semantics.success;
    }

    return AlertDialog(
      // dialogTheme in AppTheme handles elevation / radius / bg / border.
      title: Text('导出', style: theme.textTheme.titleLarge),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----------------------------------------------------------------
            // Format selector — RadioGroup ancestor manages the group value;
            // one RadioListTile per export format.
            // Selected row tinted with accent container per design spec.
            // ----------------------------------------------------------------
            RadioGroup<ExportFormat>(
              groupValue: _fmt,
              onChanged: (v) {
                // Ignore selection changes while an export is in progress.
                if (!_exporting && v != null) setState(() => _fmt = v);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _formatRows(cs, theme),
              ),
            ),

            // ----------------------------------------------------------------
            // Status message — shown only when non-null.
            // ----------------------------------------------------------------
            if (_status != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _isError
                      ? semantics.dangerContainer
                      : semantics.successContainer,
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                  border: Border.all(
                    color: cs.outline,
                    width: AppBorders.hairline,
                  ),
                ),
                child: Text(
                  _status!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _exporting ? null : _run,
          child: _exporting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
              : const Text('导出'),
        ),
      ],
    );
  }

  static const _formatOptions = <(ExportFormat, String)>[
    (ExportFormat.json, 'JSON 文件'),
    (ExportFormat.csv, 'CSV 文件'),
    (ExportFormat.text, '文本 URL 列表'),
    (ExportFormat.url, 'URL 格式'),
    (ExportFormat.qrImages, '二维码图片（每账户一张）'),
  ];

  List<Widget> _formatRows(ColorScheme cs, ThemeData theme) {
    return [
      for (final (fmt, label) in _formatOptions)
        RadioListTile<ExportFormat>(
          value: fmt,
          title: Text(label, style: theme.textTheme.bodyLarge),
          tileColor: _fmt == fmt
              ? cs.primaryContainer.withValues(alpha: 0.55)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          dense: true,
          visualDensity: VisualDensity.compact,
        ),
    ];
  }
}
