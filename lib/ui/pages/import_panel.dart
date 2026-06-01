import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:otp_migrator/core/migration_decoder.dart';
import 'package:otp_migrator/scan/camera_scanner.dart';
import 'package:otp_migrator/scan/image_qr_decoder.dart';
import 'package:otp_migrator/state/app_state.dart';
import 'package:otp_migrator/state/parse_group.dart';
import '../theme/app_theme.dart';

/// Import panel — "Terminal Ledger" styled.
///
/// Lets the user feed OTP migration data via:
///   1. Image file(s) containing QR codes.
///   2. Camera scan (when [cameraScanSupported]).
///   3. Pasted otpauth-migration:// URL.
///
/// Each successful or failed parse is surfaced as a [ParseGroup] added to
/// [parseGroupsProvider].
class ImportPanel extends ConsumerStatefulWidget {
  const ImportPanel({super.key});

  @override
  ConsumerState<ImportPanel> createState() => _ImportPanelState();
}

class _ImportPanelState extends ConsumerState<ImportPanel> {
  final TextEditingController _pasteController = TextEditingController();

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Build a [ParseGroup] from a label and a nullable QR url string.
  ParseGroup _groupFor(String label, String? url) {
    if (url == null || url.isEmpty) {
      return ParseGroup(
        sourceLabel: label,
        accounts: const [],
        error: '未识别二维码',
      );
    }
    try {
      final accounts = MigrationDecoder.decodeUrl(url);
      return ParseGroup(sourceLabel: label, accounts: accounts);
    } catch (e) {
      return ParseGroup(sourceLabel: label, accounts: const [], error: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (result == null) return;
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      final url = decodeQrFromImageBytes(bytes);
      ref.read(parseGroupsProvider.notifier).add(_groupFor(file.name, url));
    }
  }

  void _decodePasted() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;
    ref.read(parseGroupsProvider.notifier).add(_groupFor('粘贴', text));
    _pasteController.clear();
  }

  void _openCamera() {
    if (!cameraScanSupported) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 360,
          height: 360,
          child: CameraScannerView(
            onDetect: (value) {
              Navigator.pop(ctx);
              ref
                  .read(parseGroupsProvider.notifier)
                  .add(_groupFor('摄像头', value.trim()));
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<AppSemanticColors>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        // Web security warning ---------------------------------------------------
        if (kIsWeb) ...[
          Card(
            color: semantics.warningContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.card),
              side: BorderSide(
                color: semantics.warning,
                width: AppBorders.hairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                '⚠️ 浏览器环境处理 OTP 凭据存在泄露风险，敏感场景建议使用桌面端。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: semantics.onWarningContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Image pick button -------------------------------------------------------
        FilledButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.image_outlined),
          label: const Text('选择二维码图片（可多选）'),
        ),

        // Camera button (shown only when supported) --------------------------------
        if (cameraScanSupported) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('摄像头扫码'),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Paste URL field ---------------------------------------------------------
        TextField(
          controller: _pasteController,
          minLines: 2,
          maxLines: 4,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: AppTheme.monoFontFamily,
          ),
          decoration: const InputDecoration(
            labelText: '粘贴 otpauth-migration 链接',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Parse button ------------------------------------------------------------
        OutlinedButton(
          onPressed: _decodePasted,
          child: const Text('解析链接'),
        ),
      ],
    );
  }
}
