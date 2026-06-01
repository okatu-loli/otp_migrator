import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// 解码静态图片字节中的 QR 文本；失败返回 null。纯 Dart，全平台可用。
String? decodeQrFromImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final rgba = decoded.convert(numChannels: 4);
  final pixels = Int32List(rgba.width * rgba.height);
  var i = 0;
  for (final p in rgba) {
    pixels[i++] = (0xFF << 24) |
        (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt();
  }
  final source = RGBLuminanceSource(rgba.width, rgba.height, pixels);
  final bitmap = BinaryBitmap(HybridBinarizer(source));
  try {
    final result = QRCodeReader().decode(bitmap);
    return result.text;
  } on NotFoundException {
    return null;
  } catch (_) {
    return null;
  }
}
