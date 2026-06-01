import '../otp_account.dart';
import '../secret_encoding.dart';

/// 防止电子表格公式注入：以 = + - @ 开头的字段（issuer/name 来自被扫描的二维码，
/// 可能被构造为恶意公式）加前导单引号，使其被当作纯文本。
String _neutralizeFormula(String v) =>
    (v.isNotEmpty && (v.startsWith('=') || v.startsWith('+') || v.startsWith('-') || v.startsWith('@')))
        ? "'$v"
        : v;

String _cell(String v) {
  final s = _neutralizeFormula(v);
  return (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r'))
      ? '"${s.replaceAll('"', '""')}"'
      : s;
}

String exportCsv(List<OtpAccount> accounts) {
  final rows = <String>['issuer,name,secret,type,algorithm,digits,counter'];
  for (final a in accounts) {
    rows.add([
      _cell(a.issuer),
      _cell(a.name),
      _cell(base32NoPad(a.secret)),
      a.type.uriLabel,
      a.algorithm.label,
      a.digits.count.toString(),
      a.counter.toString(),
    ].join(','));
  }
  return rows.join('\n');
}
