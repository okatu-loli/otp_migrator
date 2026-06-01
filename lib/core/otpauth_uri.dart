import 'package:base32/base32.dart';
import 'otp_account.dart';

/// 按 Key URI Format 生成标准 otpauth:// 链接。
String buildOtpauthUri(OtpAccount a) {
  final secretB32 = base32.encode(a.secret).replaceAll('=', ''); // 无填充
  final label = a.issuer.isNotEmpty ? '${a.issuer}:${a.name}' : a.name;
  final params = <String, String>{
    'secret': secretB32,
    if (a.issuer.isNotEmpty) 'issuer': a.issuer,
    'algorithm': a.algorithm.label,
    'digits': a.digits.count.toString(),
  };
  if (a.type == OtpType.hotp) {
    params['counter'] = a.counter.toString();
  } else {
    params['period'] = '30';
  }
  final query = params.entries
      .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
  return 'otpauth://${a.type.uriLabel}/${Uri.encodeComponent(label)}?$query';
}
