import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Migrator'**
  String get appTitle;

  /// No description provided for @tabImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get tabImport;

  /// No description provided for @tabResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get tabResults;

  /// No description provided for @webRiskWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Handling OTP credentials in a browser carries a risk of leakage. For sensitive scenarios, prefer the desktop app.'**
  String get webRiskWarning;

  /// No description provided for @pickQrImages.
  ///
  /// In en, this message translates to:
  /// **'Pick QR code images (multi-select)'**
  String get pickQrImages;

  /// No description provided for @scanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanWithCamera;

  /// No description provided for @pasteMigrationLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste otpauth-migration link'**
  String get pasteMigrationLinkLabel;

  /// No description provided for @parseLink.
  ///
  /// In en, this message translates to:
  /// **'Parse link'**
  String get parseLink;

  /// No description provided for @qrNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'QR code not recognized'**
  String get qrNotRecognized;

  /// No description provided for @sourcePaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get sourcePaste;

  /// No description provided for @sourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get sourceCamera;

  /// No description provided for @emptyResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Import QR codes on the left to see the parsed results here'**
  String get emptyResultsHint;

  /// No description provided for @mergeExportDedup.
  ///
  /// In en, this message translates to:
  /// **'Merge export (deduplicated)'**
  String get mergeExportDedup;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @noAccountsToShow.
  ///
  /// In en, this message translates to:
  /// **'No accounts to show'**
  String get noAccountsToShow;

  /// No description provided for @exportFormatJson.
  ///
  /// In en, this message translates to:
  /// **'JSON file'**
  String get exportFormatJson;

  /// No description provided for @exportFormatCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV file'**
  String get exportFormatCsv;

  /// No description provided for @exportFormatText.
  ///
  /// In en, this message translates to:
  /// **'Text URL list'**
  String get exportFormatText;

  /// No description provided for @exportFormatUrl.
  ///
  /// In en, this message translates to:
  /// **'URL format'**
  String get exportFormatUrl;

  /// No description provided for @exportFormatQrImages.
  ///
  /// In en, this message translates to:
  /// **'QR code images (one per account)'**
  String get exportFormatQrImages;

  /// No description provided for @noAccountsToExport.
  ///
  /// In en, this message translates to:
  /// **'No accounts to export. Please import OTP data first.'**
  String get noAccountsToExport;

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get exportCancelled;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to: {dest}'**
  String exportedTo(String dest);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @digitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} digits'**
  String digitsCount(int count);

  /// No description provided for @showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get showQrCode;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @groupNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'(no accounts)'**
  String get groupNoAccounts;

  /// No description provided for @groupParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Parse failed, no account data'**
  String get groupParseFailed;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenuTooltip;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System / 跟随系统'**
  String get languageSystem;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
