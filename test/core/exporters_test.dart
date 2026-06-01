import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/exporters/json_exporter.dart';
import 'package:otp_migrator/core/exporters/csv_exporter.dart';
import 'package:otp_migrator/core/exporters/text_exporter.dart';
import 'package:otp_migrator/core/exporters/url_exporter.dart';

final accounts = [
  OtpAccount(
    secret: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
    name: 'alice', issuer: 'GitHub',
    algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
    type: OtpType.totp, counter: 0,
  ),
];

void main() {
  test('json export contains secret base32 and fields', () {
    final out = jsonDecode(exportJson(accounts)) as List;
    expect(out, hasLength(1));
    expect(out.first['issuer'], 'GitHub');
    expect(out.first['name'], 'alice');
    expect(out.first['secret'], 'JBSWY3DP');
    expect(out.first['type'], 'totp');
    expect(out.first['algorithm'], 'SHA1');
    expect(out.first['digits'], 6);
  });

  test('csv export has header and a data row', () {
    final lines = const LineSplitter().convert(exportCsv(accounts));
    expect(lines.first, 'issuer,name,secret,type,algorithm,digits,counter');
    expect(lines[1], contains('GitHub'));
    expect(lines[1], contains('JBSWY3DP'));
  });

  test('csv quotes fields containing comma', () {
    final tricky = [OtpAccount(
      secret: Uint8List.fromList([0x48,0x65,0x6C,0x6C,0x6F]),
      name: 'a,b', issuer: 'x', algorithm: OtpAlgorithm.sha1,
      digits: OtpDigits.six, type: OtpType.totp, counter: 0)];
    expect(exportCsv(tricky), contains('"a,b"'));
  });

  test('text/url export one otpauth uri per line', () {
    final text = exportText(accounts);
    expect(const LineSplitter().convert(text), hasLength(1));
    expect(text, startsWith('otpauth://totp/'));
    expect(exportUrl(accounts), exportText(accounts));
  });
}
