import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';

/// Web implementation — no dart:io imports.
Future<String?> saveTextFileImpl({
  required String suggestedName,
  required String content,
}) async {
  final bytes = Uint8List.fromList(utf8.encode(content));
  try {
    // On web, saveFile triggers a browser download and returns null.
    await FilePicker.saveFile(
      fileName: suggestedName,
      bytes: bytes,
    );
    // Download was triggered; return suggestedName as a non-null sentinel.
    return suggestedName;
  } catch (_) {
    return null;
  }
}

Future<String?> saveQrImagesImpl(Map<String, Uint8List> namedPngs) async {
  final zipBytes = _zip(namedPngs);
  try {
    await FilePicker.saveFile(
      fileName: 'otp_qrcodes.zip',
      bytes: zipBytes,
    );
    return 'otp_qrcodes.zip';
  } catch (_) {
    return null;
  }
}

Uint8List _zip(Map<String, Uint8List> namedPngs) {
  final archive = Archive();
  namedPngs.forEach(
    (name, data) => archive.addFile(ArchiveFile(name, data.length, data)),
  );
  final out = ZipEncoder().encode(archive);
  return Uint8List.fromList(out);
}
