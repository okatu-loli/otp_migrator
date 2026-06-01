import 'dart:convert';
import '../core/otp_account.dart';

class ParseGroup {
  const ParseGroup({required this.sourceLabel, required this.accounts, this.error});
  final String sourceLabel;
  final List<OtpAccount> accounts;
  final String? error;
  bool get ok => error == null;
}

String _keyOf(OtpAccount a) =>
    '${base64Encode(a.secret)}|${a.name}|${a.issuer}';

/// 扁平化所有成功组并按 secret+name+issuer 去重（保留首次出现）。
List<OtpAccount> mergeDedup(List<ParseGroup> groups) {
  final seen = <String>{};
  final out = <OtpAccount>[];
  for (final g in groups) {
    if (!g.ok) continue;
    for (final acc in g.accounts) {
      if (seen.add(_keyOf(acc))) out.add(acc);
    }
  }
  return out;
}
