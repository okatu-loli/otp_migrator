import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';

void main() {
  test('OtpAlgorithm.fromProto maps values', () {
    expect(OtpAlgorithm.fromProto(1), OtpAlgorithm.sha1);
    expect(OtpAlgorithm.fromProto(2), OtpAlgorithm.sha256);
    expect(OtpAlgorithm.fromProto(3), OtpAlgorithm.sha512);
    expect(OtpAlgorithm.fromProto(4), OtpAlgorithm.md5);
    expect(OtpAlgorithm.fromProto(0), OtpAlgorithm.sha1); // 默认 SHA1
  });
  test('OtpDigits/OtpType map values', () {
    expect(OtpDigits.fromProto(2).count, 8);
    expect(OtpDigits.fromProto(1).count, 6);
    expect(OtpDigits.fromProto(0).count, 6); // 默认 6
    expect(OtpType.fromProto(2), OtpType.totp);
    expect(OtpType.fromProto(1), OtpType.hotp);
  });
  test('OtpAccount holds raw secret bytes', () {
    final a = OtpAccount(
      secret: Uint8List.fromList([1, 2, 3]),
      name: 'n', issuer: 'i',
      algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
      type: OtpType.totp, counter: 0,
    );
    expect(a.secret, [1, 2, 3]);
    expect(a.name, 'n');
  });
}
