import 'dart:convert';
import '../otp_account.dart';
import '../secret_encoding.dart';

String exportJson(List<OtpAccount> accounts) {
  final list = accounts.map((a) => {
        'issuer': a.issuer,
        'name': a.name,
        'secret': base32NoPad(a.secret),
        'type': a.type.uriLabel,
        'algorithm': a.algorithm.label,
        'digits': a.digits.count,
        'counter': a.counter,
      }).toList();
  return const JsonEncoder.withIndent('  ').convert(list);
}
