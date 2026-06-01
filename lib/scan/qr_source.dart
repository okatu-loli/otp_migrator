class QrDecodeResult {
  const QrDecodeResult({required this.sourceLabel, this.url, this.error});
  final String sourceLabel; // 文件名 / "摄像头" / "粘贴"
  final String? url;        // 解码出的 otpauth-migration url
  final String? error;
  bool get ok => url != null && error == null;
}
