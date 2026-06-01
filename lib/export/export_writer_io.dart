import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';

/// Desktop + mobile implementation that uses dart:io.
Future<String?> saveTextFileImpl({
  required String suggestedName,
  required String content,
}) async {
  final bytes = utf8.encode(content);
  final path = await FilePicker.saveFile(
    fileName: suggestedName,
    bytes: Uint8List.fromList(bytes),
  );
  if (path == null) return null;
  // On desktop the dialog returns the path but does NOT write the bytes.
  // Write them now; catch any content-URI errors on mobile and still return.
  try {
    await File(path).writeAsBytes(bytes);
  } catch (_) {
    // Mobile content-URIs may not be writable directly; ignore.
  }
  return path;
}

Future<String?> saveQrImagesImpl(Map<String, Uint8List> namedPngs) async {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    final dir = await FilePicker.getDirectoryPath();
    if (dir == null) return null;
    for (final entry in namedPngs.entries) {
      await File('$dir${Platform.pathSeparator}${entry.key}')
          .writeAsBytes(entry.value);
    }
    return dir;
  } else {
    // Mobile: zip all PNGs into a single file.
    final zipBytes = _zip(namedPngs);
    final path = await FilePicker.saveFile(
      fileName: 'otp_qrcodes.zip',
      bytes: zipBytes,
    );
    return path;
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
