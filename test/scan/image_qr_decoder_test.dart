import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';
import 'package:otp_migrator/scan/image_qr_decoder.dart';

/// 用 qr 包把文本画成黑白 PNG 字节（每模块 8px，4 模块静区）。
Uint8List makeQrPng(String text) {
  final code = QrCode.fromData(errorCorrectLevel: QrErrorCorrectLevel.M, data: text);
  final qrImage = QrImage(code);
  const scale = 8, quiet = 4;
  final n = code.moduleCount;
  final size = (n + quiet * 2) * scale;
  final picture = img.Image(width: size, height: size);
  img.fill(picture, color: img.ColorRgb8(255, 255, 255));
  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      if (qrImage.isDark(y, x)) {
        img.fillRect(picture,
            x1: (x + quiet) * scale, y1: (y + quiet) * scale,
            x2: (x + quiet + 1) * scale - 1, y2: (y + quiet + 1) * scale - 1,
            color: img.ColorRgb8(0, 0, 0));
      }
    }
  }
  return Uint8List.fromList(img.encodePng(picture));
}

void main() {
  test('decodes QR text from PNG bytes', () {
    const text = 'otpauth-migration://offline?data=ABC';
    final png = makeQrPng(text);
    expect(decodeQrFromImageBytes(png), text);
  });

  test('returns null for non-QR image', () {
    final blank = img.Image(width: 32, height: 32);
    img.fill(blank, color: img.ColorRgb8(200, 200, 200));
    expect(decodeQrFromImageBytes(Uint8List.fromList(img.encodePng(blank))), isNull);
  });
}
