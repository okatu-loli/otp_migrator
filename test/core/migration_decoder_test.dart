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

  // Fix A: use a syntactically valid URI whose data value is valid
  // percent-encoding but invalid base64, forcing the base64 catch branch.
  // '!!!!' is 4 chars (already padded) with '!' not in the base64 alphabet,
  // so _decodeBase64 → base64Decode throws FormatException, not the
  // scheme/null check.
  test('rejects invalid base64 data', () {
    final url = Uri(
      scheme: 'otpauth-migration',
      host: 'offline',
      queryParameters: {'data': '!!!!'},
    ).toString();
    expect(() => MigrationDecoder.decodeUrl(url),
        throwsA(isA<MigrationFormatException>()));
  });

  // Fix B-1: missing data param is rejected
  test('rejects url missing data param', () {
    expect(() => MigrationDecoder.decodeUrl('otpauth-migration://offline'),
        throwsA(isA<MigrationFormatException>()));
  });

  // Fix B-2: url-safe base64 (- _ without padding) is accepted
  test('handles url-safe base64 (- _ and no padding)', () {
    final urlSafe = base64Encode(kSampleBytes)
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '');
    final url =
        'otpauth-migration://offline?data=${Uri.encodeComponent(urlSafe)}';
    final accounts = MigrationDecoder.decodeUrl(url);
    expect(accounts.single.issuer, 'iss');
  });

  // Fix B-3: HOTP with counter > 0
  // Inner OtpParameters bytes (field1=secret "Hi", field6=type HOTP, field7=counter 5):
  //   0A 02 48 69   (secret = [0x48,0x69])
  //   30 01         (type = 1 = HOTP)
  //   38 05         (counter = 5)
  // Wrapped in outer field1 length-delimited (0x08 = 8 bytes):
  //   0A 08 0A 02 48 69 30 01 38 05
  test('decodes HOTP with counter', () {
    final bytes = Uint8List.fromList(
        [0x0A, 0x08, 0x0A, 0x02, 0x48, 0x69, 0x30, 0x01, 0x38, 0x05]);
    final a = MigrationDecoder.decodePayloadBytes(bytes).single;
    expect(a.type, OtpType.hotp);
    expect(a.counter, 5);
    expect(a.secret, [0x48, 0x69]);
  });
}
