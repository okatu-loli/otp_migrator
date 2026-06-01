import 'package:flutter/material.dart';
import 'ui/theme/app_theme.dart';
import 'ui/pages/home_page.dart';

class OtpMigratorApp extends StatelessWidget {
  const OtpMigratorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Migrator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
