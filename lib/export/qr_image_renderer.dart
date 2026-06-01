import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';

/// Renders an otpauth:// URL (or any string) into PNG bytes.
Future<Uint8List> renderQrPng(String data, {double size = 512}) async {
  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: true,
  );
  final ByteData? bytes =
      await painter.toImageData(size, format: ui.ImageByteFormat.png);
  if (bytes == null) {
    throw StateError('QR 渲染失败: toImageData returned null');
  }
  return bytes.buffer.asUint8List();
}
