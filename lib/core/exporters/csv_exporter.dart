import 'package:base32/base32.dart';
import '../otp_account.dart';

String _cell(String v) =>
    (v.contains(',') || v.contains('"') || v.contains('\n'))
        ? '"${v.replaceAll('"', '""')}"'
        : v;

String exportCsv(List<OtpAccount> accounts) {
  final rows = <String>['issuer,name,secret,type,algorithm,digits,counter'];
  for (final a in accounts) {
    rows.add([
      _cell(a.issuer),
      _cell(a.name),
      _cell(base32.encode(a.secret).replaceAll('=', '')),
      a.type.uriLabel,
      a.algorithm.label,
      a.digits.count.toString(),
      a.counter.toString(),
    ].join(','));
  }
  return rows.join('\n');
}
