import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/migration_decoder.dart';

final kSampleBytes = Uint8List.fromList([
  0x0A,0x17,0x0A,0x05,0x48,0x65,0x6C,0x6C,0x6F,0x12,0x03,0x61,0x63,0x63,
  0x1A,0x03,0x69,0x73,0x73,0x20,0x01,0x28,0x01,0x30,0x02,
  0x10,0x02,0x18,0x01,0x20,0x00,0x28,0x00,
]);

String sampleUrl() =>
    'otpauth-migration://offline?data=${Uri.encodeComponent(base64Encode(kSampleBytes))}';

void main() {
  test('decodes a single account from migration url', () {
    final accounts = MigrationDecoder.decodeUrl(sampleUrl());
    expect(accounts, hasLength(1));
    final a = accounts.single;
    expect(a.secret, [0x48, 0x65, 0x6C, 0x6C, 0x6F]); // "Hello"
    expect(a.name, 'acc');
    expect(a.issuer, 'iss');
    expect(a.algorithm, OtpAlgorithm.sha1);
    expect(a.digits, OtpDigits.six);
    expect(a.type, OtpType.totp);
  });

  test('decodes from raw payload bytes', () {
    final accounts = MigrationDecoder.decodePayloadBytes(kSampleBytes);
    expect(accounts.single.issuer, 'iss');
  });

  test('rejects non-migration url', () {
    expect(() => MigrationDecoder.decodeUrl('otpauth://totp/x?secret=AA'),
        throwsA(isA<MigrationFormatException>()));
  });

  test('rejects corrupt base64', () {
    expect(() => MigrationDecoder.decodeUrl('otpauth-migration://offline?data=%%%'),
        throwsA(isA<MigrationFormatException>()));
  });
}
