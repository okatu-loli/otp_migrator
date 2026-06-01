import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/state/parse_group.dart';

OtpAccount a(List<int> secret, String name) => OtpAccount(
      secret: Uint8List.fromList(secret), name: name, issuer: 'i',
      algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
      type: OtpType.totp, counter: 0);

void main() {
  test('mergeDedup flattens groups and dedupes by secret+name', () {
    final groups = [
      ParseGroup(sourceLabel: 'q1.png', accounts: [a([1], 'x'), a([2], 'y')]),
      ParseGroup(sourceLabel: 'q2.png', accounts: [a([2], 'y'), a([3], 'z')]),
    ];
    final merged = mergeDedup(groups);
    expect(merged.map((e) => e.name), ['x', 'y', 'z']); // 保留首次出现
  });

  test('failed groups are ignored in merge', () {
    final groups = [
      ParseGroup(sourceLabel: 'bad.png', accounts: const [], error: '解码失败'),
      ParseGroup(sourceLabel: 'q.png', accounts: [a([9], 'k')]),
    ];
    expect(mergeDedup(groups).single.name, 'k');
  });
}
