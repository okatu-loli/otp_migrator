# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/), and the
project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-06-01

First public release. A cross-platform Flutter GUI that decodes Google
Authenticator export QR codes (`otpauth-migration://`) and exports the
contained OTP accounts.

### Added

- **Inputs**
  - Pick one or more QR image files; decoded entirely in Dart (`image` + `zxing2`), no native binary.
  - Live camera scanning on iOS, Android, macOS, and Web (`mobile_scanner`).
  - Paste an `otpauth-migration://` URL directly.
- **Decoding** — hand-rolled protobuf wire-format reader extracts each account's
  secret, name, issuer, algorithm, digit count, type (TOTP/HOTP), and counter.
- **Multi-QR workflow** — parse several QR codes in one session, grouped by source,
  with an optional **Merge** toggle that flattens and deduplicates by secret + name + issuer.
- **Exports** — JSON, CSV (with formula-injection neutralization), plain-text
  `otpauth://` list, URL format, per-account QR PNG images (directory on desktop,
  ZIP on web/mobile), and an in-app QR preview dialog.
- **Design** — "Terminal Ledger" design system with light and dark themes; brand
  logo and generated launcher icons for all platforms.
- **Platforms** — macOS, Windows, Linux, iOS, Android, and Web.

### Security

- Fully offline: no network requests, telemetry, or analytics.
- Secrets are held in memory and written only on explicit user action.
- Web build shows an environment-risk warning; `dart:io` never leaks into the web bundle.

[1.0.0]: https://github.com/okatu-loli/otp_migrator/releases/tag/v1.0.0
