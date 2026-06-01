import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// mobile_scanner 仅支持 iOS/Android/macOS/Web；其余平台隐藏摄像头入口。
bool get cameraScanSupported {
  if (kIsWeb) return true;
  return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
}

/// 简单的扫码视图；命中后回调 url 文本（可能是 otpauth-migration）。
class CameraScannerView extends StatelessWidget {
  const CameraScannerView({super.key, required this.onDetect});
  final void Function(String value) onDetect;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (capture) {
        for (final barcode in capture.barcodes) {
          final raw = barcode.rawValue;
          if (raw != null && raw.isNotEmpty) {
            onDetect(raw);
            break;
          }
        }
      },
    );
  }
}
