# OTP Migrator — 设计文档

- 日期：2026-06-01
- 状态：已通过 brainstorming 评审，待 spec 复核
- 项目目录：`/Users/yuxiaofan/Documents/code/otp_migrator`

## 1. 目标

实现一个跨平台 Flutter GUI 应用，复刻 [decodeGoogleOTP](https://github.com/Kuingsmile/decodeGoogleOTP)（Go CLI）的全部功能：解析 Google Authenticator 导出的二维码（`otpauth-migration://offline?data=...`），提取每个账户的 OTP 参数，并导出为多种格式。在原项目基础上增加 GUI 特性：一次解析多张二维码、可选合并导出。

### 范围确认（brainstorming 结论）
- **平台**：桌面（macOS/Windows/Linux）+ 移动（iOS/Android）+ Web，全覆盖。
- **输入方式**：图片文件导入（多选 + 拖拽）、摄像头实时扫码、直接粘贴 `otpauth-migration` URL。
- **合并语义**：默认逐张二维码独立成组、独立导出；顶部「合并导出」开关打开后，所有账户汇总并按 secret 去重作为整体导出。
- **功能范围**：严格对齐原项目，**不**加实时 TOTP 验证码生成。
- **架构**：方案 A —— 纯 Dart 实现全部解码逻辑（无原生二进制、无 FFI），保证 Web 与全平台可用、攻击面最小、易审计。

## 2. 原项目功能映射

| 原 CLI 能力 | 本应用对应 |
|---|---|
| `-i` 输入二维码图片 | 图片导入 / 摄像头 / 粘贴 URL 三种输入源 |
| `-j` JSON 导出 | JSON 导出 |
| `-c` CSV 导出 | CSV 导出 |
| `-q` 二维码图片导出（每账户标准 otpauth:// 图） | 二维码图片导出到目录 |
| `-t` 纯文本 URL 列表 | 文本 URL 列表导出 |
| `-u` URL 格式导出 | URL 格式导出 |
| `-p` 终端打印二维码 | 应用内二维码预览（逐账户展示，可放大） |
| `-d` debug / `-s` silent | 应用内日志面板（可开关），不阻塞 UI |

## 3. 解析管线

```
输入源 ──► 提取 otpauth-migration URL ──► URL 解码 ──► base64 解码
   │                                                        │
   ├─ 图片字节（file_picker 读入）                          ▼
   ├─ 摄像头帧（mobile_scanner 回调）              protobuf 解析 MigrationPayload
   └─ 粘贴文本（直接得到 URL）                              │
                                                            ▼
                                  遍历 repeated OtpParameters，逐项提取：
                                    secret(bytes) ─► base32 编码
                                    name / issuer
                                    algorithm: SHA1 / SHA256 / SHA512 / MD5
                                    digits: 6 / 8
                                    type: TOTP / HOTP
                                    counter (HOTP)
                                            │
                                            ▼
                                  统一模型 OtpAccount 列表（按来源分组）
```

### MigrationPayload protobuf 结构（用于生成 Dart 代码）
```proto
message MigrationPayload {
  enum Algorithm   { ALGORITHM_UNSPECIFIED=0; ALGORITHM_SHA1=1; ALGORITHM_SHA256=2; ALGORITHM_SHA512=3; ALGORITHM_MD5=4; }
  enum DigitCount  { DIGIT_COUNT_UNSPECIFIED=0; DIGIT_COUNT_SIX=1; DIGIT_COUNT_EIGHT=2; }
  enum OtpType     { OTP_TYPE_UNSPECIFIED=0; OTP_TYPE_HOTP=1; OTP_TYPE_TOTP=2; }
  message OtpParameters {
    bytes secret = 1;
    string name = 2;
    string issuer = 3;
    Algorithm algorithm = 4;
    DigitCount digits = 5;
    OtpType type = 6;
    int64 counter = 7;
  }
  repeated OtpParameters otp_parameters = 1;
  int32 version = 2;
  int32 batch_size = 3;
  int32 batch_index = 4;
  int64 batch_id = 5;
}
```

### 生成标准 otpauth:// URL（导出 / 二维码用）
`otpauth://{totp|hotp}/{issuer:}{name}?secret={base32}&issuer={issuer}&algorithm={SHA1...}&digits={6|8}[&counter={n}]`，按 RFC 与 Key URI Format 规范拼装，secret 用无填充 base32 大写。

## 4. 模块边界

```
lib/
  core/                          纯 Dart，零 Flutter 依赖，可独立单元测试
    otp_account.dart             OtpAccount 数据模型 + 枚举（algorithm/digits/type）
    migration_decoder.dart       URL/字节 → MigrationPayload → List<OtpAccount>
    otpauth_uri.dart             OtpAccount → 标准 otpauth:// URL
    proto/migration.pb.dart      protobuf 生成代码
    exporters/
      json_exporter.dart         List<OtpAccount> → JSON 字符串（纯函数）
      csv_exporter.dart          → CSV 字符串
      text_exporter.dart         → 纯文本 URL 列表
      url_exporter.dart          → URL 格式
  scan/                          输入源适配层
    image_source.dart            file_picker 选图/拖拽 → 字节
    camera_source.dart           mobile_scanner 摄像头扫码
    image_qr_decoder.dart        静态图片字节 → QR 文本（zxing2 纯 Dart，全平台兜底）
    paste_source.dart            粘贴文本输入
  export/
    qr_image_exporter.dart       otpauth:// → QR PNG（qr_flutter 渲染→图片字节）
    file_writer.dart             跨平台落盘（桌面/移动 file_saver、Web 下载）
  ui/                            页面与组件（实现前用 frontend-design 产出设计）
    pages/                       导入页 / 结果页 / 账户详情 / 二维码预览 / 导出对话框
    widgets/                     账户卡片、来源分组、合并开关、日志面板
    theme/                       设计令牌（色彩/字体/间距）
  app.dart
  main.dart
test/
  core/                          解析与导出的单元测试（含真实 migration 样例向量）
```

**隔离原则**：`core/` 不依赖 Flutter，可在纯 Dart 测试环境跑；`scan/` 与 `export/` 通过接口暴露能力，UI 仅依赖接口，便于替换平台实现与测试。

## 5. 数据流与状态

- 解析产物按「来源（一张二维码 / 一次粘贴 / 一次扫码）」分组，保存为 `List<ParseGroup>`，每组含来源标签 + `List<OtpAccount>`。
- 「合并导出」开关为 UI 级状态：开启时导出前先 flatten 所有组、按 `secret` 去重（保留首次出现）。
- 状态管理使用 Flutter 官方推荐的轻量方案（`ValueNotifier`/`ChangeNotifier` + `provider`，或 `flutter_riverpod`），具体在实现计划中按 best practice 定稿。

## 6. 错误处理

- 非二维码图片 / 无法解码 → 该来源标记为失败并展示原因，不影响其他来源。
- URL 非 `otpauth-migration` 前缀 / base64 损坏 / protobuf 解析失败 → 明确错误信息。
- 摄像头权限被拒 → 引导提示与降级到图片导入。
- 导出写文件失败（权限/路径）→ 可重试，错误可见。

## 7. 安全设计

- 全程离线、内存中处理，不写临时密钥文件。
- 导出由用户显式触发并选择目标位置；不做任何网络上传/遥测。
- Web 端在导入入口明确提示「敏感凭据，浏览器环境存在泄露风险，建议桌面端处理」。
- 依赖选型在实现计划阶段用 context7 / pub.dev 核对最新稳定版本与已知 CVE，规避有漏洞版本。

## 8. 测试策略

- `core/` 单元测试为主：用已知 `otpauth-migration` 样例向量断言解析出的 secret(base32)/issuer/name/algorithm/digits/type/counter。
- 导出器纯函数测试：固定输入 → 断言 JSON/CSV/文本/URL 输出。
- `otpauth_uri` 往返测试：URL 拼装符合 Key URI Format。
- 关键平台适配做冒烟测试（图片解码、QR 渲染）。

## 9. 关键依赖（实现计划阶段核对版本/CVE）

| 用途 | 候选包 |
|---|---|
| protobuf 解析 | `protobuf` |
| 摄像头扫码 | `mobile_scanner` |
| 静态图片 QR 解码（全平台兜底，含 Web/桌面） | `zxing2` |
| QR 生成 | `qr_flutter` |
| 文件选择/拖拽 | `file_picker` |
| 文件保存/分享 | `file_saver` / `share_plus` |
| base32 | `base32` |
| 状态管理 | `provider` 或 `flutter_riverpod`（定稿于计划） |

## 10. UI / 设计要求

- **编码前先用 `frontend-design` skill 产出视觉设计**：响应式布局（桌面宽屏多栏、移动单栏），明确视觉语言，规避「AI 模板感」，兼顾美学与跨平台兼容性。
- 该步骤作为实现计划的第一个 phase，先有设计令牌（色彩/排版/间距/组件规范）再写界面代码。

## 11. 非目标（YAGNI）

- 不做实时 TOTP/HOTP 验证码生成与展示。
- 不做账户的本地长期存储 / 同步 / 加密保险库。
- 不做账户编辑（仅解析与导出原始数据）。
- 不做网络功能与遥测。
