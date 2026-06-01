import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:otp_migrator/state/app_state.dart';
import 'package:otp_migrator/state/parse_group.dart';
import 'package:otp_migrator/ui/pages/export_dialog.dart';
import 'package:otp_migrator/ui/widgets/account_card.dart';
import '../theme/app_theme.dart';

/// Results panel — shows parsed OTP accounts grouped by source, or merged &
/// deduped when the merge toggle is on. Provides toolbar controls: merge
/// switch, clear, export.
///
/// Empty state: centered hint when no groups have been imported yet.
class ResultsPanel extends ConsumerWidget {
  const ResultsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(parseGroupsProvider);
    final mergeOn = ref.watch(mergeEnabledProvider);

    if (groups.isEmpty) {
      return _EmptyHint();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --------------------------------------------------------------------
        // Toolbar
        // --------------------------------------------------------------------
        _Toolbar(mergeOn: mergeOn),
        const Divider(),

        // --------------------------------------------------------------------
        // Account list
        // --------------------------------------------------------------------
        Expanded(
          child: mergeOn
              ? _MergedList()
              : _GroupedList(groups: groups),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty hint
// ---------------------------------------------------------------------------

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Text(
          '从左侧导入二维码后，这里显示解析结果',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.mergeOn});

  final bool mergeOn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Merge switch
          Switch(
            value: mergeOn,
            onChanged: (_) => ref.read(mergeEnabledProvider.notifier).toggle(),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => ref.read(mergeEnabledProvider.notifier).toggle(),
            child: Text(
              '合并导出（汇总去重）',
              style: theme.textTheme.bodyMedium,
            ),
          ),

          const Spacer(),

          // Clear button
          TextButton.icon(
            onPressed: () => ref.read(parseGroupsProvider.notifier).clear(),
            icon: const Icon(Icons.clear_all),
            label: const Text('清空'),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Export button
          FilledButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const ExportDialog(),
            ),
            icon: const Icon(Icons.download),
            label: const Text('导出'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Merged list (merge ON)
// ---------------------------------------------------------------------------

class _MergedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(mergedAccountsProvider);
    if (accounts.isEmpty) {
      return Center(
        child: Text(
          '没有可显示的账户',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: accounts.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => AccountCard(account: accounts[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped list (merge OFF)
// ---------------------------------------------------------------------------

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.groups});

  final List<ParseGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: groups.length,
      itemBuilder: (ctx, gi) => _GroupSection(group: groups[gi]),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.group});

  final ParseGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = theme.extension<AppSemanticColors>()!;
    final cs = theme.colorScheme;

    // Header text: label, or label — error if failed
    final headerText = group.ok
        ? group.sourceLabel
        : '${group.sourceLabel} — ${group.error}';

    final headerColor = group.ok ? cs.onSurfaceVariant : semantics.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.xs,
              top: AppSpacing.xxs,
            ),
            child: Text(
              headerText.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: headerColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),

          // Account cards (or empty hint for failed groups)
          if (group.accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                group.ok ? '（无账户）' : '解析失败，无账户数据',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: group.ok ? cs.onSurfaceVariant : semantics.danger,
                ),
              ),
            )
          else
            ...group.accounts.map(
              (acc) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AccountCard(account: acc),
              ),
            ),
        ],
      ),
    );
  }
}
