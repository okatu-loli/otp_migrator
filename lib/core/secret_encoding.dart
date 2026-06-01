import 'dart:typed_data';
import 'package:base32/base32.dart';

/// RFC4648 base32 编码，去掉尾部填充 '='（otpauth/导出统一用此形态）。
String base32NoPad(Uint8List secret) => base32.encode(secret).replaceAll('=', '');
