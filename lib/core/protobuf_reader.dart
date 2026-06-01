import 'dart:typed_data';

enum WireType { varint, fixed64, lengthDelimited, fixed32, unknown }

class ProtoTag {
  const ProtoTag(this.fieldNumber, this.wireType);
  final int fieldNumber;
  final WireType wireType;
}

/// 极简 protobuf wire-format 读取器，仅覆盖 MigrationPayload 所需类型。
class ProtobufReader {
  ProtobufReader(this._bytes);
  final Uint8List _bytes;
  int _pos = 0;

  bool get isAtEnd => _pos >= _bytes.length;

  /// Returns a Dart 64-bit int matching protobuf int64 wire semantics.
  /// MigrationPayload contains no uint64 fields, so sign-bit reinterpretation
  /// of values ≥ 2^63 is not a concern for this schema.
  int readVarint() {
    int result = 0;
    int shift = 0;
    while (true) {
      if (_pos >= _bytes.length) {
        throw const FormatException('protobuf: unexpected end while reading varint');
      }
      final b = _bytes[_pos++];
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) break;
      shift += 7;
      if (shift > 63) throw const FormatException('protobuf: varint too long');
    }
    return result;
  }

  ProtoTag readTag() {
    final key = readVarint();
    final fieldNumber = key >> 3;
    final wire = switch (key & 0x7) {
      0 => WireType.varint,
      1 => WireType.fixed64,
      2 => WireType.lengthDelimited,
      5 => WireType.fixed32,
      _ => WireType.unknown,
    };
    return ProtoTag(fieldNumber, wire);
  }

  Uint8List readLengthDelimited() {
    final len = readVarint();
    if (_pos + len > _bytes.length) {
      throw const FormatException('protobuf: length-delimited overruns buffer');
    }
    final out = Uint8List.sublistView(_bytes, _pos, _pos + len);
    _pos += len;
    return Uint8List.fromList(out);
  }

  /// 跳过未知字段，保证向前兼容。
  void skip(WireType wireType) {
    switch (wireType) {
      case WireType.varint:
        readVarint();
      case WireType.fixed64:
        _pos += 8;
      case WireType.lengthDelimited:
        final len = readVarint();
        _pos += len;
      case WireType.fixed32:
        _pos += 4;
      case WireType.unknown:
        throw const FormatException('protobuf: unknown wire type');
    }
    if (_pos > _bytes.length) {
      throw const FormatException('protobuf: skip overruns buffer');
    }
  }
}
