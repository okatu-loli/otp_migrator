import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// mobile_scanner 仅支持 iOS/Android/macOS/Web；其余平台隐藏摄像头入口。
/// 用 defaultTargetPlatform 判定，避免引入 dart:io（保证 Web 编译与跨工具链兼容）。
bool get cameraScanSupported {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
    case TargetPlatform.macOS:
      return true;
    default:
      return false;
  }
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
