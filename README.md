<p align="center">
  <img src="assets/logo/logo.svg" width="120" alt="OTP Migrator logo">
</p>

<p align="center">
  <b>English</b> · <a href="README.zh-CN.md">简体中文</a>
</p>

# OTP Migrator

**A cross-platform Flutter GUI for decoding Google Authenticator export QR codes.**

> 这是一个跨平台 Flutter 应用，用于解码 Google Authenticator 导出的迁移二维码，并将 OTP 账户导出为多种格式。

<p align="center">
  <a href="https://github.com/okatu-loli/otp_migrator/actions/workflows/ci.yml"><img src="https://github.com/okatu-loli/otp_migrator/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://okatu-loli.github.io/otp_migrator/"><img src="https://img.shields.io/badge/Live%20demo-Web-0F7B6C" alt="Live demo"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT"></a>
</p>

**🌐 Live web demo: https://okatu-loli.github.io/otp_migrator/** (decoding runs entirely in your browser — but for real secrets, prefer a desktop build; see [Security Notes](#security-notes)).

Inspired by and mirroring the functionality of [decodeGoogleOTP](https://github.com/Kuingsmile/decodeGoogleOTP) (MIT), a Go CLI tool for the same purpose. This GUI brings full offline decoding and export to macOS, Windows, Linux, iOS, Android, and the web — no app-store dependency on Google Authenticator required.

---

## Features

- **Multiple input methods**
  - Pick one or more QR image files (PNG/JPG/etc.) via a file picker; decoded entirely in Dart using `image` + `zxing2` — no native binary required.
  - Live camera scanning on iOS, Android, macOS, and Web via `mobile_scanner`.
  - Paste an `otpauth-migration://` URL directly into the text field.

- **Protobuf parsing** — hand-rolled protobuf wire-format reader decodes the migration payload into structured `OtpAccount` objects (secret, name, issuer, algorithm, digits, type, counter).

- **Multi-QR workflow** — import multiple QR codes in one session; results are grouped by source. An optional **Merge** toggle flattens all groups and deduplicates accounts by `secret + name + issuer`.

- **Export formats**
  - JSON — one object per account with all fields.
  - CSV — spreadsheet-friendly with header row; fields containing commas are quoted.
  - Plain-text `otpauth://` URL list — one URI per line.
  - URL format — same URI format, useful for direct import into other authenticators.
  - Per-account QR PNG images — saved to a user-chosen directory on desktop platforms; packaged as a ZIP on web and mobile.
  - In-app QR preview dialog — scan the regenerated QR with any authenticator app, equivalent to the CLI's `--print-qr`.

- **Design system** — "Terminal Ledger" theme (`lib/ui/theme/app_theme.dart`) with light and dark variants.

- **Fully offline** — no network calls, no telemetry, no analytics. Secrets stay in memory and are only written out on explicit user action.

- **Conditional-import file writer** — `dart:io` never leaks into the web build; the export writer uses platform stubs.

---

## CLI Feature-Parity Table

| CLI flag | Description | GUI equivalent |
|----------|-------------|----------------|
| `-i <file>` | Input QR image file | File picker (supports multiple files) |
| `-j` | Export as JSON | Export dialog → JSON format |
| `-c` | Export as CSV | Export dialog → CSV format |
| `-q` | Print QR codes to terminal | In-app QR preview dialog (per account) |
| `-t` | Export as plain-text `otpauth://` list | Export dialog → Text format |
| `-u` | Export as URL list | Export dialog → URL format |
| `-p` | Paste / stdin migration URL | Paste URL text field in Import panel |

> The GUI additionally supports live camera scanning (no CLI equivalent) and bulk QR PNG export to a directory or ZIP.

---

## Supported Platforms

| Platform | File import | Camera scan | Export to file | Export ZIP |
|----------|-------------|-------------|----------------|------------|
| macOS    | Yes         | Yes         | Yes (directory)| No         |
| Windows  | Yes         | No          | Yes (directory)| No         |
| Linux    | Yes         | No          | Yes (directory)| No         |
| iOS      | Yes         | Yes         | No             | Yes        |
| Android  | Yes         | Yes         | No             | Yes        |
| Web      | Yes         | Yes         | No             | Yes        |

> Camera scanning requires `mobile_scanner` and is available on iOS, Android, macOS, and Web. Windows and Linux rely on file import and URL paste.

---

## Build & Run

### Prerequisites

- **Flutter 3.41.6** (stable channel, Dart 3.11.4) — the version used by this project.
- For iOS: Xcode and CocoaPods.
- For Android: Android SDK and NDK.

### Install dependencies

```sh
flutter pub get
```

### Run in development

```sh
# macOS desktop
flutter run -d macos

# Web (Chrome)
flutter run -d chrome

# iOS simulator
flutter run -d ios

# Android emulator
flutter run -d android

# Windows desktop
flutter run -d windows

# Linux desktop
flutter run -d linux
```

### Build release

```sh
# macOS app bundle
flutter build macos

# Web (outputs to build/web/)
flutter build web

# iOS IPA (requires Apple developer account)
flutter build ios

# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# Windows executable
flutter build windows

# Linux executable
flutter build linux
```

---

## Security Notes

- **Fully offline.** The app makes zero network requests. No data leaves the device.
- **In-memory secrets.** OTP secret bytes are held in Dart memory only; they are never written to disk unless the user explicitly triggers an export action.
- **Explicit export.** Secrets are written to disk or clipboard only when the user presses an export button, picks a save location, or taps "Copy."
- **Web environment warning.** The app displays a visible banner when running in a browser, noting that web storage and clipboard interactions carry inherent risks (other browser extensions, shared devices). For maximum security, prefer the native desktop build.
- **No logging.** No crash reporters, analytics SDKs, or remote logging are included.

---

## Project Structure

```
lib/
  app.dart                  # App root widget
  main.dart                 # Entry point
  core/                     # Domain models and pure-Dart parsing
    otp_account.dart        # OtpAccount, enums (algorithm/digits/type)
    protobuf_reader.dart    # Hand-rolled protobuf wire-format reader
    migration_decoder.dart  # otpauth-migration:// URL decoder
    otpauth_uri.dart        # otpauth:// URI builder
    secret_encoding.dart    # Base32 encoding helpers
    exporters/              # JSON, CSV, text, URL exporters
  scan/                     # QR input sources
    image_qr_decoder.dart   # Static image QR decode (image + zxing2)
    camera_scanner.dart     # Live camera scan wrapper (mobile_scanner)
    qr_source.dart          # Source metadata
  export/                   # File/ZIP output
    export_writer.dart      # Conditional-import entry point
    export_writer_io.dart   # dart:io implementation (desktop)
    export_writer_web.dart  # Web ZIP implementation
    export_writer_stub.dart # Stub for unsupported platforms
    qr_image_renderer.dart  # Render otpauth:// URI to PNG bytes
  state/                    # Riverpod state
    app_state.dart          # AppState notifier, merge toggle
    parse_group.dart        # ParseGroup (per-source result container)
  ui/                       # Flutter widgets
    theme/
      app_theme.dart        # "Terminal Ledger" design system (light + dark)
    pages/
      home_page.dart        # Responsive two-panel layout
      import_panel.dart     # File picker, paste field, camera button
      results_panel.dart    # Grouped account list, merge toggle
      export_dialog.dart    # Format selector + export action
    widgets/
      account_card.dart     # Single account display card
      qr_preview_dialog.dart# In-app QR code viewer
```

---

## License

The original [decodeGoogleOTP](https://github.com/Kuingsmile/decodeGoogleOTP) project is released under the **MIT License**.

This Flutter project is likewise released under the **MIT License** — see the [`LICENSE`](LICENSE) file. Copyright (c) 2026 okatu-loli.
