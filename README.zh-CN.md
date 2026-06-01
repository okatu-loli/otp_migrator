<p align="center">
  <img src="assets/logo/logo.svg" width="120" alt="OTP Migrator logo">
</p>

<p align="center">
  <a href="README.md">English</a> · <b>简体中文</b>
</p>

# OTP Migrator

**一个跨平台的 Flutter GUI，用于解码 Google Authenticator 导出的迁移二维码。**

> A cross-platform Flutter GUI for decoding Google Authenticator export QR codes, and exporting OTP accounts to multiple formats.

灵感来源并对齐 [decodeGoogleOTP](https://github.com/Kuingsmile/decodeGoogleOTP)（MIT）—— 一个用途相同的 Go 命令行工具。本 GUI 将完整的**离线**解码与导出能力带到 macOS、Windows、Linux、iOS、Android 与 Web，无需依赖 Google Authenticator 应用本身。

---

## 功能特性

- **多种输入方式**
  - 通过文件选择器选择一张或多张二维码图片（PNG/JPG 等）；完全在 Dart 侧用 `image` + `zxing2` 解码，**无需任何原生二进制**。
  - 在 iOS、Android、macOS、Web 上通过 `mobile_scanner` 进行**摄像头实时扫码**。
  - 直接把 `otpauth-migration://` 链接**粘贴**到文本框。

- **Protobuf 解析** —— 手写的 protobuf wire-format 读取器，把迁移负载解码为结构化的 `OtpAccount`（secret、name、issuer、algorithm、digits、type、counter）。

- **多二维码工作流** —— 一次会话内导入多张二维码，结果**按来源分组**。可选的「**合并**」开关会扁平化所有分组，并按 `secret + name + issuer` **去重**。

- **导出格式**
  - JSON —— 每个账户一个对象，包含全部字段。
  - CSV —— 适配电子表格，带表头；含逗号的字段会加引号；以 `= + - @` 开头的字段会被中和，防止公式注入。
  - 纯文本 `otpauth://` 链接列表 —— 每行一个 URI。
  - URL 格式 —— 同样的 URI 形态，便于直接导入其它验证器。
  - 每账户一张二维码 PNG —— 桌面端保存到用户选定的目录；Web 与移动端打包为 ZIP。
  - 应用内二维码预览对话框 —— 用任意验证器 App 扫描重新生成的二维码，等价于 CLI 的 `--print-qr`。

- **设计系统** —— "Terminal Ledger" 主题（`lib/ui/theme/app_theme.dart`），含浅色与深色两套。

- **完全离线** —— 无网络请求、无遥测、无统计。密钥仅驻留内存，只有在用户显式操作时才写出。

- **条件导入的文件写入器** —— `dart:io` 不会泄漏进 Web 构建；导出写入器使用平台桩实现。

---

## 与 CLI 的功能对照表

| CLI 参数 | 说明 | GUI 对应 |
|----------|------|----------|
| `-i <file>` | 输入二维码图片文件 | 文件选择器（支持多选） |
| `-j` | 导出为 JSON | 导出对话框 → JSON 格式 |
| `-c` | 导出为 CSV | 导出对话框 → CSV 格式 |
| `-q` | 在终端打印二维码 | 应用内二维码预览对话框（逐账户） |
| `-t` | 导出为纯文本 `otpauth://` 列表 | 导出对话框 → 文本格式 |
| `-u` | 导出为 URL 列表 | 导出对话框 → URL 格式 |
| `-p` | 粘贴 / stdin 迁移链接 | 导入面板的「粘贴链接」文本框 |

> GUI 额外支持摄像头实时扫码（CLI 无对应），以及批量导出二维码 PNG 到目录或 ZIP。

---

## 支持平台

| 平台 | 文件导入 | 摄像头扫码 | 导出到文件 | 导出 ZIP |
|------|----------|------------|------------|----------|
| macOS    | 支持 | 支持 | 支持（目录） | 否 |
| Windows  | 支持 | 否   | 支持（目录） | 否 |
| Linux    | 支持 | 否   | 支持（目录） | 否 |
| iOS      | 支持 | 支持 | 否           | 支持 |
| Android  | 支持 | 支持 | 否           | 支持 |
| Web      | 支持 | 支持 | 否           | 支持 |

> 摄像头扫码依赖 `mobile_scanner`，仅在 iOS、Android、macOS、Web 可用。Windows 与 Linux 通过文件导入和粘贴链接使用。

---

## 构建与运行

### 前置环境

- **Flutter 3.41.6**（stable 通道，Dart 3.11.4）—— 本项目使用的版本。
- iOS：需要 Xcode 与 CocoaPods。
- Android：需要 Android SDK 与 NDK。

### 安装依赖

```sh
flutter pub get
```

### 开发模式运行

```sh
# macOS 桌面
flutter run -d macos

# Web（Chrome）
flutter run -d chrome

# iOS 模拟器
flutter run -d ios

# Android 模拟器
flutter run -d android

# Windows 桌面
flutter run -d windows

# Linux 桌面
flutter run -d linux
```

### 构建发布版

```sh
# macOS 应用包
flutter build macos

# Web（输出到 build/web/）
flutter build web

# iOS IPA（需要 Apple 开发者账号）
flutter build ios

# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# Windows 可执行文件
flutter build windows

# Linux 可执行文件
flutter build linux
```

---

## 安全说明

- **完全离线。** 应用不发起任何网络请求，数据不会离开设备。
- **内存中处理密钥。** OTP 密钥字节仅保存在 Dart 内存中；除非用户显式触发导出，否则绝不写入磁盘。
- **显式导出。** 只有当用户点击导出按钮、选择保存位置或点击「复制」时，密钥才会被写出。
- **Web 环境警告。** 在浏览器中运行时会显示醒目横幅，提示浏览器存储与剪贴板交互存在固有风险（其它扩展、共享设备等）。追求最高安全性请优先使用桌面原生构建。
- **无日志。** 不包含任何崩溃上报、统计 SDK 或远程日志。

---

## 项目结构

```
lib/
  app.dart                  # 应用根 Widget
  main.dart                 # 入口
  core/                     # 领域模型与纯 Dart 解析
    otp_account.dart        # OtpAccount 与枚举（algorithm/digits/type）
    protobuf_reader.dart    # 手写 protobuf wire-format 读取器
    migration_decoder.dart  # otpauth-migration:// 链接解码器
    otpauth_uri.dart        # otpauth:// URI 构造器
    secret_encoding.dart    # Base32 编码辅助
    exporters/              # JSON、CSV、文本、URL 导出器
  scan/                     # 二维码输入源
    image_qr_decoder.dart   # 静态图片二维码解码（image + zxing2）
    camera_scanner.dart     # 摄像头实时扫码封装（mobile_scanner）
    qr_source.dart          # 来源元数据
  export/                   # 文件 / ZIP 输出
    export_writer.dart      # 条件导入入口
    export_writer_io.dart   # dart:io 实现（桌面/移动）
    export_writer_web.dart  # Web ZIP 实现
    export_writer_stub.dart # 不支持平台的桩
    qr_image_renderer.dart  # 把 otpauth:// URI 渲染为 PNG 字节
  state/                    # Riverpod 状态
    app_state.dart          # 解析分组、合并开关、派生去重列表
    parse_group.dart        # ParseGroup（按来源的结果容器）
  ui/                       # Flutter 组件
    theme/
      app_theme.dart        # "Terminal Ledger" 设计系统（浅色 + 深色）
    pages/
      home_page.dart        # 响应式双栏布局
      import_panel.dart     # 文件选择、粘贴框、摄像头按钮
      results_panel.dart    # 分组账户列表、合并开关
      export_dialog.dart    # 格式选择 + 导出操作
    widgets/
      account_card.dart     # 单账户展示卡片
      qr_preview_dialog.dart# 应用内二维码查看器
```

---

## 许可协议

原始项目 [decodeGoogleOTP](https://github.com/Kuingsmile/decodeGoogleOTP) 以 **MIT 协议**发布。

本 Flutter 项目同样以 **MIT 协议**发布 —— 详见 [`LICENSE`](LICENSE) 文件。Copyright (c) 2026 okatu-loli。
