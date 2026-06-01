// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'OTP Migrator';

  @override
  String get tabImport => '导入';

  @override
  String get tabResults => '结果';

  @override
  String get webRiskWarning => '⚠️ 浏览器环境处理 OTP 凭据存在泄露风险，敏感场景建议使用桌面端。';

  @override
  String get pickQrImages => '选择二维码图片（可多选）';

  @override
  String get scanWithCamera => '摄像头扫码';

  @override
  String get pasteMigrationLinkLabel => '粘贴 otpauth-migration 链接';

  @override
  String get parseLink => '解析链接';

  @override
  String get qrNotRecognized => '未识别二维码';

  @override
  String get sourcePaste => '粘贴';

  @override
  String get sourceCamera => '摄像头';

  @override
  String get emptyResultsHint => '从左侧导入二维码后，这里显示解析结果';

  @override
  String get mergeExportDedup => '合并导出（汇总去重）';

  @override
  String get clear => '清空';

  @override
  String get export => '导出';

  @override
  String get noAccountsToShow => '没有可显示的账户';

  @override
  String get exportFormatJson => 'JSON 文件';

  @override
  String get exportFormatCsv => 'CSV 文件';

  @override
  String get exportFormatText => '文本 URL 列表';

  @override
  String get exportFormatUrl => 'URL 格式';

  @override
  String get exportFormatQrImages => '二维码图片（每账户一张）';

  @override
  String get noAccountsToExport => '没有可导出的账户，请先导入 OTP 数据。';

  @override
  String get exportCancelled => '已取消';

  @override
  String exportedTo(String dest) {
    return '已导出到：$dest';
  }

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get cancel => '取消';

  @override
  String digitsCount(int count) {
    return '$count 位';
  }

  @override
  String get showQrCode => '显示二维码';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get close => '关闭';

  @override
  String get groupNoAccounts => '（无账户）';

  @override
  String get groupParseFailed => '解析失败，无账户数据';

  @override
  String get languageMenuTooltip => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageSystem => 'System / 跟随系统';

  @override
  String get about => '关于';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutSourceCode => '开源地址';
}
