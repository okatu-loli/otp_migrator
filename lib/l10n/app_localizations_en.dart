// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OTP Migrator';

  @override
  String get tabImport => 'Import';

  @override
  String get tabResults => 'Results';

  @override
  String get webRiskWarning =>
      '⚠️ Handling OTP credentials in a browser carries a risk of leakage. For sensitive scenarios, prefer the desktop app.';

  @override
  String get pickQrImages => 'Pick QR code images (multi-select)';

  @override
  String get scanWithCamera => 'Scan with camera';

  @override
  String get pasteMigrationLinkLabel => 'Paste otpauth-migration link';

  @override
  String get parseLink => 'Parse link';

  @override
  String get qrNotRecognized => 'QR code not recognized';

  @override
  String get sourcePaste => 'Paste';

  @override
  String get sourceCamera => 'Camera';

  @override
  String get emptyResultsHint =>
      'Import QR codes on the left to see the parsed results here';

  @override
  String get mergeExportDedup => 'Merge export (deduplicated)';

  @override
  String get clear => 'Clear';

  @override
  String get export => 'Export';

  @override
  String get noAccountsToShow => 'No accounts to show';

  @override
  String get exportFormatJson => 'JSON file';

  @override
  String get exportFormatCsv => 'CSV file';

  @override
  String get exportFormatText => 'Text URL list';

  @override
  String get exportFormatUrl => 'URL format';

  @override
  String get exportFormatQrImages => 'QR code images (one per account)';

  @override
  String get noAccountsToExport =>
      'No accounts to export. Please import OTP data first.';

  @override
  String get exportCancelled => 'Cancelled';

  @override
  String exportedTo(String dest) {
    return 'Exported to: $dest';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String digitsCount(int count) {
    return '$count digits';
  }

  @override
  String get showQrCode => 'Show QR code';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get close => 'Close';

  @override
  String get groupNoAccounts => '(no accounts)';

  @override
  String get groupParseFailed => 'Parse failed, no account data';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageSystem => 'System / 跟随系统';

  @override
  String get about => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutSourceCode => 'Source code';
}
