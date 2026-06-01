import 'dart:typed_data';
import 'export_writer_stub.dart'
    if (dart.library.io) 'export_writer_io.dart'
    if (dart.library.js_interop) 'export_writer_web.dart';

/// 跨平台导出写盘。Web 触发浏览器下载；桌面/移动写入用户选择的位置。
class ExportWriter {
  static Future<String?> saveTextFile({
    required String suggestedName,
    required String content,
  }) =>
      saveTextFileImpl(suggestedName: suggestedName, content: content);

  static Future<String?> saveQrImages(Map<String, Uint8List> namedPngs) =>
      saveQrImagesImpl(namedPngs);
}
