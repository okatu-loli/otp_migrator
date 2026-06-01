import '../otp_account.dart';
import 'text_exporter.dart';

// 原 CLI -u 与 -t 同为 otpauth:// URL 列表，保留独立入口以对齐命令语义。
String exportUrl(List<OtpAccount> accounts) => exportText(accounts);
