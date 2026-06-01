import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/otpauth_uri.dart';

OtpAccount acc({OtpType type = OtpType.totp, int counter = 0}) => OtpAccount(
      secret: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]), // "Hello"
      name: 'alice@example.com', issuer: 'GitHub',
      algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
      type: type, counter: counter,
    );

void main() {
  test('builds totp uri with base32 secret and label', () {
    final uri = Uri.parse(buildOtpauthUri(acc()));
    expect(uri.scheme, 'otpauth');
    expect(uri.host, 'totp');
    expect(uri.queryParameters['secret'], 'JBSWY3DP'); // base32("Hello"), no padding
    expect(uri.queryParameters['issuer'], 'GitHub');
    expect(uri.queryParameters['algorithm'], 'SHA1');
    expect(uri.queryParameters['digits'], '6');
    expect(Uri.decodeComponent(uri.path.substring(1)), 'GitHub:alice@example.com');
  });

  test('hotp uri includes counter', () {
    final uri = Uri.parse(buildOtpauthUri(acc(type: OtpType.hotp, counter: 42)));
    expect(uri.host, 'hotp');
    expect(uri.queryParameters['counter'], '42');
  });
}
