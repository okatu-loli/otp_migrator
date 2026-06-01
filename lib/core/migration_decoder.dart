import 'dart:convert';
import 'dart:typed_data';
import 'otp_account.dart';
import 'protobuf_reader.dart';

class MigrationFormatException implements Exception {
  const MigrationFormatException(this.message);
  final String message;
  @override
  String toString() => 'MigrationFormatException: $message';
}

class MigrationDecoder {
  /// 解析完整的 otpauth-migration:// URL。
  static List<OtpAccount> decodeUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'otpauth-migration') {
      throw const MigrationFormatException('不是 otpauth-migration 链接');
    }
    final data = uri.queryParameters['data'];
    if (data == null || data.isEmpty) {
      throw const MigrationFormatException('链接缺少 data 参数');
    }
    final Uint8List bytes;
    try {
      bytes = _decodeBase64(data);
    } on FormatException {
      throw const MigrationFormatException('data 不是合法的 base64');
    }
    return decodePayloadBytes(bytes);
  }

  static Uint8List _decodeBase64(String s) {
    var normalized = s.replaceAll('-', '+').replaceAll('_', '/');
    final pad = normalized.length % 4;
    if (pad > 0) normalized = normalized.padRight(normalized.length + (4 - pad), '=');
    return base64Decode(normalized);
  }

  /// 解析 MigrationPayload protobuf 字节。
  static List<OtpAccount> decodePayloadBytes(Uint8List payload) {
    final reader = ProtobufReader(payload);
    final accounts = <OtpAccount>[];
    try {
      while (!reader.isAtEnd) {
        final tag = reader.readTag();
        if (tag.fieldNumber == 1 && tag.wireType == WireType.lengthDelimited) {
          accounts.add(_parseOtpParameters(reader.readLengthDelimited()));
        } else {
          reader.skip(tag.wireType);
        }
      }
    } on FormatException catch (e) {
      throw MigrationFormatException('protobuf 解析失败：${e.message}');
    }
    if (accounts.isEmpty) {
      throw const MigrationFormatException('未找到任何账户');
    }
    return accounts;
  }

  static OtpAccount _parseOtpParameters(Uint8List bytes) {
    final reader = ProtobufReader(bytes);
    Uint8List secret = Uint8List(0);
    String name = '';
    String issuer = '';
    int algorithm = 1, digits = 1, type = 2, counter = 0;
    while (!reader.isAtEnd) {
      final tag = reader.readTag();
      switch (tag.fieldNumber) {
        case 1:
          secret = reader.readLengthDelimited();
        case 2:
          name = utf8.decode(reader.readLengthDelimited());
        case 3:
          issuer = utf8.decode(reader.readLengthDelimited());
        case 4:
          algorithm = reader.readVarint();
        case 5:
          digits = reader.readVarint();
        case 6:
          type = reader.readVarint();
        case 7:
          counter = reader.readVarint();
        default:
          reader.skip(tag.wireType);
      }
    }
    return OtpAccount(
      secret: secret,
      name: name,
      issuer: issuer,
      algorithm: OtpAlgorithm.fromProto(algorithm),
      digits: OtpDigits.fromProto(digits),
      type: OtpType.fromProto(type),
      counter: counter,
    );
  }
}
