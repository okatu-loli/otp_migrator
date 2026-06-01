import '../otp_account.dart';
import '../otpauth_uri.dart';

String exportText(List<OtpAccount> accounts) =>
    accounts.map(buildOtpauthUri).join('\n');
