// OTP Migrator logo generator.
// Pure-Dart (package:image) so it runs with `dart run tool/gen_logo.dart`
// without Flutter. Draws the brand mark and writes master PNGs.
//
// Concept ("Terminal Ledger"): a QR finder pattern (square-in-square — instantly
// reads as "authenticator / QR") on deep slate, with three diminishing modules
// lifting off toward the upper-right to signal migration/export. One disciplined
// teal-green accent, flat, geometric — no gradients, no glow.

import 'dart:io';
import 'package:image/image.dart';

// ---- Brand palette (from the UI design system) ----
final slate = ColorRgb8(0x11, 0x18, 0x1A); // app icon background
final teal = ColorRgb8(0x3D, 0xBF, 0xA8); // dark-mode accent (pops on slate)
// Trailing modules: teal pre-blended over slate at decreasing opacity
// (pre-blended to opaque so output is independent of fillRect blend behavior).
final trail1 = ColorRgb8(57, 174, 154); // ~0.90
final trail2 = ColorRgb8(41, 116, 104); // ~0.55
final trail3 = ColorRgb8(31, 77, 71); //  ~0.32

/// Draw the mark onto a square canvas of [n] px, transparent background unless
/// [withBackground] is set (then filled slate, full-bleed).
Image drawMark(int n, {required bool withBackground}) {
  final img = Image(width: n, height: n, numChannels: 4);
  // start fully transparent
  fill(img, color: ColorRgba8(0, 0, 0, 0));
  if (withBackground) {
    fill(img, color: slate);
  }

  double u(double frac) => frac * n; // fractional → px helper

  // --- QR finder pattern (square-in-square), optically centered ---
  // Outer rounded square (teal).
  fillRect(img,
      x1: u(0.18).round(), y1: u(0.25).round(),
      x2: u(0.64).round(), y2: u(0.71).round(),
      color: teal, radius: u(0.085).round());
  // Knock out the middle ring (back to background).
  fillRect(img,
      x1: u(0.265).round(), y1: u(0.335).round(),
      x2: u(0.555).round(), y2: u(0.625).round(),
      color: withBackground ? slate : ColorRgba8(0, 0, 0, 0),
      radius: u(0.05).round());
  // Solid center.
  fillRect(img,
      x1: u(0.345).round(), y1: u(0.415).round(),
      x2: u(0.475).round(), y2: u(0.545).round(),
      color: teal, radius: u(0.03).round());

  // --- Migration: three diminishing modules lifting toward upper-right ---
  _module(img, u(0.605), u(0.255), u(0.135), trail1);
  _module(img, u(0.715), u(0.15), u(0.095), trail2);
  _module(img, u(0.80), u(0.075), u(0.06), trail3);

  return img;
}

void _module(Image img, double x, double y, double size, Color c) {
  fillRect(img,
      x1: x.round(), y1: y.round(),
      x2: (x + size).round(), y2: (y + size).round(),
      color: c, radius: (size * 0.22).round());
}

/// High-quality downscale.
Image resized(Image src, int n) =>
    copyResize(src, width: n, height: n, interpolation: Interpolation.cubic);

void main() {
  Directory('assets/logo').createSync(recursive: true);

  const masterN = 1024;
  // Render at 4x then downscale for crisp anti-aliased edges.
  const superN = masterN * 2;

  final bgSuper = drawMark(superN, withBackground: true);
  final fgSuper = drawMark(superN, withBackground: false);

  // Full-bleed master (slate background) — feeds launcher-icon tools.
  final master = resized(bgSuper, masterN);
  File('assets/logo/icon_master.png').writeAsBytesSync(encodePng(master));

  // Transparent-background foreground (mark only) — adaptive / overlay use.
  final foreground = resized(fgSuper, masterN);
  File('assets/logo/icon_foreground.png').writeAsBytesSync(encodePng(foreground));

  // A few convenience sizes for README / web favicon.
  for (final s in [512, 256, 128, 64, 32]) {
    File('assets/logo/icon_$s.png').writeAsBytesSync(encodePng(resized(bgSuper, s)));
  }

  stdout.writeln('Wrote assets/logo/icon_master.png (+ foreground & sizes).');
}
