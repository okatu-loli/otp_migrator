import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:otp_migrator/core/app_info.dart';
import 'package:otp_migrator/l10n/app_localizations.dart';
import 'package:otp_migrator/state/locale_provider.dart';
import '../theme/app_theme.dart';
import 'import_panel.dart';
import 'results_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  List<Widget> _appBarActions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider);
    return [
      _LanguageMenu(current: current),
      IconButton(
        icon: const Icon(Icons.info_outline),
        tooltip: l10n.about,
        onPressed: () => _showAbout(context),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.expanded) {
          // Wide layout: two panels side by side.
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.appTitle),
              actions: _appBarActions(context, ref),
            ),
            body: const Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: ImportPanel()),
                VerticalDivider(width: 1),
                Expanded(flex: 3, child: ResultsPanel()),
              ],
            ),
          );
        }

        // Narrow layout: tabbed view.
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.appTitle),
              actions: _appBarActions(context, ref),
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.tabImport),
                  Tab(text: l10n.tabResults),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                ImportPanel(),
                ResultsPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Language selection popup menu. `null` value => follow system locale.
class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu({required this.current});

  final Locale? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    Widget item(String label, bool selected) => Row(
          children: [
            Icon(
              selected ? Icons.check : null,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label),
          ],
        );

    final code = current?.languageCode;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate),
      tooltip: l10n.languageMenuTooltip,
      onSelected: (value) {
        final notifier = ref.read(localeProvider.notifier);
        switch (value) {
          case 'en':
            notifier.setLocale(const Locale('en'));
          case 'zh':
            notifier.setLocale(const Locale('zh'));
          default:
            notifier.setLocale(null);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: item(l10n.languageEnglish, code == 'en'),
        ),
        PopupMenuItem<String>(
          value: 'zh',
          child: item(l10n.languageChinese, code == 'zh'),
        ),
        PopupMenuItem<String>(
          value: 'system',
          child: item(l10n.languageSystem, current == null),
        ),
      ],
    );
  }
}

Future<void> _showAbout(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  String versionText = '';
  try {
    final info = await PackageInfo.fromPlatform();
    versionText = 'v${info.version} (${info.buildNumber})';
  } catch (_) {
    // Leave version blank if it cannot be read (e.g. some test envs).
  }
  if (!context.mounted) return;

  showAboutDialog(
    context: context,
    applicationName: l10n.appTitle,
    applicationVersion: versionText,
    children: [
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          Text('${l10n.aboutSourceCode}: '),
          Flexible(
            child: InkWell(
              onTap: () => launchUrl(
                Uri.parse(kRepoUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                kRepoUrl,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
