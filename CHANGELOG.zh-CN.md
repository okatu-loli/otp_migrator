# 更新日志

[English](CHANGELOG.md) · [简体中文](CHANGELOG.zh-CN.md)

> **持续发布。** 每次推送到 `master` 都会发布一个带版本号的 Release
> （`vYYYY.MM.DD.<构建号>`），其更新说明由 **CI 从提交信息自动生成**
> （按 [Conventional Commits](https://www.conventionalcommits.org/) 类型分组，中英双语标题）。
> 完整列表见 [Releases 页面](https://github.com/okatu-loli/otp_migrator/releases)。
>
> 下方为人工整理的 `1.0.0` 基线条目；后续版本以 Releases 页面为准，不再手工编辑此文件。

## [1.0.0] - 2026-06-01

首个公开发布。一个跨平台 Flutter GUI，用于解码 Google Authenticator 导出的
迁移二维码（`otpauth-migration://`）并导出其中的 OTP 账户。

### 新增

- **输入方式**
  - 选择一张或多张二维码图片；完全在 Dart 侧解码（`image` + `zxing2`），无需原生二进制。
  - 在 iOS、Android、macOS、Web 上摄像头实时扫码（`mobile_scanner`）。
  - 直接粘贴 `otpauth-migration://` 链接。
- **解码** —— 手写 protobuf wire-format 读取器，提取每个账户的 secret、name、issuer、
  algorithm、位数、类型（TOTP/HOTP）与计数器。
- **多二维码工作流** —— 一次会话解析多张二维码，按来源分组；可选「合并」开关按
  secret + name + issuer 扁平化去重。
- **导出** —— JSON、CSV（含公式注入中和）、纯文本 `otpauth://` 列表、URL 格式、
  每账户二维码 PNG（桌面写目录，Web/移动打包 ZIP），以及应用内二维码预览对话框。
- **设计** —— "Terminal Ledger" 设计系统，含浅色/深色主题；品牌 logo 与各平台图标。
- **平台** —— macOS、Windows、Linux、iOS、Android、Web。

### 安全

- 完全离线：无网络请求、无遥测、无统计。
- 密钥仅驻留内存，只有用户显式操作才写出。
- Web 构建显示环境风险提示；`dart:io` 不会泄漏进 Web 包。

[1.0.0]: https://github.com/okatu-loli/otp_migrator/releases/tag/v1.0.0
