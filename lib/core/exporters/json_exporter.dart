import 'dart:convert';
import 'package:base32/base32.dart';
import '../otp_account.dart';

String exportJson(List<OtpAccount> accounts) {
  final list = accounts.map((a) => {
        'issuer': a.issuer,
        'name': a.name,
        'secret': base32.encode(a.secret).replaceAll('=', ''),
        'type': a.type.uriLabel,
        'algorithm': a.algorithm.label,
        'digits': a.digits.count,
        'counter': a.counter,
      }).toList();
  return const JsonEncoder.withIndent('  ').convert(list);
}
