import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/otp_account.dart';
import 'parse_group.dart';

/// 所有解析组（按来源）。
final parseGroupsProvider =
    NotifierProvider<ParseGroupsNotifier, List<ParseGroup>>(ParseGroupsNotifier.new);

class ParseGroupsNotifier extends Notifier<List<ParseGroup>> {
  @override
  List<ParseGroup> build() => const [];
  void add(ParseGroup g) => state = [...state, g];
  void clear() => state = const [];
  void removeAt(int i) => state = [...state]..removeAt(i);
}

/// 合并导出开关。
final mergeEnabledProvider =
    NotifierProvider<MergeNotifier, bool>(MergeNotifier.new);

class MergeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

/// 派生：合并去重后的账户列表。
final mergedAccountsProvider = Provider<List<OtpAccount>>(
    (ref) => mergeDedup(ref.watch(parseGroupsProvider)));
