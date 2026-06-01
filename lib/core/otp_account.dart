import 'dart:typed_data';

enum OtpAlgorithm {
  sha1('SHA1'), sha256('SHA256'), sha512('SHA512'), md5('MD5');
  const OtpAlgorithm(this.label);
  final String label;
  static OtpAlgorithm fromProto(int v) => switch (v) {
        2 => OtpAlgorithm.sha256,
        3 => OtpAlgorithm.sha512,
        4 => OtpAlgorithm.md5,
        _ => OtpAlgorithm.sha1, // 0/1 → SHA1
      };
}

enum OtpDigits {
  six(6), eight(8);
  const OtpDigits(this.count);
  final int count;
  static OtpDigits fromProto(int v) => v == 2 ? OtpDigits.eight : OtpDigits.six;
}

enum OtpType {
  totp('totp'), hotp('hotp');
  const OtpType(this.uriLabel);
  final String uriLabel;
  static OtpType fromProto(int v) => v == 1 ? OtpType.hotp : OtpType.totp;
}

class OtpAccount {
  const OtpAccount({
    required this.secret,
    required this.name,
    required this.issuer,
    required this.algorithm,
    required this.digits,
    required this.type,
    required this.counter,
  });

  final Uint8List secret; // 原始字节；base32 在 otpauth_uri 中生成
  final String name;
  final String issuer;
  final OtpAlgorithm algorithm;
  final OtpDigits digits;
  final OtpType type;
  final int counter; // 仅 HOTP 有意义
}
