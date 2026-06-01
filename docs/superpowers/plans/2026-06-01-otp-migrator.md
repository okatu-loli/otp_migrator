# OTP Migrator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 跨平台 Flutter GUI，解析 Google Authenticator 导出的 `otpauth-migration` 二维码（支持多张同时解析、可选合并、去重），并导出为 JSON / CSV / 二维码图片 / 文本 URL 列表 / URL 格式，覆盖 decodeGoogleOTP 全部能力。

**Architecture:** 纯 Dart 核心（零 Flutter 依赖、可单测）：手写 protobuf wire 解析器 → `OtpAccount` 模型（secret 存原始字节）→ 导出器纯函数 + `otpauth://` URL 构造器。输入适配层提供「图片字节 / 摄像头 / 粘贴」三种来源；输出层做 QR 渲染与跨平台落盘。UI 用 Riverpod 管理「按来源分组的解析结果 + 合并开关」，界面在编码前先经 frontend-design 产出设计系统。

**Tech Stack:** Flutter (stable, Dart 3) · flutter_riverpod 3.3.x · file_picker 11.0.x · mobile_scanner 7.2.x（摄像头，iOS/Android/macOS/Web）· zxing2 0.2.x + image 4.9.x（全平台静态图片 QR 解码）· qr_flutter 4.1.x（QR 生成）· archive（Web 多文件打包）· base32 2.2.x。protobuf 手写解析、无 `protobuf`/`dio` 依赖。

**依赖安装策略:** 全部用 `flutter pub add <pkg>` 让 pub 解析当前最新兼容版本（规避已知 CVE 的旧版本）。上面版本号为已核对的预期下限。

---

## File Structure

```
lib/
  core/                              纯 Dart，零 Flutter 依赖
    otp_account.dart                 OtpAccount 模型 + Algorithm/DigitCount/OtpType 枚举
    protobuf_reader.dart             极简 protobuf wire-format 读取器（varint / length-delimited）
    migration_decoder.dart           otpauth-migration URL/字节 → List<OtpAccount> + 错误类型
    otpauth_uri.dart                 OtpAccount → 标准 otpauth:// URL（含 base32 secret）
    exporters/
      json_exporter.dart             List<OtpAccount> → JSON 字符串
      csv_exporter.dart              → CSV 字符串
      text_exporter.dart             → 每行一个 otpauth:// URL
      url_exporter.dart              → URL 格式（同 text，保留以对齐原 CLI -u）
  scan/
    qr_source.dart                   抽象：QrDecodeResult { url, sourceLabel, error }
    image_qr_decoder.dart            图片字节 → QR 文本（image 解像素 + zxing2 解码）
    camera_scanner.dart              mobile_scanner 封装（支持平台）
  export/
    qr_image_renderer.dart           otpauth:// URL → PNG 字节（qr_flutter QrPainter.toImageData）
    export_writer.dart               单文件保存 / 多 PNG 落盘（桌面&移动）/ Web zip 下载
  state/
    parse_group.dart                 ParseGroup { sourceLabel, accounts, error }
    app_state.dart                   Riverpod providers：groups、merge 开关、派生 mergedAccounts(去重)
  ui/
    theme/app_theme.dart             frontend-design 产出的设计令牌（颜色/排版/间距/组件）
    pages/home_page.dart             主页（响应式：宽屏多栏 / 窄屏单栏）
    pages/import_panel.dart          导入区（拖拽/选图/扫码/粘贴 + Web 安全提示）
    pages/results_panel.dart         结果区（按来源分组、合并开关、账户卡片）
    pages/export_dialog.dart         导出对话框（选格式 + 目标）
    widgets/account_card.dart        单账户展示（issuer/name/参数 + 二维码预览按钮）
    widgets/qr_preview_dialog.dart   对应原 -p：放大展示某账户 otpauth:// 二维码
    widgets/log_panel.dart           debug/silent 对应的可开关日志面板
  app.dart
  main.dart
test/
  core/
    protobuf_reader_test.dart
    migration_decoder_test.dart
    otpauth_uri_test.dart
    exporters_test.dart
  scan/
    image_qr_decoder_test.dart
```

**测试向量（全计划共用，手工构造、确定性）**
一个 `MigrationPayload`，含 1 个 `OtpParameters`：secret 原始字节 = `Hello` = `[0x48,0x65,0x6C,0x6C,0x6F]`，name=`acc`，issuer=`iss`，algorithm=SHA1(1)，digits=SIX(1)，type=TOTP(2)。顶层 version=2,batch_size=1,batch_index=0,batch_id=0。

确定性 payload 字节（hex）：
```
0A 17 0A 05 48 65 6C 6C 6F 12 03 61 63 63 1A 03 69 73 73 20 01 28 01 30 02 10 02 18 01 20 00 28 00
```
- 外层 `0A 17`：field1(otp_parameters) wiretype2，长度 0x17=23
- 内层 23 字节为 OtpParameters，随后 `10 02`(version=2) `18 01`(batch_size=1) `20 00`(batch_index=0) `28 00`(batch_id=0)

Dart 常量（测试中复用）：
```dart
final kSampleBytes = Uint8List.fromList([
  0x0A,0x17,0x0A,0x05,0x48,0x65,0x6C,0x6C,0x6F,0x12,0x03,0x61,0x63,0x63,
  0x1A,0x03,0x69,0x73,0x73,0x20,0x01,0x28,0x01,0x30,0x02,
  0x10,0x02,0x18,0x01,0x20,0x00,0x28,0x00,
]);
// 对应 migration URL：
//   'otpauth-migration://offline?data=' + Uri.encodeComponent(base64Encode(kSampleBytes))
```

---

## Phase 0 — UI 设计（编码前，用户硬性要求）

### Task 0: 用 frontend-design 产出设计系统

**Files:**
- Create: `docs/superpowers/specs/2026-06-01-otp-migrator-ui-design.md`（设计说明 + 设计令牌）
- Create: `lib/ui/theme/app_theme.dart`（落地为 ThemeData / 设计令牌；本任务先产出，Phase 9 使用）

- [ ] **Step 1: 调用 frontend-design skill**

调用 `frontend-design` skill，输入需求：为一个「安全/凭据迁移工具」设计跨平台桌面+移动响应式界面。要求：
- 明确视觉语言（配色、排版层级、间距尺度、圆角/阴影、强调色），**规避通用 AI 模板感**（不要紫蓝渐变 + 居中卡片的套路）；偏向沉稳、专业、可信赖的工具型审美，兼顾浅色/深色。
- 关键屏幕：① 主页（宽屏左导入/右结果两栏，窄屏单栏 Tab）② 账户卡片（issuer/name/algorithm/digits/type 清晰分级）③ 二维码预览对话框 ④ 导出对话框。
- 产出可直接落入 Flutter 的设计令牌（颜色、字体、间距、组件状态），并写入 `app_theme.dart`（`ColorScheme` + `ThemeData` 浅/深色）。

- [ ] **Step 2: 评审产出**

确认 `app_theme.dart` 提供：浅色与深色 `ThemeData`、一组命名间距常量（如 `AppSpacing`）、强调色与语义色（成功/失败/警告）。无需测试（纯样式）。

- [ ] **Step 3: Commit**
```bash
git add docs/superpowers/specs/2026-06-01-otp-migrator-ui-design.md lib/ui/theme/app_theme.dart
git commit -m "design: add UI design system and theme tokens"
```

---

## Phase 1 — 工程脚手架

### Task 1: 创建 Flutter 工程与依赖

**Files:**
- Create: 整个 Flutter 工程骨架（在 `/Users/yuxiaofan/Documents/code/otp_migrator`）

- [ ] **Step 1: 在已有目录内生成 Flutter 工程**

工程目录已存在且含 `docs/`，用 `.`（当前目录）生成，避免覆盖 docs：
```bash
cd /Users/yuxiaofan/Documents/code/otp_migrator
flutter create --org com.otpmigrator --platforms=macos,windows,linux,ios,android,web --project-name otp_migrator .
```
Expected: 生成 `lib/`、`pubspec.yaml`、各平台目录；`docs/` 保留。

- [ ] **Step 2: 添加依赖**
```bash
flutter pub add flutter_riverpod file_picker mobile_scanner zxing2 image qr_flutter archive base32
```
Expected: `pubspec.yaml` 写入上述包，`flutter pub get` 成功。

- [ ] **Step 3: 初始化 git 并提交**
```bash
git init && git add -A && git commit -m "chore: scaffold Flutter project with cross-platform targets and deps"
```
（若已 init 则跳过 init）

---

## Phase 2 — 核心模型与 protobuf 解析（TDD）

### Task 2: OtpAccount 模型与枚举

**Files:**
- Create: `lib/core/otp_account.dart`
- Test: `test/core/migration_decoder_test.dart`（本任务先建枚举断言）

- [ ] **Step 1: 写失败测试**
```dart
// test/core/otp_account_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';

void main() {
  test('OtpAlgorithm.fromProto maps values', () {
    expect(OtpAlgorithm.fromProto(1), OtpAlgorithm.sha1);
    expect(OtpAlgorithm.fromProto(2), OtpAlgorithm.sha256);
    expect(OtpAlgorithm.fromProto(3), OtpAlgorithm.sha512);
    expect(OtpAlgorithm.fromProto(4), OtpAlgorithm.md5);
    expect(OtpAlgorithm.fromProto(0), OtpAlgorithm.sha1); // 默认 SHA1
  });
  test('OtpDigits/OtpType map values', () {
    expect(OtpDigits.fromProto(2).count, 8);
    expect(OtpDigits.fromProto(1).count, 6);
    expect(OtpDigits.fromProto(0).count, 6); // 默认 6
    expect(OtpType.fromProto(2), OtpType.totp);
    expect(OtpType.fromProto(1), OtpType.hotp);
  });
  test('OtpAccount holds raw secret bytes', () {
    final a = OtpAccount(
      secret: Uint8List.fromList([1, 2, 3]),
      name: 'n', issuer: 'i',
      algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
      type: OtpType.totp, counter: 0,
    );
    expect(a.secret, [1, 2, 3]);
    expect(a.name, 'n');
  });
}
```

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/core/otp_account_test.dart`
Expected: FAIL（`otp_account.dart` 不存在 / 符号未定义）

- [ ] **Step 3: 实现**
```dart
// lib/core/otp_account.dart
import 'dart:typed_data';

enum OtpAlgorithm {
  sha1('SHA1'), sha256('SHA256'), sha512('SHA512'), md5('MD5');
  const OtpAlgorithm(this.label);
  final String label;
  static OtpAlgorithm fromProto(int v) => switch (v) {
        2 => OtpAlgorithm.sha256,
        3 => OtpAlgorithm.sha512,
        4 => OtpAlgorithm.md5,
        _ => OtpAlgorithm.sha1, // 0/1 → SHA1
      };
}

enum OtpDigits {
  six(6), eight(8);
  const OtpDigits(this.count);
  final int count;
  static OtpDigits fromProto(int v) => v == 2 ? OtpDigits.eight : OtpDigits.six;
}

enum OtpType {
  totp('totp'), hotp('hotp');
  const OtpType(this.uriLabel);
  final String uriLabel;
  static OtpType fromProto(int v) => v == 1 ? OtpType.hotp : OtpType.totp;
}

class OtpAccount {
  const OtpAccount({
    required this.secret,
    required this.name,
    required this.issuer,
    required this.algorithm,
    required this.digits,
    required this.type,
    required this.counter,
  });

  final Uint8List secret; // 原始字节；base32 在 otpauth_uri 中生成
  final String name;
  final String issuer;
  final OtpAlgorithm algorithm;
  final OtpDigits digits;
  final OtpType type;
  final int counter; // 仅 HOTP 有意义
}
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/core/otp_account_test.dart` → Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add lib/core/otp_account.dart test/core/otp_account_test.dart
git commit -m "feat(core): add OtpAccount model and OTP enums"
```

### Task 3: protobuf wire-format 读取器

**Files:**
- Create: `lib/core/protobuf_reader.dart`
- Test: `test/core/protobuf_reader_test.dart`

- [ ] **Step 1: 写失败测试**
```dart
// test/core/protobuf_reader_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/protobuf_reader.dart';

void main() {
  test('reads varint key and value', () {
    // field5 varint value 0  -> key 0x28, value 0x00
    final r = ProtobufReader(Uint8List.fromList([0x28, 0x00]));
    final tag = r.readTag();
    expect(tag.fieldNumber, 5);
    expect(tag.wireType, WireType.varint);
    expect(r.readVarint(), 0);
    expect(r.isAtEnd, true);
  });

  test('reads length-delimited bytes', () {
    // field1 wt2 len3 [0x61,0x62,0x63]
    final r = ProtobufReader(Uint8List.fromList([0x0A, 0x03, 0x61, 0x62, 0x63]));
    final tag = r.readTag();
    expect(tag.fieldNumber, 1);
    expect(tag.wireType, WireType.lengthDelimited);
    expect(r.readLengthDelimited(), [0x61, 0x62, 0x63]);
  });

  test('multi-byte varint', () {
    // 300 = 0xAC 0x02 (varint)
    final r = ProtobufReader(Uint8List.fromList([0xAC, 0x02]));
    expect(r.readVarint(), 300);
  });
}
```

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/core/protobuf_reader_test.dart` → Expected: FAIL（类未定义）

- [ ] **Step 3: 实现**
```dart
// lib/core/protobuf_reader.dart
import 'dart:typed_data';

enum WireType { varint, fixed64, lengthDelimited, fixed32, unknown }

class ProtoTag {
  const ProtoTag(this.fieldNumber, this.wireType);
  final int fieldNumber;
  final WireType wireType;
}

/// 极简 protobuf wire-format 读取器，仅覆盖 MigrationPayload 所需类型。
class ProtobufReader {
  ProtobufReader(this._bytes);
  final Uint8List _bytes;
  int _pos = 0;

  bool get isAtEnd => _pos >= _bytes.length;

  int readVarint() {
    int result = 0;
    int shift = 0;
    while (true) {
      if (_pos >= _bytes.length) {
        throw const FormatException('protobuf: unexpected end while reading varint');
      }
      final b = _bytes[_pos++];
      result |= (b & 0x7F) << shift;
      if ((b & 0x80) == 0) break;
      shift += 7;
      if (shift > 63) throw const FormatException('protobuf: varint too long');
    }
    return result;
  }

  ProtoTag readTag() {
    final key = readVarint();
    final fieldNumber = key >> 3;
    final wire = switch (key & 0x7) {
      0 => WireType.varint,
      1 => WireType.fixed64,
      2 => WireType.lengthDelimited,
      5 => WireType.fixed32,
      _ => WireType.unknown,
    };
    return ProtoTag(fieldNumber, wire);
  }

  Uint8List readLengthDelimited() {
    final len = readVarint();
    if (_pos + len > _bytes.length) {
      throw const FormatException('protobuf: length-delimited overruns buffer');
    }
    final out = Uint8List.sublistView(_bytes, _pos, _pos + len);
    _pos += len;
    return Uint8List.fromList(out);
  }

  /// 跳过未知字段，保证向前兼容。
  void skip(WireType wireType) {
    switch (wireType) {
      case WireType.varint:
        readVarint();
      case WireType.fixed64:
        _pos += 8;
      case WireType.lengthDelimited:
        final len = readVarint();
        _pos += len;
      case WireType.fixed32:
        _pos += 4;
      case WireType.unknown:
        throw const FormatException('protobuf: unknown wire type');
    }
    if (_pos > _bytes.length) {
      throw const FormatException('protobuf: skip overruns buffer');
    }
  }
}
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/core/protobuf_reader_test.dart` → Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add lib/core/protobuf_reader.dart test/core/protobuf_reader_test.dart
git commit -m "feat(core): add minimal protobuf wire-format reader"
```

---

## Phase 3 — Migration 解码器（TDD）

### Task 4: migration_decoder

**Files:**
- Create: `lib/core/migration_decoder.dart`
- Test: `test/core/migration_decoder_test.dart`

- [ ] **Step 1: 写失败测试**
```dart
// test/core/migration_decoder_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/migration_decoder.dart';

final kSampleBytes = Uint8List.fromList([
  0x0A,0x17,0x0A,0x05,0x48,0x65,0x6C,0x6C,0x6F,0x12,0x03,0x61,0x63,0x63,
  0x1A,0x03,0x69,0x73,0x73,0x20,0x01,0x28,0x01,0x30,0x02,
  0x10,0x02,0x18,0x01,0x20,0x00,0x28,0x00,
]);

String sampleUrl() =>
    'otpauth-migration://offline?data=${Uri.encodeComponent(base64Encode(kSampleBytes))}';

void main() {
  test('decodes a single account from migration url', () {
    final accounts = MigrationDecoder.decodeUrl(sampleUrl());
    expect(accounts, hasLength(1));
    final a = accounts.single;
    expect(a.secret, [0x48, 0x65, 0x6C, 0x6C, 0x6F]); // "Hello"
    expect(a.name, 'acc');
    expect(a.issuer, 'iss');
    expect(a.algorithm, OtpAlgorithm.sha1);
    expect(a.digits, OtpDigits.six);
    expect(a.type, OtpType.totp);
  });

  test('decodes from raw payload bytes', () {
    final accounts = MigrationDecoder.decodePayloadBytes(kSampleBytes);
    expect(accounts.single.issuer, 'iss');
  });

  test('rejects non-migration url', () {
    expect(() => MigrationDecoder.decodeUrl('otpauth://totp/x?secret=AA'),
        throwsA(isA<MigrationFormatException>()));
  });

  test('rejects corrupt base64', () {
    expect(() => MigrationDecoder.decodeUrl('otpauth-migration://offline?data=%%%'),
        throwsA(isA<MigrationFormatException>()));
  });
}
```

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/core/migration_decoder_test.dart` → Expected: FAIL

- [ ] **Step 3: 实现**
```dart
// lib/core/migration_decoder.dart
import 'dart:convert';
import 'dart:typed_data';
import 'otp_account.dart';
import 'protobuf_reader.dart';

class MigrationFormatException implements Exception {
  const MigrationFormatException(this.message);
  final String message;
  @override
  String toString() => 'MigrationFormatException: $message';
}

class MigrationDecoder {
  /// 解析完整的 otpauth-migration:// URL。
  static List<OtpAccount> decodeUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'otpauth-migration') {
      throw const MigrationFormatException('不是 otpauth-migration 链接');
    }
    final data = uri.queryParameters['data'];
    if (data == null || data.isEmpty) {
      throw const MigrationFormatException('链接缺少 data 参数');
    }
    final Uint8List bytes;
    try {
      // Uri 已解码 query；兼容 url-safe / 标准 base64 与缺失 padding。
      bytes = _decodeBase64(data);
    } on FormatException {
      throw const MigrationFormatException('data 不是合法的 base64');
    }
    return decodePayloadBytes(bytes);
  }

  static Uint8List _decodeBase64(String s) {
    var normalized = s.replaceAll('-', '+').replaceAll('_', '/');
    final pad = normalized.length % 4;
    if (pad > 0) normalized = normalized.padRight(normalized.length + (4 - pad), '=');
    return base64Decode(normalized);
  }

  /// 解析 MigrationPayload protobuf 字节。
  static List<OtpAccount> decodePayloadBytes(Uint8List payload) {
    final reader = ProtobufReader(payload);
    final accounts = <OtpAccount>[];
    try {
      while (!reader.isAtEnd) {
        final tag = reader.readTag();
        if (tag.fieldNumber == 1 && tag.wireType == WireType.lengthDelimited) {
          accounts.add(_parseOtpParameters(reader.readLengthDelimited()));
        } else {
          reader.skip(tag.wireType); // version/batch_* 等顶层字段
        }
      }
    } on FormatException catch (e) {
      throw MigrationFormatException('protobuf 解析失败：${e.message}');
    }
    if (accounts.isEmpty) {
      throw const MigrationFormatException('未找到任何账户');
    }
    return accounts;
  }

  static OtpAccount _parseOtpParameters(Uint8List bytes) {
    final reader = ProtobufReader(bytes);
    Uint8List secret = Uint8List(0);
    String name = '';
    String issuer = '';
    int algorithm = 1, digits = 1, type = 2, counter = 0;
    while (!reader.isAtEnd) {
      final tag = reader.readTag();
      switch (tag.fieldNumber) {
        case 1:
          secret = reader.readLengthDelimited();
        case 2:
          name = utf8.decode(reader.readLengthDelimited());
        case 3:
          issuer = utf8.decode(reader.readLengthDelimited());
        case 4:
          algorithm = reader.readVarint();
        case 5:
          digits = reader.readVarint();
        case 6:
          type = reader.readVarint();
        case 7:
          counter = reader.readVarint();
        default:
          reader.skip(tag.wireType);
      }
    }
    return OtpAccount(
      secret: secret,
      name: name,
      issuer: issuer,
      algorithm: OtpAlgorithm.fromProto(algorithm),
      digits: OtpDigits.fromProto(digits),
      type: OtpType.fromProto(type),
      counter: counter,
    );
  }
}
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/core/migration_decoder_test.dart` → Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add lib/core/migration_decoder.dart test/core/migration_decoder_test.dart
git commit -m "feat(core): decode otpauth-migration payload to OtpAccount list"
```

---

## Phase 4 — otpauth:// URL 构造器（TDD）

### Task 5: otpauth_uri

**Files:**
- Create: `lib/core/otpauth_uri.dart`
- Test: `test/core/otpauth_uri_test.dart`

- [ ] **Step 1: 写失败测试**
```dart
// test/core/otpauth_uri_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/otpauth_uri.dart';

OtpAccount acc({OtpType type = OtpType.totp, int counter = 0}) => OtpAccount(
      secret: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]), // "Hello"
      name: 'alice@example.com', issuer: 'GitHub',
      algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
      type: type, counter: counter,
    );

void main() {
  test('builds totp uri with base32 secret and label', () {
    final uri = Uri.parse(buildOtpauthUri(acc()));
    expect(uri.scheme, 'otpauth');
    expect(uri.host, 'totp');
    // base32 of "Hello" (RFC4648, no padding) = JBSWY3DP
    expect(uri.queryParameters['secret'], 'JBSWY3DP');
    expect(uri.queryParameters['issuer'], 'GitHub');
    expect(uri.queryParameters['algorithm'], 'SHA1');
    expect(uri.queryParameters['digits'], '6');
    // label = issuer:name
    expect(Uri.decodeComponent(uri.path.substring(1)), 'GitHub:alice@example.com');
  });

  test('hotp uri includes counter', () {
    final uri = Uri.parse(buildOtpauthUri(acc(type: OtpType.hotp, counter: 42)));
    expect(uri.host, 'hotp');
    expect(uri.queryParameters['counter'], '42');
  });
}
```
> 说明：`"Hello"` 的 RFC4648 base32（无填充）为 `JBSWY3DP`，此为确定值，测试直接断言。

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/core/otpauth_uri_test.dart` → Expected: FAIL

- [ ] **Step 3: 实现**
```dart
// lib/core/otpauth_uri.dart
import 'package:base32/base32.dart';
import 'otp_account.dart';

/// 按 Key URI Format 生成标准 otpauth:// 链接。
String buildOtpauthUri(OtpAccount a) {
  final secretB32 = base32.encode(a.secret).replaceAll('=', ''); // 无填充
  final label = a.issuer.isNotEmpty ? '${a.issuer}:${a.name}' : a.name;
  final params = <String, String>{
    'secret': secretB32,
    if (a.issuer.isNotEmpty) 'issuer': a.issuer,
    'algorithm': a.algorithm.label,
    'digits': a.digits.count.toString(),
  };
  if (a.type == OtpType.hotp) {
    params['counter'] = a.counter.toString();
  } else {
    params['period'] = '30';
  }
  final query = params.entries
      .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
  return 'otpauth://${a.type.uriLabel}/${Uri.encodeComponent(label)}?$query';
}
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/core/otpauth_uri_test.dart` → Expected: PASS（如 `period` 影响断言，测试只查指定键，不受影响）

- [ ] **Step 5: Commit**
```bash
git add lib/core/otpauth_uri.dart test/core/otpauth_uri_test.dart
git commit -m "feat(core): build standard otpauth:// uri with base32 secret"
```

---

## Phase 5 — 导出器（TDD）

### Task 6: json/csv/text/url 导出器

**Files:**
- Create: `lib/core/exporters/json_exporter.dart`, `csv_exporter.dart`, `text_exporter.dart`, `url_exporter.dart`
- Test: `test/core/exporters_test.dart`

- [ ] **Step 1: 写失败测试**
```dart
// test/core/exporters_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/core/exporters/json_exporter.dart';
import 'package:otp_migrator/core/exporters/csv_exporter.dart';
import 'package:otp_migrator/core/exporters/text_exporter.dart';
import 'package:otp_migrator/core/exporters/url_exporter.dart';

final accounts = [
  OtpAccount(
    secret: Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]),
    name: 'alice', issuer: 'GitHub',
    algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
    type: OtpType.totp, counter: 0,
  ),
];

void main() {
  test('json export contains secret base32 and fields', () {
    final out = jsonDecode(exportJson(accounts)) as List;
    expect(out, hasLength(1));
    expect(out.first['issuer'], 'GitHub');
    expect(out.first['name'], 'alice');
    expect(out.first['secret'], 'JBSWY3DP');
    expect(out.first['type'], 'totp');
    expect(out.first['algorithm'], 'SHA1');
    expect(out.first['digits'], 6);
  });

  test('csv export has header and a data row', () {
    final lines = const LineSplitter().convert(exportCsv(accounts));
    expect(lines.first, 'issuer,name,secret,type,algorithm,digits,counter');
    expect(lines[1], contains('GitHub'));
    expect(lines[1], contains('JBSWY3DP'));
  });

  test('csv quotes fields containing comma', () {
    final tricky = [OtpAccount(
      secret: Uint8List.fromList([0x48,0x65,0x6C,0x6C,0x6F]),
      name: 'a,b', issuer: 'x', algorithm: OtpAlgorithm.sha1,
      digits: OtpDigits.six, type: OtpType.totp, counter: 0)];
    expect(exportCsv(tricky), contains('"a,b"'));
  });

  test('text/url export one otpauth uri per line', () {
    final text = exportText(accounts);
    expect(const LineSplitter().convert(text), hasLength(1));
    expect(text, startsWith('otpauth://totp/'));
    expect(exportUrl(accounts), exportText(accounts)); // -t 与 -u 同形态
  });
}
```

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/core/exporters_test.dart` → Expected: FAIL

- [ ] **Step 3: 实现 4 个导出器**
```dart
// lib/core/exporters/json_exporter.dart
import 'dart:convert';
import 'package:base32/base32.dart';
import '../otp_account.dart';

String exportJson(List<OtpAccount> accounts) {
  final list = accounts.map((a) => {
        'issuer': a.issuer,
        'name': a.name,
        'secret': base32.encode(a.secret).replaceAll('=', ''),
        'type': a.type.uriLabel,
        'algorithm': a.algorithm.label,
        'digits': a.digits.count,
        'counter': a.counter,
      }).toList();
  return const JsonEncoder.withIndent('  ').convert(list);
}
```
```dart
// lib/core/exporters/csv_exporter.dart
import 'package:base32/base32.dart';
import '../otp_account.dart';

String _cell(String v) =>
    (v.contains(',') || v.contains('"') || v.contains('\n'))
        ? '"${v.replaceAll('"', '""')}"'
        : v;

String exportCsv(List<OtpAccount> accounts) {
  final rows = <String>['issuer,name,secret,type,algorithm,digits,counter'];
  for (final a in accounts) {
    rows.add([
      _cell(a.issuer),
      _cell(a.name),
      _cell(base32.encode(a.secret).replaceAll('=', '')),
      a.type.uriLabel,
      a.algorithm.label,
      a.digits.count.toString(),
      a.counter.toString(),
    ].join(','));
  }
  return rows.join('\n');
}
```
```dart
// lib/core/exporters/text_exporter.dart
import '../otp_account.dart';
import '../otpauth_uri.dart';

String exportText(List<OtpAccount> accounts) =>
    accounts.map(buildOtpauthUri).join('\n');
```
```dart
// lib/core/exporters/url_exporter.dart
import '../otp_account.dart';
import 'text_exporter.dart';

// 原 CLI -u 与 -t 同为 otpauth:// URL 列表，保留独立入口以对齐命令语义。
String exportUrl(List<OtpAccount> accounts) => exportText(accounts);
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/core/exporters_test.dart` → Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add lib/core/exporters test/core/exporters_test.dart
git commit -m "feat(core): add json/csv/text/url exporters"
```

---

## Phase 6 — 输入适配层

### Task 7: 静态图片 QR 解码（image + zxing2，全平台）

**Files:**
- Create: `lib/scan/qr_source.dart`, `lib/scan/image_qr_decoder.dart`
- Test: `test/scan/image_qr_decoder_test.dart`

- [ ] **Step 1: 写失败测试（用代码生成一张含已知文本的 QR 图片再解码，闭环）**
```dart
// test/scan/image_qr_decoder_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';
import 'package:otp_migrator/scan/image_qr_decoder.dart';

/// 用 qr 包把文本画成黑白 PNG 字节（每模块 8px，4 模块静区）。
Uint8List makeQrPng(String text) {
  final code = QrCode.fromData(errorCorrectLevel: QrErrorCorrectLevel.M, data: text);
  final qrImage = QrImage(code);
  const scale = 8, quiet = 4;
  final n = code.moduleCount;
  final size = (n + quiet * 2) * scale;
  final picture = img.Image(width: size, height: size);
  img.fill(picture, color: img.ColorRgb8(255, 255, 255));
  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      if (qrImage.isDark(y, x)) {
        img.fillRect(picture,
            x1: (x + quiet) * scale, y1: (y + quiet) * scale,
            x2: (x + quiet + 1) * scale - 1, y2: (y + quiet + 1) * scale - 1,
            color: img.ColorRgb8(0, 0, 0));
      }
    }
  }
  return Uint8List.fromList(img.encodePng(picture));
}

void main() {
  test('decodes QR text from PNG bytes', () {
    const text = 'otpauth-migration://offline?data=ABC';
    final png = makeQrPng(text);
    expect(decodeQrFromImageBytes(png), text);
  });

  test('returns null for non-QR image', () {
    final blank = img.Image(width: 32, height: 32);
    img.fill(blank, color: img.ColorRgb8(200, 200, 200));
    expect(decodeQrFromImageBytes(Uint8List.fromList(img.encodePng(blank))), isNull);
  });
}
```
> `qr` 包随 `qr_flutter` 传递依赖引入；若测试中无法直接引用，则 `flutter pub add qr` 显式添加。

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/scan/image_qr_decoder_test.dart` → Expected: FAIL

- [ ] **Step 3: 实现**
```dart
// lib/scan/qr_source.dart
class QrDecodeResult {
  const QrDecodeResult({required this.sourceLabel, this.url, this.error});
  final String sourceLabel; // 文件名 / "摄像头" / "粘贴"
  final String? url;        // 解码出的 otpauth-migration url
  final String? error;
  bool get ok => url != null && error == null;
}
```
```dart
// lib/scan/image_qr_decoder.dart
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// 解码静态图片字节中的 QR 文本；失败返回 null。纯 Dart，全平台可用。
String? decodeQrFromImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final rgba = decoded.convert(numChannels: 4);
  final pixels = Int32List(rgba.width * rgba.height);
  var i = 0;
  for (final p in rgba) {
    // zxing2 期望 ARGB（int32）。
    pixels[i++] = (0xFF << 24) |
        (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt();
  }
  final source = RGBLuminanceSource(rgba.width, rgba.height, pixels);
  final bitmap = BinaryBitmap(HybridBinarizer(source));
  try {
    final result = QRCodeReader().decode(bitmap);
    return result.text;
  } on NotFoundException {
    return null;
  } catch (_) {
    return null;
  }
}
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/scan/image_qr_decoder_test.dart` → Expected: PASS
（若 `HybridBinarizer` 对生成图识别不稳，改用 `GlobalHistogramBinarizer`。）

- [ ] **Step 5: Commit**
```bash
git add lib/scan/qr_source.dart lib/scan/image_qr_decoder.dart test/scan/image_qr_decoder_test.dart
git commit -m "feat(scan): pure-Dart static image QR decoding (image + zxing2)"
```

### Task 8: 摄像头扫码封装（mobile_scanner）

**Files:**
- Create: `lib/scan/camera_scanner.dart`

- [ ] **Step 1: 实现支持性判断 + 组件封装**（无逻辑单测；UI 集成时冒烟）
```dart
// lib/scan/camera_scanner.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// mobile_scanner 仅支持 iOS/Android/macOS/Web；其余平台隐藏摄像头入口。
bool get cameraScanSupported {
  if (kIsWeb) return true;
  return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
}

/// 简单的扫码视图；命中后回调 url 文本（可能是 otpauth-migration）。
class CameraScannerView extends StatelessWidget {
  const CameraScannerView({super.key, required this.onDetect});
  final void Function(String value) onDetect;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (capture) {
        for (final barcode in capture.barcodes) {
          final raw = barcode.rawValue;
          if (raw != null && raw.isNotEmpty) {
            onDetect(raw);
            break;
          }
        }
      },
    );
  }
}
```

- [ ] **Step 2: 静态分析通过**
Run: `flutter analyze lib/scan/camera_scanner.dart` → Expected: No issues

- [ ] **Step 3: Commit**
```bash
git add lib/scan/camera_scanner.dart
git commit -m "feat(scan): camera scanner wrapper with platform gating"
```

---

## Phase 7 — QR 生成与导出落盘

### Task 9: QR 图片渲染（otpauth:// → PNG 字节）

**Files:**
- Create: `lib/export/qr_image_renderer.dart`

- [ ] **Step 1: 实现**（依赖 Flutter binding，归为组件级；单测可选）
```dart
// lib/export/qr_image_renderer.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';

/// 把单条 otpauth:// URL 渲染为 PNG 字节。
Future<Uint8List> renderQrPng(String data, {double size = 512}) async {
  final painter = QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: true,
    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: 0xFF000000) as dynamic,
  );
  final ui.Image image = await painter.toImage(size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
```
> 注：`QrPainter.toImage(size)` 返回 `ui.Image`；若当前 qr_flutter 版本签名不同（如 `toImageData(size)` 返回 `ByteData`），按实际 API 调整为返回 PNG 字节。执行时以 `flutter pub deps` 锁定版本的 API 为准。eyeStyle 行如不被支持则删除，保留默认样式。

- [ ] **Step 2: 静态分析**
Run: `flutter analyze lib/export/qr_image_renderer.dart` → Expected: No issues

- [ ] **Step 3: Commit**
```bash
git add lib/export/qr_image_renderer.dart
git commit -m "feat(export): render otpauth uri to QR PNG bytes"
```

### Task 10: 跨平台导出写盘

**Files:**
- Create: `lib/export/export_writer.dart`

- [ ] **Step 1: 实现**（桌面/移动 dart:io；Web 用 file_picker bytes + archive zip）
```dart
// lib/export/export_writer.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ExportWriter {
  /// 保存单个文本文件（json/csv/text/url）。返回保存路径或 null（取消/Web 已下载）。
  static Future<String?> saveTextFile({
    required String suggestedName,
    required String content,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(content));
    return FilePicker.platform.saveFile(
      fileName: suggestedName,
      bytes: kIsWeb ? bytes : null, // Web 必须给 bytes 直接下载
    ).then((path) async {
      if (kIsWeb) return path; // Web：已触发下载
      if (path == null) return null;
      await File(path).writeAsBytes(bytes);
      return path;
    });
  }

  /// 保存多张 QR PNG。桌面/移动写入用户选择的目录；Web 打包为 zip 下载。
  static Future<String?> saveQrImages(Map<String, Uint8List> namedPngs) async {
    if (kIsWeb) {
      final archive = Archive();
      namedPngs.forEach((name, data) =>
          archive.addFile(ArchiveFile(name, data.length, data)));
      final zip = Uint8List.fromList(ZipEncoder().encode(archive)!);
      return FilePicker.platform
          .saveFile(fileName: 'otp_qrcodes.zip', bytes: zip);
    }
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return null;
    for (final entry in namedPngs.entries) {
      await File('$dir/${entry.key}').writeAsBytes(entry.value);
    }
    return dir;
  }
}
```
> 注：`ZipEncoder().encode` 在新版 archive 中可能返回非空 `List<int>`；按实际 API 去掉 `!` 即可。`FilePicker.saveFile` 在桌面返回路径、Web 触发下载，行为以锁定版本为准。

- [ ] **Step 2: 静态分析**
Run: `flutter analyze lib/export/export_writer.dart` → Expected: No issues

- [ ] **Step 3: Commit**
```bash
git add lib/export/export_writer.dart
git commit -m "feat(export): cross-platform file & QR image writer"
```

---

## Phase 8 — 状态管理（Riverpod）

### Task 11: ParseGroup 与合并/去重逻辑（TDD 核心派生逻辑）

**Files:**
- Create: `lib/state/parse_group.dart`, `lib/state/app_state.dart`
- Test: `test/state/merge_test.dart`

- [ ] **Step 1: 写失败测试（合并去重为纯函数，可单测）**
```dart
// test/state/merge_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_migrator/core/otp_account.dart';
import 'package:otp_migrator/state/parse_group.dart';

OtpAccount a(List<int> secret, String name) => OtpAccount(
      secret: Uint8List.fromList(secret), name: name, issuer: 'i',
      algorithm: OtpAlgorithm.sha1, digits: OtpDigits.six,
      type: OtpType.totp, counter: 0);

void main() {
  test('mergeDedup flattens groups and dedupes by secret+name', () {
    final groups = [
      ParseGroup(sourceLabel: 'q1.png', accounts: [a([1], 'x'), a([2], 'y')]),
      ParseGroup(sourceLabel: 'q2.png', accounts: [a([2], 'y'), a([3], 'z')]),
    ];
    final merged = mergeDedup(groups);
    expect(merged.map((e) => e.name), ['x', 'y', 'z']); // 保留首次出现
  });

  test('failed groups are ignored in merge', () {
    final groups = [
      ParseGroup(sourceLabel: 'bad.png', accounts: const [], error: '解码失败'),
      ParseGroup(sourceLabel: 'q.png', accounts: [a([9], 'k')]),
    ];
    expect(mergeDedup(groups).single.name, 'k');
  });
}
```

- [ ] **Step 2: 运行确认失败**
Run: `flutter test test/state/merge_test.dart` → Expected: FAIL

- [ ] **Step 3: 实现 parse_group.dart**
```dart
// lib/state/parse_group.dart
import 'dart:convert';
import '../core/otp_account.dart';

class ParseGroup {
  const ParseGroup({required this.sourceLabel, required this.accounts, this.error});
  final String sourceLabel;
  final List<OtpAccount> accounts;
  final String? error;
  bool get ok => error == null;
}

String _keyOf(OtpAccount a) =>
    '${base64Encode(a.secret)}|${a.name}|${a.issuer}';

/// 扁平化所有成功组并按 secret+name+issuer 去重（保留首次出现）。
List<OtpAccount> mergeDedup(List<ParseGroup> groups) {
  final seen = <String>{};
  final out = <OtpAccount>[];
  for (final g in groups) {
    if (!g.ok) continue;
    for (final acc in g.accounts) {
      if (seen.add(_keyOf(acc))) out.add(acc);
    }
  }
  return out;
}
```

- [ ] **Step 4: 运行通过**
Run: `flutter test test/state/merge_test.dart` → Expected: PASS

- [ ] **Step 5: 实现 app_state.dart（Riverpod providers，无需单测）**
```dart
// lib/state/app_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/otp_account.dart';
import 'parse_group.dart';

/// 所有解析组（按来源）。
final parseGroupsProvider =
    NotifierProvider<ParseGroupsNotifier, List<ParseGroup>>(ParseGroupsNotifier.new);

class ParseGroupsNotifier extends Notifier<List<ParseGroup>> {
  @override
  List<ParseGroup> build() => const [];
  void add(ParseGroup g) => state = [...state, g];
  void clear() => state = const [];
  void removeAt(int i) => state = [...state]..removeAt(i);
}

/// 合并导出开关。
final mergeEnabledProvider =
    NotifierProvider<MergeNotifier, bool>(MergeNotifier.new);

class MergeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

/// 派生：合并去重后的账户列表（导出时按需使用）。
final mergedAccountsProvider = Provider<List<OtpAccount>>(
    (ref) => mergeDedup(ref.watch(parseGroupsProvider)));
```

- [ ] **Step 6: 静态分析 + Commit**
Run: `flutter analyze lib/state` → Expected: No issues
```bash
git add lib/state test/state/merge_test.dart
git commit -m "feat(state): parse groups, merge toggle, dedup with riverpod"
```

---

## Phase 9 — UI（应用 Phase 0 设计）

### Task 12: 应用入口与主页骨架

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`, `lib/ui/pages/home_page.dart`

- [ ] **Step 1: main.dart 包裹 ProviderScope**
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() => runApp(const ProviderScope(child: OtpMigratorApp()));
```

- [ ] **Step 2: app.dart 套用 Phase 0 主题**
```dart
// lib/app.dart
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
      theme: AppTheme.light,        // Phase 0 产出
      darkTheme: AppTheme.dark,     // Phase 0 产出
      home: const HomePage(),
    );
  }
}
```

- [ ] **Step 3: home_page.dart 响应式布局（宽屏两栏 / 窄屏 Tab）**
```dart
// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'import_panel.dart';
import 'results_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Migrator')),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) {
          return const Row(children: [
            Expanded(flex: 2, child: ImportPanel()),
            VerticalDivider(width: 1),
            Expanded(flex: 3, child: ResultsPanel()),
          ]);
        }
        return const DefaultTabController(
          length: 2,
          child: Column(children: [
            TabBar(tabs: [Tab(text: '导入'), Tab(text: '结果')]),
            Expanded(child: TabBarView(children: [ImportPanel(), ResultsPanel()])),
          ]),
        );
      }),
    );
  }
}
```

- [ ] **Step 4: 运行冒烟**
Run: `flutter run -d macos`（或当前可用桌面设备）→ Expected: 启动显示空的导入/结果两栏，无报错。

- [ ] **Step 5: Commit**
```bash
git add lib/main.dart lib/app.dart lib/ui/pages/home_page.dart
git commit -m "feat(ui): app entry, theme wiring, responsive home layout"
```

### Task 13: 导入面板（图片/拖拽/粘贴/扫码 + Web 提示）

**Files:**
- Create: `lib/ui/pages/import_panel.dart`

- [ ] **Step 1: 实现导入入口，全部接 MigrationDecoder 并写入 state**
```dart
// lib/ui/pages/import_panel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/migration_decoder.dart';
import '../../scan/image_qr_decoder.dart';
import '../../scan/camera_scanner.dart';
import '../../state/app_state.dart';
import '../../state/parse_group.dart';

class ImportPanel extends ConsumerWidget {
  const ImportPanel({super.key});

  Future<void> _pickImages(WidgetRef ref) async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true, type: FileType.image, withData: true);
    if (res == null) return;
    for (final f in res.files) {
      final bytes = f.bytes;
      if (bytes == null) continue;
      final url = decodeQrFromImageBytes(bytes);
      ref.read(parseGroupsProvider.notifier).add(_groupFor(f.name, url));
    }
  }

  void _decodePasted(WidgetRef ref, String text) {
    ref.read(parseGroupsProvider.notifier).add(_groupFor('粘贴', text.trim()));
  }

  ParseGroup _groupFor(String label, String? url) {
    if (url == null || url.isEmpty) {
      return ParseGroup(sourceLabel: label, accounts: const [], error: '未识别二维码');
    }
    try {
      return ParseGroup(sourceLabel: label, accounts: MigrationDecoder.decodeUrl(url));
    } catch (e) {
      return ParseGroup(sourceLabel: label, accounts: const [], error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pasteCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        if (kIsWeb)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('⚠️ 浏览器环境处理 OTP 凭据存在泄露风险，敏感场景建议使用桌面端。'),
            ),
          ),
        FilledButton.icon(
          onPressed: () => _pickImages(ref),
          icon: const Icon(Icons.image_outlined),
          label: const Text('选择二维码图片（可多选）'),
        ),
        const SizedBox(height: 12),
        if (cameraScanSupported)
          OutlinedButton.icon(
            onPressed: () => _openCamera(context, ref),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('摄像头扫码'),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: pasteCtrl,
          minLines: 2, maxLines: 4,
          decoration: const InputDecoration(
            labelText: '粘贴 otpauth-migration 链接',
            border: OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _decodePasted(ref, pasteCtrl.text),
          child: const Text('解析链接'),
        ),
      ]),
    );
  }

  void _openCamera(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (ctx) => Dialog(
      child: SizedBox(width: 360, height: 360,
        child: CameraScannerView(onDetect: (value) {
          Navigator.of(ctx).pop();
          ref.read(parseGroupsProvider.notifier).add(_groupFor('摄像头', value.trim()));
        }),
      ),
    ));
  }
}
```
> 拖拽支持：如需桌面拖拽文件，`flutter pub add desktop_drop` 并包一层 `DropTarget`，把 drop 的文件字节走同一 `_groupFor` 流程。本步骤先交付选图/粘贴/扫码；拖拽作为 Task 13b 可选增强。

- [ ] **Step 2: 静态分析 + 冒烟**
Run: `flutter analyze lib/ui/pages/import_panel.dart` → Expected: No issues
手动：选一张真实 Google Authenticator 导出二维码 → 结果区出现账户组。

- [ ] **Step 3: Commit**
```bash
git add lib/ui/pages/import_panel.dart
git commit -m "feat(ui): import panel (image/paste/camera) wired to decoder"
```

### Task 14: 结果面板 + 账户卡片 + 合并开关

**Files:**
- Create: `lib/ui/pages/results_panel.dart`, `lib/ui/widgets/account_card.dart`

- [ ] **Step 1: account_card.dart**
```dart
// lib/ui/widgets/account_card.dart
import 'package:flutter/material.dart';
import 'package:base32/base32.dart';
import '../../core/otp_account.dart';
import '../../core/otpauth_uri.dart';
import 'qr_preview_dialog.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.account});
  final OtpAccount account;
  @override
  Widget build(BuildContext context) {
    final secret = base32.encode(account.secret).replaceAll('=', '');
    return Card(
      child: ListTile(
        title: Text(account.issuer.isEmpty ? account.name : '${account.issuer} · ${account.name}'),
        subtitle: Text('${account.type.uriLabel.toUpperCase()} · '
            '${account.algorithm.label} · ${account.digits.count} 位\n$secret'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.qr_code_2),
          tooltip: '显示二维码',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => QrPreviewDialog(data: buildOtpauthUri(account)),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: results_panel.dart（分组展示 + 合并开关 + 导出入口）**
```dart
// lib/ui/pages/results_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_state.dart';
import '../widgets/account_card.dart';
import 'export_dialog.dart';

class ResultsPanel extends ConsumerWidget {
  const ResultsPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(parseGroupsProvider);
    final merge = ref.watch(mergeEnabledProvider);
    if (groups.isEmpty) {
      return const Center(child: Text('从左侧导入二维码后，这里显示解析结果'));
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Switch(value: merge, onChanged: (_) => ref.read(mergeEnabledProvider.notifier).toggle()),
          const Text('合并导出（汇总去重）'),
          const Spacer(),
          TextButton.icon(
            onPressed: () => ref.read(parseGroupsProvider.notifier).clear(),
            icon: const Icon(Icons.clear_all), label: const Text('清空')),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => const ExportDialog()),
            icon: const Icon(Icons.download), label: const Text('导出')),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: merge
            ? _MergedList()
            : ListView(children: [
                for (final g in groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(g.ok ? g.sourceLabel : '${g.sourceLabel} — ${g.error}',
                        style: Theme.of(context).textTheme.labelLarge),
                  ),
                  for (final a in g.accounts) AccountCard(account: a),
                ]
              ]),
      ),
    ]);
  }
}

class _MergedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merged = ref.watch(mergedAccountsProvider);
    return ListView(children: [for (final a in merged) AccountCard(account: a)]);
  }
}
```

- [ ] **Step 3: 静态分析 + 冒烟**
Run: `flutter analyze lib/ui` → Expected: No issues（`export_dialog.dart`/`qr_preview_dialog.dart` 将在 Task 15/16 创建；如分析报缺失，按下面任务先建占位再回填——本计划顺序应先建 16 再 14，执行时若顺序冲突，先创建被依赖文件）

- [ ] **Step 4: Commit**
```bash
git add lib/ui/widgets/account_card.dart lib/ui/pages/results_panel.dart
git commit -m "feat(ui): results panel with grouping, merge toggle and account cards"
```

### Task 15: 二维码预览对话框（对应 -p）

**Files:**
- Create: `lib/ui/widgets/qr_preview_dialog.dart`

- [ ] **Step 1: 实现（用 qr_flutter QrImageView 直接展示）**
```dart
// lib/ui/widgets/qr_preview_dialog.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreviewDialog extends StatelessWidget {
  const QrPreviewDialog({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          QrImageView(data: data, version: QrVersions.auto, size: 280,
              backgroundColor: Colors.white),
          const SizedBox(height: 12),
          SelectableText(data, maxLines: 3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2: 静态分析 + Commit**
Run: `flutter analyze lib/ui/widgets/qr_preview_dialog.dart` → Expected: No issues
```bash
git add lib/ui/widgets/qr_preview_dialog.dart
git commit -m "feat(ui): otpauth QR preview dialog"
```

### Task 16: 导出对话框（选格式 + 目标 + 合并感知）

**Files:**
- Create: `lib/ui/pages/export_dialog.dart`

- [ ] **Step 1: 实现（按合并开关决定导出账户来源；调用 exporters + ExportWriter + qr renderer）**
```dart
// lib/ui/pages/export_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/otp_account.dart';
import '../../core/otpauth_uri.dart';
import '../../core/exporters/json_exporter.dart';
import '../../core/exporters/csv_exporter.dart';
import '../../core/exporters/text_exporter.dart';
import '../../core/exporters/url_exporter.dart';
import '../../export/export_writer.dart';
import '../../export/qr_image_renderer.dart';
import '../../state/app_state.dart';
import '../../state/parse_group.dart';

enum ExportFormat { json, csv, text, url, qrImages }

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});
  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  ExportFormat _fmt = ExportFormat.json;
  String? _status;

  List<OtpAccount> _accounts() {
    if (ref.read(mergeEnabledProvider)) return ref.read(mergedAccountsProvider);
    return [for (final g in ref.read(parseGroupsProvider)) if (g.ok) ...g.accounts];
  }

  Future<void> _run() async {
    final accounts = _accounts();
    if (accounts.isEmpty) { setState(() => _status = '没有可导出的账户'); return; }
    String? where;
    switch (_fmt) {
      case ExportFormat.json:
        where = await ExportWriter.saveTextFile(suggestedName: 'otp.json', content: exportJson(accounts));
      case ExportFormat.csv:
        where = await ExportWriter.saveTextFile(suggestedName: 'otp.csv', content: exportCsv(accounts));
      case ExportFormat.text:
        where = await ExportWriter.saveTextFile(suggestedName: 'otp.txt', content: exportText(accounts));
      case ExportFormat.url:
        where = await ExportWriter.saveTextFile(suggestedName: 'otp_urls.txt', content: exportUrl(accounts));
      case ExportFormat.qrImages:
        final pngs = <String, Uint8List>{};
        for (var i = 0; i < accounts.length; i++) {
          final a = accounts[i];
          final safe = '${i + 1}_${a.issuer}_${a.name}'.replaceAll(RegExp(r'[^\w\-.]'), '_');
          pngs['$safe.png'] = await renderQrPng(buildOtpauthUri(a));
        }
        where = await ExportWriter.saveQrImages(pngs);
    }
    setState(() => _status = where == null ? '已取消' : '已导出到：$where');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导出'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final f in ExportFormat.values)
          RadioListTile<ExportFormat>(
            value: f, groupValue: _fmt,
            onChanged: (v) => setState(() => _fmt = v!),
            title: Text(switch (f) {
              ExportFormat.json => 'JSON 文件',
              ExportFormat.csv => 'CSV 文件',
              ExportFormat.text => '文本 URL 列表',
              ExportFormat.url => 'URL 格式',
              ExportFormat.qrImages => '二维码图片（每账户一张）',
            }),
          ),
        if (_status != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_status!)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _run, child: const Text('导出')),
      ],
    );
  }
}
```
> 需在文件顶部补 `import 'dart:typed_data';`（`Uint8List`）。

- [ ] **Step 2: 静态分析 + 全量冒烟**
Run: `flutter analyze` → Expected: No issues
手动：导入 → 切换合并开关 → 分别导出 JSON / CSV / 文本 / URL / 二维码图片，校验文件内容正确。

- [ ] **Step 3: Commit**
```bash
git add lib/ui/pages/export_dialog.dart
git commit -m "feat(ui): export dialog with all formats and merge awareness"
```

---

## Phase 10 — 平台权限与配置

### Task 17: 摄像头权限与 Web 配置

**Files:**
- Modify: `ios/Runner/Info.plist`, `macos/Runner/Info.plist`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `macos/Runner/*.entitlements`（camera entitlement）

- [ ] **Step 1: iOS/macOS 增加相机用途说明**
在 `ios/Runner/Info.plist` 与 `macos/Runner/Info.plist` 的顶层 `<dict>` 内加入：
```xml
<key>NSCameraUsageDescription</key>
<string>用于扫描 Google Authenticator 导出的二维码</string>
```
macOS：在 `macos/Runner/DebugProfile.entitlements` 与 `Release.entitlements` 加入：
```xml
<key>com.apple.security.device.camera</key>
<true/>
```

- [ ] **Step 2: Android 相机权限**
在 `android/app/src/main/AndroidManifest.xml` 的 `<manifest>` 下加入：
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

- [ ] **Step 3: 验证各平台可构建**
```bash
flutter build macos --debug
flutter build apk --debug
flutter build web
```
Expected: 三个目标均构建成功。

- [ ] **Step 4: Commit**
```bash
git add ios macos android
git commit -m "chore: camera permissions for ios/macos/android"
```

---

## Phase 11 — 收尾验证

### Task 18: 全量测试与多平台冒烟 + README

**Files:**
- Create: `README.md`

- [ ] **Step 1: 全量单测**
Run: `flutter test` → Expected: 所有 core/scan/state 测试 PASS。

- [ ] **Step 2: 静态分析零问题**
Run: `flutter analyze` → Expected: No issues found.

- [ ] **Step 3: 真实样例端到端**
用一张真实 Google Authenticator 导出二维码（含多账户）在桌面端验证：解析、分组、合并去重、5 种导出全部正确。

- [ ] **Step 4: 写 README（功能、平台、构建、安全说明）**
内容涵盖：项目简介、对齐 decodeGoogleOTP 的功能表、支持平台、`flutter run`/`build` 指引、离线安全声明、Web 风险提示。

- [ ] **Step 5: Commit**
```bash
git add README.md
git commit -m "docs: add README with features, build and security notes"
```

---

## Self-Review（针对 spec 的覆盖核对）

- **多格式导出（JSON/CSV/QR/文本/URL/终端式）** → Task 6（前四）、Task 9+16（QR 图片）、Task 15（应用内二维码=终端打印替代）✔
- **多二维码同时解析** → Task 13 多选导入 + Task 11 分组 ✔
- **可选合并 + 去重** → Task 11 `mergeDedup` + Task 14 开关 + Task 16 合并感知导出 ✔
- **三种输入源（图片/摄像头/粘贴）** → Task 7/8/13 ✔
- **跨平台（桌面/移动/Web）** → Task 1 平台目标 + Task 7 全平台解码 + Task 8 摄像头平台门控 + Task 10 Web 导出 + Task 17 权限 ✔
- **OTP 全参数提取** → Task 4 提取 secret/name/issuer/algorithm/digits/type/counter ✔
- **安全（离线、显式导出、Web 提示）** → Task 13 Web 提示 + Task 16 显式保存 + 无网络依赖（去除 dio）✔
- **编码前 frontend-design** → Phase 0 / Task 0 ✔
- **避免 CVE/弃用包** → `flutter pub add` 取最新；去除 dio/protoc 依赖 ✔

**类型一致性核对**：`OtpAccount`(secret:Uint8List) 贯穿 decoder/exporters/uri/state；`ParseGroup.ok`、`mergeDedup`、provider 命名（`parseGroupsProvider`/`mergeEnabledProvider`/`mergedAccountsProvider`）在 Task 11/14/16 一致；`buildOtpauthUri`/`decodeQrFromImageBytes`/`renderQrPng`/`ExportWriter.saveTextFile/saveQrImages` 命名跨任务一致。

**已知执行期注意点（非占位符，明确标注）**：qr_flutter `toImage` vs `toImageData` 签名、archive `ZipEncoder().encode` 返回是否可空——均给出按锁定版本 API 微调的明确指引。

**依赖顺序提示**：Task 14 引用 Task 15/16 的对话框；执行时先建被依赖文件或先放占位空 Widget，避免分析中断。
