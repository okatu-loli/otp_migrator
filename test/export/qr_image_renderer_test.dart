import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/export/qr_image_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders non-empty PNG bytes with PNG signature', () async {
    final bytes = await renderQrPng('otpauth://totp/x?secret=JBSWY3DP', size: 256);
    expect(bytes.length, greaterThan(100));
    // PNG magic number: 89 50 4E 47 0D 0A 1A 0A
    expect(bytes.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  });
}
