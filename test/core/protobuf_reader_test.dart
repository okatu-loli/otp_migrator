import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/protobuf_reader.dart';

void main() {
  test('reads varint key and value', () {
    final r = ProtobufReader(Uint8List.fromList([0x28, 0x00]));
    final tag = r.readTag();
    expect(tag.fieldNumber, 5);
    expect(tag.wireType, WireType.varint);
    expect(r.readVarint(), 0);
    expect(r.isAtEnd, true);
  });

  test('reads length-delimited bytes', () {
    final r = ProtobufReader(Uint8List.fromList([0x0A, 0x03, 0x61, 0x62, 0x63]));
    final tag = r.readTag();
    expect(tag.fieldNumber, 1);
    expect(tag.wireType, WireType.lengthDelimited);
    expect(r.readLengthDelimited(), [0x61, 0x62, 0x63]);
  });

  test('multi-byte varint', () {
    final r = ProtobufReader(Uint8List.fromList([0xAC, 0x02]));
    expect(r.readVarint(), 300);
  });
}
